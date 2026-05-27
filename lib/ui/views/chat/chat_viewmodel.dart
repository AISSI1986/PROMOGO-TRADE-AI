import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/models/chat_room.dart';
import 'package:promogoai/models/chat_message.dart';
import 'package:promogoai/services/chat_service.dart';
import 'package:promogoai/services/auth_service.dart';

class ChatViewModel extends BaseViewModel with WidgetsBindingObserver {
  final _chatService = locator<ChatService>();
  final _authService = locator<AuthService>();

  late ChatRoomModel _room;
  ChatRoomModel get room => _room;

  List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => _messages;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  StreamSubscription<ChatMessageModel>? _messageSubscription;
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;
  StreamSubscription<ChatConnectionState>? _connectionStateSubscription;
  ChatConnectionState _connectionStatus = ChatConnectionState.disconnected;
  ChatConnectionState get connectionStatus => _connectionStatus;

  final List<ChatMessageModel> _pendingMessages = [];
  Timer? _typingTimer;
  bool _isCurrentlyTyping = false;

  bool _otherUserIsOnline = false;
  bool get otherUserIsOnline => _otherUserIsOnline;

  DateTime? _otherUserLastSeen;
  DateTime? get otherUserLastSeen => _otherUserLastSeen;

  bool _otherUserIsTyping = false;
  bool get otherUserIsTyping => _otherUserIsTyping;

  int? get currentUserId => _authService.userData?['id'] as int?;
  int get otherUserId => currentUserId == _room.buyerId ? _room.sellerId : _room.buyerId;

  Future<void> init(ChatRoomModel chatRoom) async {
    _room = chatRoom;
    
    // Enregistrer l'observateur de cycle de vie
    WidgetsBinding.instance.addObserver(this);

    // Initialiser les états de présence de l'autre utilisateur
    _otherUserIsOnline = currentUserId == _room.buyerId ? _room.sellerIsOnline : _room.buyerIsOnline;
    _otherUserLastSeen = currentUserId == _room.buyerId ? _room.sellerLastSeen : _room.buyerLastSeen;

    // 1. Charger d'abord les messages depuis le cache local pour un affichage immédiat
    final cachedMsgs = await _chatService.loadCachedMessages(_room.id);
    if (cachedMsgs.isNotEmpty) {
      _messages = cachedMsgs;
    } else {
      setBusy(true);
    }
    
    // 2. Charger/Rafraîchir depuis le réseau
    _messages = await _chatService.fetchMessages(_room.id);
    setBusy(false);

    // 3. Se connecter au WebSocket pour recevoir les messages en temps réel
    _chatService.connectToRoom(_room.id);

    // Écouter le statut de connexion du socket
    _connectionStatus = _chatService.connectionState;
    _connectionStateSubscription = _chatService.connectionStateStream.listen((state) {
      final oldState = _connectionStatus;
      _connectionStatus = state;
      notifyListeners();

      if (oldState != ChatConnectionState.connected && state == ChatConnectionState.connected) {
        print("🔄 [ChatViewModel] Reconnecté ! Début de la synchronisation...");
        _syncMessages();
      }
    });

    final userId = currentUserId;
    if (userId != null) {
      // Signaler la lecture des messages
      _chatService.sendReadAll(_room.id, userId);
    }

    // 4. Écouter les nouveaux messages arrivant du WebSocket
    _messageSubscription = _chatService.messageStream.listen((newMsg) {
      if (newMsg.roomId == _room.id) {
        if (!_messages.any((m) => m.id == newMsg.id)) {
          _messages.add(newMsg);
          notifyListeners();
          _scrollToBottom();

          // Sauvegarder dans le cache local
          _chatService.cacheMessages(_room.id, _messages);
          _chatService.updateRoomLastMessage(_room.id, newMsg.content, newMsg.timestamp);

          // Si le message vient de l'autre, on met à jour la lecture
          if (newMsg.senderId == otherUserId && userId != null) {
            _chatService.sendReadAll(_room.id, userId);
          }
        }
      }
    });

    // 4. Écouter les événements temps réel (présence, saisie, lecture)
    _eventSubscription = _chatService.eventStream.listen((event) {
      final type = event['type'];
      if (type == 'user_presence') {
        final uId = event['user_id'] as int;
        if (uId == otherUserId) {
          _otherUserIsOnline = event['is_online'] as bool;
          if (event['last_seen'] != null) {
            _otherUserLastSeen = DateTime.parse(event['last_seen'] as String);
          }
          notifyListeners();
        }
      } else if (type == 'typing') {
        final sId = event['sender_id'] as int;
        if (sId == otherUserId) {
          _otherUserIsTyping = event['is_typing'] as bool;
          notifyListeners();
        }
      } else if (type == 'messages_read') {
        final rId = event['reader_id'] as int;
        if (rId == otherUserId) {
          // Mettre à jour l'état de lecture de nos messages
          for (var i = 0; i < _messages.length; i++) {
            if (_messages[i].senderId == currentUserId && !_messages[i].isRead) {
              _messages[i] = ChatMessageModel(
                id: _messages[i].id,
                roomId: _messages[i].roomId,
                senderId: _messages[i].senderId,
                senderUsername: _messages[i].senderUsername,
                content: _messages[i].content,
                timestamp: _messages[i].timestamp,
                isRead: true,
              );
            }
          }
          notifyListeners();
          // Sauvegarder dans le cache local
          _chatService.cacheMessages(_room.id, _messages);
        }
      }
    });

    messageController.addListener(_onMessageControllerChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: false);
    });
  }

  void _onMessageControllerChanged() {
    final text = messageController.text;
    final userId = currentUserId;
    if (userId == null) return;

    if (text.isNotEmpty && !_isCurrentlyTyping) {
      _isCurrentlyTyping = true;
      _chatService.sendTypingStatus(_room.id, userId, true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isCurrentlyTyping) {
        _isCurrentlyTyping = false;
        _chatService.sendTypingStatus(_room.id, userId, false);
      }
    });
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final userId = currentUserId;
    if (userId == null) return;

    // Créer un message temporaire local avec un ID négatif unique et isPending: true
    final tempId = DateTime.now().millisecondsSinceEpoch * -1;
    final pendingMsg = ChatMessageModel(
      id: tempId,
      roomId: _room.id,
      senderId: userId,
      senderUsername: (_authService.userData?['username'] as String?) ?? '',
      content: text,
      timestamp: DateTime.now(),
      isRead: false,
      isPending: true,
    );

    // Ajouter directement à l'affichage local (affichera une coche simple ✓ car isRead est false)
    _messages.add(pendingMsg);
    _pendingMessages.add(pendingMsg);
    
    _typingTimer?.cancel();
    if (_isCurrentlyTyping) {
      _isCurrentlyTyping = false;
      _chatService.sendTypingStatus(_room.id, userId, false);
    }

    messageController.clear();
    notifyListeners();
    _scrollToBottom();

    // Lancer la tentative d'envoi en arrière-plan
    _sendPendingMessage(pendingMsg);
  }

  Future<void> _sendPendingMessage(ChatMessageModel pendingMsg) async {
    try {
      // Envoyer via REST API pour s'assurer de la persistance en BDD
      final responseMsg = await _chatService.sendChatMessage(_room.id, pendingMsg.content);
      if (responseMsg != null) {
        final index = _messages.indexWhere((m) => m.id == pendingMsg.id);
        if (index != -1) {
          // Remplacer le message temporaire par le message réel de la base de données
          _messages[index] = responseMsg;
        }
        _pendingMessages.removeWhere((m) => m.id == pendingMsg.id);
        notifyListeners();
        // Sauvegarder dans le cache local
        _chatService.cacheMessages(_room.id, _messages);
        _chatService.updateRoomLastMessage(_room.id, responseMsg.content, responseMsg.timestamp);
      }
    } catch (e) {
      print("❌ [ChatViewModel] Erreur envoi message en attente: $e");
    }
  }

  void _retryPendingMessages() {
    if (_pendingMessages.isEmpty) return;
    print("🔄 [ChatViewModel] Renvoi de ${_pendingMessages.length} message(s) en attente...");
    final list = List<ChatMessageModel>.from(_pendingMessages);
    for (var pending in list) {
      _sendPendingMessage(pending);
    }
  }

  Future<void> _syncMessages() async {
    final freshMessages = await _chatService.fetchMessages(_room.id);
    if (freshMessages.isEmpty) return;

    bool updated = false;
    for (var fresh in freshMessages) {
      final index = _messages.indexWhere((m) => m.id == fresh.id);
      if (index == -1) {
        _messages.add(fresh);
        updated = true;
      } else {
        if (_messages[index].isRead != fresh.isRead) {
          _messages[index] = fresh;
          updated = true;
        }
      }
    }

    if (updated) {
      // Trier par date chronologique
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      notifyListeners();
      _scrollToBottom();
      
      // Sauvegarder dans le cache local
      _chatService.cacheMessages(_room.id, _messages);
      if (_messages.isNotEmpty) {
        _chatService.updateRoomLastMessage(_room.id, _messages.last.content, _messages.last.timestamp);
      }
    }

    // Réessayer d'envoyer les messages en attente après la synchro
    _retryPendingMessages();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("📱 [ChatViewModel] App au premier plan, reconnexion...");
      _chatService.connectToRoom(_room.id);
    } else if (state == AppLifecycleState.paused) {
      print("📱 [ChatViewModel] App en arrière-plan, déconnexion...");
      _chatService.disconnect();
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (scrollController.hasClients) {
          if (animated) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent + 100,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            scrollController.jumpTo(scrollController.position.maxScrollExtent + 100);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    messageController.removeListener(_onMessageControllerChanged);
    messageController.dispose();
    scrollController.dispose();
    _messageSubscription?.cancel();
    _eventSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _typingTimer?.cancel();
    _chatService.disconnect();
    super.dispose();
  }
}
