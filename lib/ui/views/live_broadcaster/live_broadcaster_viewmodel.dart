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

// IMPORTS POUR LE MOTEUR APIVIDEO (Plus stable que HaishinKit sur Android)
import 'package:apivideo_live_stream/apivideo_live_stream.dart';

class LiveBroadcasterViewModel extends BaseViewModel {
  final _socketService = locator<LiveSocketService>();
  final _srsService = locator<SrsStreamingService>();
  final _authService = locator<AuthService>();
  
  ApiVideoLiveStreamController? _controller;
  ApiVideoLiveStreamController? get controller => _controller;

  bool _isLive = false;
  bool get isLive => _isLive;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isFrontCamera = false;
  bool get isFrontCamera => _isFrontCamera;

  int _viewerCount = 0;
  int get viewerCount => _viewerCount;

  String liveId = "";
  List<Map<String, dynamic>> sellerProducts = [];

  List<Map<String, dynamic>> _pinnedProducts = [];
  List<Map<String, dynamic>> get pinnedProducts => _pinnedProducts;
  
  Offset _pinnedPosition = const Offset(20, 250); // Position par défaut (un peu sur le côté)
  Offset get pinnedPosition => _pinnedPosition;

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
    
    // 🛑 VITAL : On attend 1 seconde complète pour que l'animation de changement de page soit finie
    // et que l'ancien écran Pre-Live ait TOTALEMENT libéré le capteur photo Android.
    await Future.delayed(const Duration(milliseconds: 1000));
    await _initStreaming();
    _socketService.connect(liveId);
    _fetchChatHistory();
    
    _socketSubscription = _socketService.events.listen((event) {
      final type = event['type'];
      
      if (type == 'chat_message') {
        _chatMessages.add({
          "user": event['user'] ?? "Anonyme",
          "message": event['message'] ?? "",
          "isMe": false,
        });
        notifyListeners();
      } else if (type == 'order_request') {
        // Notification dans le chat aussi pour la preuve sociale
        _chatMessages.add({
          "user": "SYSTÈME",
          "message": "🔥 ${event['buyer_name']} vient de commander ${event['product_name']} !",
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

  void sendMessage() {
    final text = chatController.text.trim();
    if (text.isEmpty) return;

    final payload = {
      "type": "chat_message",
      "user": _authService.userData?['username'] ?? "Vendeur",
      "message": text,
    };

    _socketService.sendEvent(payload);
    _chatMessages.add({...payload, "isMe": true});
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
        final List<dynamic> data = json.decode(response.body);
        for (var msg in data) {
          _chatMessages.add({
            "user": msg['user'],
            "message": msg['message'],
            "isMe": msg['user'] == (_authService.userData?['username'] ?? ""),
            "isSystem": msg['is_system'] ?? false,
          });
        }
        notifyListeners();
      }
    } catch (e) {
      print("❌ [LiveBroadcaster] Erreur récupération historique chat: $e");
    }
  }

  Future<void> _initStreaming() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      _controller = ApiVideoLiveStreamController(
        initialAudioConfig: AudioConfig(bitrate: 128000),
        initialVideoConfig: VideoConfig.withDefaultBitrate(resolution: Resolution.RESOLUTION_720),
        onConnectionSuccess: () { print("✅ [LiveBroadcaster] RTMP Connecté"); },
        onConnectionFailed: (error) { print("❌ [LiveBroadcaster] Erreur RTMP: $error"); },
      );

      _isFrontCamera = true;
      
      // Allumer la caméra locale
      await _controller!.initialize();
      
      notifyListeners();
    } catch (e) {
      print("❌ [LiveBroadcaster] Erreur Init apivideo : $e");
    }
  }


  bool _showLiveIndicator = false;
  bool get showLiveIndicator => _showLiveIndicator;

  void toggleLive() async {
    if (!_isLive) {
      final rtmpUrl = _srsService.getRtmpPushUrl(liveId);
      try {
        // 1. MISE À JOUR DU STATUT EN BASE DE DONNÉES (Django)
        await http.patch(
          Uri.parse(ApiConstants.getUpdateLiveStatusEndpoint(liveId)),
          headers: {'Authorization': 'Bearer ${_authService.accessToken}'},
          body: {'status': 'LIVE'},
        );

        // 2. CONNEXION RTMP APIVIDEO
        String baseUrl = "rtmp://${ApiConstants.srsHost}:1935/live";
        await _controller!.startStreaming(streamKey: liveId, url: baseUrl);
        
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
        print("❌ [LiveBroadcaster] Erreur Lancement : $e");
      }
    } else {
      // ARRÊT DU LIVE
      _showLiveIndicator = false;
      
      try {
        // Mise à jour du statut en base de données EN PREMIER (au cas où la vidéo plante)
        await http.patch(
          Uri.parse(ApiConstants.getUpdateLiveStatusEndpoint(liveId)),
          headers: {'Authorization': 'Bearer ${_authService.accessToken}'},
          body: {'status': 'ENDED'},
        );
        print("✅ [LiveBroadcaster] Statut passé à ENDED dans la base de données");
      } catch (e) {
        print("❌ [LiveBroadcaster] Erreur appel API ENDED : $e");
      }

      try {
        await _controller!.stop();
      } catch (e) {
        print("⚠️ [LiveBroadcaster] Erreur lors de la fermeture RTMP : $e");
      }
      
      _isLive = false;
      _stopTimer();
      _socketService.sendEvent({"type": "live_status", "status": "ended"});
    }
    notifyListeners();
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
    _controller?.setAudioConfig(AudioConfig(bitrate: _isMuted ? 0 : 128000));
    notifyListeners();
  }

  void switchCamera() async {
    _isFrontCamera = !_isFrontCamera;
    await _controller?.switchCamera();
    notifyListeners();
  }

  final List<Map<String, dynamic>> _incomingOrders = [];
  List<Map<String, dynamic>> get incomingOrders => _incomingOrders;
  Duration _liveDuration = Duration.zero;
  String get formattedDuration => _liveDuration.toString().split('.').first.padLeft(8, "0");
  Timer? _liveTimer;
  StreamSubscription? _socketSubscription;

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
  void dispose() {
    _socketSubscription?.cancel();
    _socketService.disconnect();
    _stopTimer();
    _controller?.stop();
    super.dispose();
  }
}
