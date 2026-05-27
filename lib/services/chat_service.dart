import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:promogoai/models/chat_room.dart';
import 'package:promogoai/models/chat_message.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/services/local_storage_service.dart';
import 'package:promogoai/app/app.locator.dart';

enum ChatConnectionState { connecting, connected, disconnected }

class ChatService {
  final _authService = locator<AuthService>();
  final _localStorageService = locator<LocalStorageService>();
  WebSocketChannel? _channel;
  final _messageStreamController = StreamController<ChatMessageModel>.broadcast();
  final _eventStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStateController = StreamController<ChatConnectionState>.broadcast();
  
  int? _activeRoomId;
  ChatConnectionState _connectionState = ChatConnectionState.disconnected;
  Timer? _reconnectTimer;
  int _reconnectDelaySeconds = 1;

  Stream<ChatMessageModel> get messageStream => _messageStreamController.stream;
  Stream<Map<String, dynamic>> get eventStream => _eventStreamController.stream;
  Stream<ChatConnectionState> get connectionStateStream => _connectionStateController.stream;
  
  ChatConnectionState get connectionState => _connectionState;


  Map<String, String> _getHeaders() {
    final token = _authService.accessToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _getRoomsCacheKey() {
    final userId = _authService.userData?['id'];
    return 'chat_rooms_${userId ?? "anon"}.json';
  }

  String _getMessagesCacheKey(int roomId) {
    return 'chat_messages_$roomId.json';
  }

  Future<List<ChatRoomModel>> loadCachedRooms() async {
    try {
      final cachedData = await _localStorageService.getJson(_getRoomsCacheKey());
      if (cachedData != null && cachedData is List) {
        return cachedData.map((item) => ChatRoomModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print("❌ [ChatService] Erreur chargement salons en cache: $e");
    }
    return [];
  }

  Future<List<ChatMessageModel>> loadCachedMessages(int roomId) async {
    try {
      final cachedData = await _localStorageService.getJson(_getMessagesCacheKey(roomId));
      if (cachedData != null && cachedData is List) {
        return cachedData.map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print("❌ [ChatService] Erreur chargement messages en cache: $e");
    }
    return [];
  }

  Future<void> cacheMessages(int roomId, List<ChatMessageModel> messages) async {
    try {
      final list = messages.map((m) => m.toJson()).toList();
      await _localStorageService.saveJson(_getMessagesCacheKey(roomId), list);
    } catch (e) {
      print("❌ [ChatService] Erreur sauvegarde messages en cache: $e");
    }
  }

  /// Récupérer la liste des salons de discussion de l'utilisateur
  Future<List<ChatRoomModel>> fetchRooms() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.chatRoomsEndpoint),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data.containsKey('results')) {
          list = data['results'] as List<dynamic>;
        }
        await _localStorageService.saveJson(_getRoomsCacheKey(), list);
        return list.map((item) => ChatRoomModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        print("❌ [ChatService] Erreur fetchRooms: ${response.statusCode} | ${response.body}");
        return await loadCachedRooms();
      }
    } catch (e) {
      print("❌ [ChatService] Exception fetchRooms: $e");
      return await loadCachedRooms();
    }
  }

  /// Créer ou obtenir un salon de discussion pour un vendeur et produit
  Future<ChatRoomModel?> getOrCreateRoom(int sellerId, int? productId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.chatGetOrCreateRoomEndpoint),
        headers: _getHeaders(),
        body: jsonEncode({
          'seller_id': sellerId,
          if (productId != null) 'product_id': productId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return ChatRoomModel.fromJson(data as Map<String, dynamic>);
      } else {
        print("❌ [ChatService] Erreur getOrCreateRoom: ${response.statusCode} | ${response.body}");
      }
    } catch (e) {
      print("❌ [ChatService] Exception getOrCreateRoom: $e");
      rethrow;
    }
    return null;
  }

  /// Charger l'historique des messages d'un salon
  Future<List<ChatMessageModel>> fetchMessages(int roomId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getChatMessagesEndpoint(roomId)),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data.containsKey('results')) {
          list = data['results'] as List<dynamic>;
        }
        await _localStorageService.saveJson(_getMessagesCacheKey(roomId), list);
        return list.map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        print("❌ [ChatService] Erreur fetchMessages: ${response.statusCode} | ${response.body}");
        return await loadCachedMessages(roomId);
      }
    } catch (e) {
      print("❌ [ChatService] Exception fetchMessages: $e");
      return await loadCachedMessages(roomId);
    }
  }


  /// Envoyer un message via REST (comme solution de secours)
  Future<ChatMessageModel?> sendChatMessage(int roomId, String content) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getSendChatMessageEndpoint(roomId)),
        headers: _getHeaders(),
        body: jsonEncode({'content': content}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return ChatMessageModel.fromJson(data as Map<String, dynamic>);
      } else {
        print("❌ [ChatService] Erreur sendChatMessage: ${response.statusCode} | ${response.body}");
      }
    } catch (e) {
      print("❌ [ChatService] Exception sendChatMessage: $e");
    }
    return null;
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _updateConnectionState(ChatConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  /// Se connecter au WebSocket du salon de discussion
  void connectToRoom(int roomId) {
    if (_activeRoomId == roomId && _channel != null && _connectionState == ChatConnectionState.connected) {
      print("⚠️ [ChatService] Déjà connecté au salon $roomId");
      return;
    }

    if (_activeRoomId != roomId) {
      disconnect();
      _activeRoomId = roomId;
    }

    _cancelReconnectTimer();
    _connect();
  }

  void _connect() async {
    final roomId = _activeRoomId;
    if (roomId == null) return;

    _updateConnectionState(ChatConnectionState.connecting);

    // Vérifier si le serveur de socket est joignable via socket TCP pour éviter l'exception non gérée
    bool online = false;
    try {
      final socket = await Socket.connect('31.97.116.73', 8085, timeout: const Duration(seconds: 2));
      socket.destroy();
      online = true;
    } catch (_) {
      online = false;
    }

    if (!online) {
      print("⏳ [ChatWebSocket] Serveur injoignable, planification de la reconnexion...");
      _handleDisconnection();
      return;
    }

    final senderId = _authService.userData?['id'];
    var url = ApiConstants.getChatWebSocketUrl(roomId);
    if (senderId != null) {
      url = '$url?sender_id=$senderId';
    }
    print("🌐 [ChatWebSocket] Tentative de connexion sur $url");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _channel!.stream.listen(
        (message) {
          if (_connectionState != ChatConnectionState.connected) {
            print("✅ [ChatWebSocket] Connexion établie avec succès !");
            _updateConnectionState(ChatConnectionState.connected);
            _reconnectDelaySeconds = 1; // reset delay
          }
          print("📩 [ChatWebSocket] Message brut reçu: $message");
          try {
            final data = jsonDecode(message as String) as Map<String, dynamic>;
            _eventStreamController.add(data);
            if (data['type'] == 'chat_message' && data['message'] != null) {
              final msg = ChatMessageModel.fromJson(data['message'] as Map<String, dynamic>);
              _messageStreamController.add(msg);
            }
          } catch (e) {
            print("❌ [ChatWebSocket] Erreur décodage message: $e");
          }
        },
        onError: (Object error) {
          print("❌ [ChatWebSocket] Erreur connexion: $error");
          _handleDisconnection();
        },
        onDone: () {
          print("🔌 [ChatWebSocket] Connexion fermée");
          _handleDisconnection();
        },
      );
    } catch (e) {
      print("❌ [ChatWebSocket] Exception connexion: $e");
      _handleDisconnection();
    }
  }

  void _handleDisconnection() {
    _channel = null;
    _updateConnectionState(ChatConnectionState.disconnected);

    if (_activeRoomId != null) {
      _scheduleReconnection();
    }
  }

  void _scheduleReconnection() {
    if (_reconnectTimer != null) return;

    print("⏳ [ChatWebSocket] Planification de la reconnexion dans $_reconnectDelaySeconds secondes...");
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelaySeconds), () {
      _reconnectTimer = null;
      if (_reconnectDelaySeconds < 16) {
        _reconnectDelaySeconds *= 2;
      }
      _connect();
    });
  }


  /// Envoyer un message via WebSocket
  void sendMessageViaWebSocket(int roomId, int senderId, String content) {
    if (_channel != null && _activeRoomId == roomId) {
      final payload = {
        'sender_id': senderId,
        'content': content,
      };
      print("📤 [ChatWebSocket] Envoi message: $payload");
      _channel!.sink.add(jsonEncode(payload));
    } else {
      print("⚠️ [ChatService] WebSocket non connecté, envoi via REST fallback");
      sendChatMessage(roomId, content).then((msg) {
        if (msg != null) {
          _messageStreamController.add(msg);
        }
      });
    }
  }

  /// Émettre l'état de saisie (typing)
  void sendTypingStatus(int roomId, int senderId, bool isTyping) {
    if (_channel != null && _activeRoomId == roomId) {
      final payload = {
        'type': 'typing',
        'sender_id': senderId,
        'is_typing': isTyping,
      };
      print("📤 [ChatWebSocket] Envoi typing: $payload");
      _channel!.sink.add(jsonEncode(payload));
    }
  }

  /// Confirmer la lecture de tous les messages du salon
  void sendReadAll(int roomId, int readerId) {
    if (_channel != null && _activeRoomId == roomId) {
      final payload = {
        'type': 'read_all',
        'reader_id': readerId,
      };
      print("📤 [ChatWebSocket] Envoi read_all: $payload");
      _channel!.sink.add(jsonEncode(payload));
    }
  }

  /// Déconnexion du WebSocket actuel
  void disconnect() {
    _cancelReconnectTimer();
    _channel?.sink.close();
    _channel = null;
    _activeRoomId = null;
    _reconnectDelaySeconds = 1;
    _updateConnectionState(ChatConnectionState.disconnected);
    print("🛑 [ChatService] Déconnecté du salon");
  }

  /// Mettre à jour localement le dernier message du salon dans la liste en cache
  Future<void> updateRoomLastMessage(int roomId, String content, DateTime timestamp) async {
    try {
      final cached = await loadCachedRooms();
      final index = cached.indexWhere((r) => r.id == roomId);
      if (index != -1) {
        final updatedRoom = ChatRoomModel(
          id: cached[index].id,
          buyerId: cached[index].buyerId,
          sellerId: cached[index].sellerId,
          adId: cached[index].adId,
          buyerUsername: cached[index].buyerUsername,
          sellerUsername: cached[index].sellerUsername,
          buyerFullName: cached[index].buyerFullName,
          sellerFullName: cached[index].sellerFullName,
          buyerPhone: cached[index].buyerPhone,
          sellerPhone: cached[index].sellerPhone,
          adTitle: cached[index].adTitle,
          adPrice: cached[index].adPrice,
          adImageUrl: cached[index].adImageUrl,
          lastMessageContent: content,
          lastMessageTime: timestamp,
          unreadCount: cached[index].unreadCount,
          buyerIsOnline: cached[index].buyerIsOnline,
          buyerLastSeen: cached[index].buyerLastSeen,
          sellerIsOnline: cached[index].sellerIsOnline,
          sellerLastSeen: cached[index].sellerLastSeen,
        );
        cached[index] = updatedRoom;
        await _localStorageService.saveJson(_getRoomsCacheKey(), cached.map((r) => r.toJson()).toList());
      }
    } catch (e) {
      print("❌ [ChatService] Erreur mise à jour dernier message salon: $e");
    }
  }
}
