import 'package:flutter/material.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/services/live_socket_service.dart';
import 'package:promogoai/services/srs_streaming_service.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stacked/stacked.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:promogoai/services/live_streaming_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/ui/common/setup_snackbar_ui.dart';

class LiveBroadcasterViewModel extends BaseViewModel with WidgetsBindingObserver {
  final _authService = locator<AuthService>();
  final _socketService = locator<LiveSocketService>();
  final _streamingService = locator<LiveStreamingService>();
  final _srsService = locator<SrsStreamingService>();
  final _snackbarService = locator<SnackbarService>();

  bool _isDisposed = false;
  
  Widget buildVideoView({bool isBroadcaster = false}) {
    return _streamingService.buildVideoView(channelId: liveId, isBroadcaster: isBroadcaster);
  }

  bool _isStreamingInitialized = false;
  bool get isStreamingInitialized => _isStreamingInitialized;

  bool _isLive = false;
  bool get isLive => _isLive;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isFrontCamera = false;
  bool get isFrontCamera => _isFrontCamera;

  int _viewerCount = 0;
  int get viewerCount => _viewerCount;

  int _likesCount = 0;
  int get likesCount => _likesCount;

  String liveId = "";
  List<Map<String, dynamic>> sellerProducts = [];

  List<Map<String, dynamic>> _pinnedProducts = [];
  List<Map<String, dynamic>> get pinnedProducts => _pinnedProducts;
  
  Offset _pinnedPosition = const Offset(20, 250); // Position par défaut (un peu sur le côté)
  Offset get pinnedPosition => _pinnedPosition;

  List<Map<String, dynamic>> floatingHearts = [];
  int heartCounter = 0;

  void pinProduct(Map<String, dynamic> product) {
    // On vérifie si déjà épinglé
    bool alreadyPinned = _pinnedProducts.any((p) => p['id'] == product['id']);
    
    if (!alreadyPinned && _pinnedProducts.length < 6) {
      _pinnedProducts.add(product);
      _socketService.sendEvent({
        "type": "pin_product",
        "product": product,
      });
      notifyListeners();
    }
  }

  void unpinProduct(int index) {
    final product = _pinnedProducts[index];
    _pinnedProducts.removeAt(index);
    _socketService.sendEvent({
      "type": "unpin_product",
      "product_id": product['id'],
    });
    notifyListeners();
  }

  void unpinAllProducts() {
    _pinnedProducts.clear();
    _socketService.sendEvent({
      "type": "unpin_all_products",
    });
    notifyListeners();
  }

  void updatePinnedPosition(Offset delta) {
    _pinnedPosition += delta;
    notifyListeners();
  }

  Future<void> updateProduct(int index, String newName, String newPrice) async {
    final product = sellerProducts[index];
    final productId = product['id'].toString();

    // 1. MISE À JOUR LOCALE IMMÉDIATE (Réactivité)
    sellerProducts[index]['name'] = newName;
    sellerProducts[index]['price'] = "$newPrice GHS";
    
    // Mettre à jour dans la liste des épinglés si présent
    for (int i = 0; i < _pinnedProducts.length; i++) {
      if (_pinnedProducts[i]['id'] == product['id']) {
        _pinnedProducts[i] = Map<String, dynamic>.from(sellerProducts[index]);
      }
    }
    notifyListeners();

    try {
      // 2. SAUVEGARDE EN BASE DE DONNÉES (Backend)
      final response = await http.patch(
        Uri.parse(ApiConstants.getUpdateLiveProductEndpoint(productId)),
        headers: {
          'Authorization': 'Bearer ${_authService.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "name": newName,
          "price": newPrice.replaceAll(RegExp(r'[^0-9.]'), ''),
        }),
      );

      if (response.statusCode == 200) {
        print("✅ [LiveBroadcaster] Produit $productId mis à jour sur le backend");
        
        // 3. NOTIFICATION TEMPS RÉEL (WebSocket)
        _socketService.sendEvent({
          "type": "product_update",
          "product_id": productId,
          "name": newName,
          "price": "$newPrice GHS",
        });
      } else if (response.statusCode == 401) {
        print("🔑 [LiveBroadcaster] 401 sur update product. Tentative de refresh...");
        final refreshed = await _authService.refreshAccessToken();
        if (refreshed) {
          return await updateProduct(index, newName, newPrice);
        }
      } else {
        print("⚠️ [LiveBroadcaster] Erreur backend (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("❌ [LiveBroadcaster] Erreur réseau lors de la mise à jour : $e");
    }
  }

  void initBroadcaster(String id, List<Map<String, dynamic>> products) async {
    this.liveId = id;
    this.sellerProducts = products;
    WakelockPlus.enable(); // Garde l'écran allumé pendant le Live !
    WidgetsBinding.instance.addObserver(this);
    
    // 🛑 VITAL : On attend 1 seconde complète pour que l'animation de changement de page soit finie
    // et que l'ancien écran Pre-Live ait TOTALEMENT libéré le capteur photo Android.
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    await _initStreaming();
    _socketService.connect(liveId);
    _fetchChatHistory();
    
    _socketSubscription = _socketService.events.listen((event) {
      final type = event['type'];
      if (type == 'chat_message') {
        final incomingUser = event['user']?.toString() ?? "Utilisateur";
        final myUserName = formatUserName(_authService.userData?['username']?.toString() ?? "Vendeur");
        // Ignorer l'écho de notre propre message (déjà ajouté localement dans sendMessage)
        if (incomingUser != myUserName) {
          _chatMessages.insert(0, {
            "user": incomingUser,
            "message": event['message'] ?? "",
            "isMe": false,
          });
          notifyListeners();
        }
      } else if (type == 'like') {
        _likesCount++;
        heartCounter++;
        _showLocalHeart(heartCounter);
        notifyListeners();
      } else if (type == 'order_request') {
        // Notification dans le chat aussi pour la preuve sociale
        _chatMessages.insert(0, {
          "user": "SYSTÈME",
          "message": "🛍️ ${event['buyer_name']} vient de commander ${event['product_name']} !",
          "isMe": false,
          "isSystem": true,
        });
        
        _incomingOrders.insert(0, {
          "buyer": event['buyer_name'],
          "phone": event['buyer_phone'],
          "product": event['product_name'],
          "location": event['buyer_location'],
          "time": DateTime.now(),
        });
        notifyListeners();
      }
    });
  }

  final List<Map<String, dynamic>> _chatMessages = [
    {"user": "SURA IA", "message": "Bon direct ! Tes clients sont impatients.", "isSystem": true}
  ];
  List<Map<String, dynamic>> get chatMessages => _chatMessages;
  final TextEditingController chatController = TextEditingController();

  String formatUserName(String rawName) {
    if (rawName.isEmpty) return "Anonyme";
    final phoneRegex = RegExp(r'^\+?[0-9]{8,}$');
    if (phoneRegex.hasMatch(rawName)) {
      // Le vendeur ne veut AUCUN chiffre. On transforme les 2 derniers chiffres en un acronyme de 2 lettres.
      final letters = ["A","B","C","D","E","F","G","H","I","K"];
      int d1 = int.parse(rawName[rawName.length - 2]);
      int d2 = int.parse(rawName[rawName.length - 1]);
      return "${letters[d1]}${letters[d2]}";
    }
    return rawName;
  }

  void _showLocalHeart(int id) {
    if (!_isDisposed) {
      final random = math.Random();
      floatingHearts.add({
        'id': id,
        'xOffset': (random.nextDouble() * 80) - 40,
        'colorIndex': random.nextInt(Colors.primaries.length),
      });
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!_isDisposed) {
          floatingHearts.removeWhere((h) => h['id'] == id);
          notifyListeners();
        }
      });
    }
  }

  void sendMessage() {
    final text = chatController.text.trim();
    if (text.isEmpty) return;

    final userName = formatUserName(_authService.userData?['username']?.toString() ?? "Vendeur");

    final payload = {
      "type": "chat_message",
      "user": userName,
      "message": text,
    };

    _socketService.sendEvent(payload);
    _chatMessages.insert(0, {...payload, "isMe": true});
    chatController.clear();
    notifyListeners();
  }

  Future<void> _fetchChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getLiveChatHistoryEndpoint(liveId)),
        headers: {'Authorization': 'Bearer ${_authService.accessToken}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        for (var msg in data) {
          _chatMessages.insert(0, {
            "user": msg['user'],
            "message": msg['message'],
            "isMe": msg['user'] == (_authService.userData?['username'] ?? ""),
            "isSystem": msg['is_system'] ?? false,
          });
        }
        notifyListeners();
      } else if (response.statusCode == 401) {
        print("🔑 [LiveBroadcaster] 401 sur fetch chat history. Tentative de refresh...");
        final refreshed = await _authService.refreshAccessToken();
        if (refreshed) {
          return await _fetchChatHistory();
        }
      }
    } catch (e) {
      print("❌ [LiveBroadcaster] Erreur récupération historique chat: $e");
    }
  }

  Future<void> _initStreaming() async {
    try {
      // 1. Demander explicitement les permissions pour Agora
      await [Permission.camera, Permission.microphone].request();

      if (!isStreamingInitialized) {
        await _streamingService.initialize();
        await _streamingService.startLocalPreview();
      }
      _isStreamingInitialized = true;
      notifyListeners();
    } catch (e) {
      print("[LiveBroadcaster] Erreur Init Agora : $e");
    }
  }


  bool _showLiveIndicator = false;
  bool get showLiveIndicator => _showLiveIndicator;

  Future<void> endLiveSession() async {
    if (_isLive || liveId.isNotEmpty) {
      try {
        final response = await http.patch(
          Uri.parse(ApiConstants.getUpdateLiveStatusEndpoint(liveId)),
          headers: {
            'Authorization': 'Bearer ${_authService.accessToken}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'status': 'ENDED',
            'duration_seconds': _liveDuration.inSeconds,
            'final_viewer_count': _viewerCount,
            'final_likes_count': _likesCount,
          }),
        );
        print("💡 [LiveBroadcaster] endLiveSession -> Status: ${response.statusCode}, Body: ${response.body}");
        if (response.statusCode == 401) {
          print("🔑 [LiveBroadcaster] 401 sur endLiveSession. Tentative de refresh...");
          final refreshed = await _authService.refreshAccessToken();
          if (refreshed) {
            return await endLiveSession();
          }
        }
        print("[LiveBroadcaster] Statut passé à ENDED dans la base de données");
      } catch (e) {
        print("[LiveBroadcaster] Erreur appel API ENDED : $e");
      }
      try {
        await _streamingService.leaveChannel();
        await _streamingService.stopLocalPreview();
      } catch (e) {
        print("[LiveBroadcaster] Erreur lors de la fermeture Agora : $e");
      }
      _isLive = false;
      _stopTimer();
      _socketService.sendEvent({"type": "live_status", "status": "ended"});
      notifyListeners();
    }
  }

  void toggleLive() async {
    if (!_isLive) {
      try {
        // 1. MISE À JOUR DU STATUT EN BASE DE DONNÉES (Django)
        final response = await http.patch(
          Uri.parse(ApiConstants.getUpdateLiveStatusEndpoint(liveId)),
          headers: {
            'Authorization': 'Bearer ${_authService.accessToken}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'status': 'LIVE'}),
        );
        print("💡 [LiveBroadcaster] toggleLive -> Status: ${response.statusCode}, Body: ${response.body}");

        if (response.statusCode == 401) {
          print("🔑 [LiveBroadcaster] 401 sur toggleLive. Tentative de refresh...");
          final refreshed = await _authService.refreshAccessToken();
          if (refreshed) {
            return toggleLive();
          }
        }

        // 2. CONNEXION AGORA (Récupération du Token)
        String? token;
        try {
          final tokenResponse = await http.get(
            Uri.parse("${ApiConstants.getAgoraTokenEndpoint}?channelName=$liveId&role=broadcaster"),
            headers: {'Authorization': 'Bearer ${_authService.accessToken}'},
          );
          if (tokenResponse.statusCode == 200) {
            final data = jsonDecode(tokenResponse.body);
            token = data['token'];
            print("🔑 [LiveBroadcaster] Token Agora récupéré avec succès.");
          } else {
            print("⚠️ [LiveBroadcaster] Erreur Token Agora: ${tokenResponse.body}");
          }
        } catch(e) {
          print("⚠️ [LiveBroadcaster] Impossible de récupérer le Token Agora: $e");
        }

        await _streamingService.joinChannelAsBroadcaster(liveId, token: token);
        
        _isLive = true;
        _showLiveIndicator = true; // Afficher l'indicateur
        notifyListeners();

        // Cacher l'indicateur après 5 secondes
        Timer(const Duration(seconds: 5), () {
          _showLiveIndicator = false;
          notifyListeners();
        });

        _startTimer();
        _socketService.sendEvent({"type": "live_status", "status": "started"});
      } catch (e) {
        print("[LiveBroadcaster] Erreur Lancement : $e");
      }
    } else {
      await endLiveSession();
    }
  }

  void _startTimer() {
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _liveDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopTimer() {
    _liveTimer?.cancel();
    _liveDuration = Duration.zero;
  }

  void toggleMute() async {
    _isMuted = !_isMuted;
    await _streamingService.toggleMute(_isMuted);
    notifyListeners();
  }

  void switchCamera() async {
    _isFrontCamera = !_isFrontCamera;
    await _streamingService.switchCamera();
    notifyListeners();
  }

  final List<Map<String, dynamic>> _incomingOrders = [];
  List<Map<String, dynamic>> get incomingOrders => _incomingOrders;
  Duration _liveDuration = Duration.zero;
  String get formattedDuration => _liveDuration.toString().split('.').first.padLeft(8, "0");
  Timer? _liveTimer;
  StreamSubscription<dynamic>? _socketSubscription;

  void pinAllProducts() {
    _pinnedProducts.clear();
    // Épingler les 6 premiers produits du catalogue
    for (int i = 0; i < sellerProducts.length && i < 6; i++) {
      _pinnedProducts.add(sellerProducts[i]);
    }
    _socketService.sendEvent({
      "type": "pin_all_products",
      "products": _pinnedProducts,
    });
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_isLive && liveId.isNotEmpty) {
        print("💡 [LiveBroadcaster] Arrière-plan : passage en TEMPORARILY_OFFLINE");
        http.patch(
          Uri.parse(ApiConstants.getUpdateLiveStatusEndpoint(liveId)),
          headers: {
            'Authorization': 'Bearer ${_authService.accessToken}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'status': 'TEMPORARILY_OFFLINE'}),
        ).then((res) => print("💡 [LiveBroadcaster] Arrière-plan Status: ${res.statusCode}"));
        _socketService.sendEvent({"type": "stream_paused"});
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isLive && liveId.isNotEmpty) {
        print("💡 [LiveBroadcaster] Premier plan : retour en LIVE");
        http.patch(
          Uri.parse(ApiConstants.getUpdateLiveStatusEndpoint(liveId)),
          headers: {
            'Authorization': 'Bearer ${_authService.accessToken}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'status': 'LIVE'}),
        ).then((res) => print("💡 [LiveBroadcaster] Premier plan Status: ${res.statusCode}"));
        _socketService.sendEvent({"type": "stream_resumed"});
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Si l'utilisateur quitte l'écran sans avoir arrêté le live, on force le statut ENDED sur Django
    if (_isLive || liveId.isNotEmpty) {
      http.patch(
        Uri.parse(ApiConstants.getUpdateLiveStatusEndpoint(liveId)),
        headers: {
          'Authorization': 'Bearer ${_authService.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': 'ENDED'}),
      ).catchError((_) => http.Response('', 500));
    }
    _socketSubscription?.cancel();
    _socketService.disconnect();
    _stopTimer();
    try {
      _streamingService.dispose();
    } catch (e) {
      print("[LiveBroadcaster] Erreur lors du dispose du controleur: $e");
    }
    WakelockPlus.disable(); // Permet à l'écran de se remettre en veille
    _isDisposed = true;
    super.dispose();
  }
}
