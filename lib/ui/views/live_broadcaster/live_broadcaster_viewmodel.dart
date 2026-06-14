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
import 'package:wakelock_plus/wakelock_plus.dart';

// IMPORTS POUR LE MOTEUR APIVIDEO (Plus stable que HaishinKit sur Android)
import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/ui/common/setup_snackbar_ui.dart';

class LiveBroadcasterViewModel extends BaseViewModel with WidgetsBindingObserver {
  final _socketService = locator<LiveSocketService>();
  final _srsService = locator<SrsStreamingService>();
  final _authService = locator<AuthService>();
  final _snackbarService = locator<SnackbarService>();
  
  ApiVideoLiveStreamController? _controller;
  ApiVideoLiveStreamController? get controller => _controller;

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
        final incomingUser = formatUserName((event['user'] ?? "Anonyme").toString());
        final myUserName = formatUserName(_authService.userData?['username']?.toString() ?? "Vendeur");
        // Ignorer l'écho de notre propre message (déjà ajouté localement dans sendMessage)
        if (incomingUser != myUserName) {
          _chatMessages.add({
            "user": incomingUser,
            "message": event['message'] ?? "",
            "isMe": false,
          });
          notifyListeners();
        }
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
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        for (var msg in data) {
          _chatMessages.add({
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
      // Vérifier le statut actuel
      var cameraStatus = await Permission.camera.status;
      var micStatus = await Permission.microphone.status;

      // Demander explicitement les permissions si pas déjà accordées
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }
      if (!micStatus.isGranted) {
        micStatus = await Permission.microphone.request();
      }

      // Si l'utilisateur a coché "Ne plus demander" ou refusé 2 fois (sur Android)
      if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
        print("❌ [LiveBroadcaster] Permissions refusées définitivement. Ouverture des paramètres...");
        // Notifier l'utilisateur via Snackbar
        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.error,
          message: "Permissions requises. Veuillez les activer dans les paramètres.",
          duration: const Duration(seconds: 4),
        );
        // Ouvre l'écran des paramètres de l'application
        await openAppSettings();
        return;
      }

      if (cameraStatus != PermissionStatus.granted || micStatus != PermissionStatus.granted) {
        print("❌ [LiveBroadcaster] Permissions refusées ! Le flux ne peut pas démarrer.");
        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.error,
          message: "Vous devez autoriser la caméra et le micro pour diffuser.",
        );
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      final controller = ApiVideoLiveStreamController(
        initialAudioConfig: AudioConfig(bitrate: 128000, sampleRate: SampleRate.kHz_44_1),
        initialVideoConfig: VideoConfig.withDefaultBitrate(
          resolution: Resolution.RESOLUTION_480,
          fps: 30,
        ),
        onConnectionSuccess: () { print("[LiveBroadcaster] RTMP Connecté"); },
        onConnectionFailed: (error) { print("[LiveBroadcaster] Erreur RTMP: $error"); },
      );

      _isFrontCamera = true;
      
      // Allumer la caméra locale
      await controller.initialize();
      
      _controller = controller;
      _isStreamingInitialized = true;
      notifyListeners();
    } catch (e) {
      print("[LiveBroadcaster] Erreur Init apivideo : $e");
    }
  }


  bool _showLiveIndicator = false;
  bool get showLiveIndicator => _showLiveIndicator;

  Future<void> endLiveSession() async {
    if (_isLive || liveId.isNotEmpty) {
      try {
        final response = await http.patch(
          Uri.parse(ApiConstants.getUpdateLiveStatusEndpoint(liveId)),
          headers: {'Authorization': 'Bearer ${_authService.accessToken}'},
          body: {'status': 'ENDED'},
        );
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
        await _controller!.stop();
      } catch (e) {
        print("[LiveBroadcaster] Erreur lors de la fermeture RTMP : $e");
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
          headers: {'Authorization': 'Bearer ${_authService.accessToken}'},
          body: {'status': 'LIVE'},
        );

        if (response.statusCode == 401) {
          print("🔑 [LiveBroadcaster] 401 sur toggleLive. Tentative de refresh...");
          final refreshed = await _authService.refreshAccessToken();
          if (refreshed) {
            return toggleLive();
          }
        }

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
    _controller?.setAudioConfig(AudioConfig(bitrate: _isMuted ? 0 : 128000, sampleRate: SampleRate.kHz_44_1));
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
        print("⏸️ [LiveBroadcaster] Arrière-plan : passage en TEMPORARILY_OFFLINE");
        http.patch(
          Uri.parse(ApiConstants.getUpdateLiveStatusEndpoint(liveId)),
          headers: {'Authorization': 'Bearer ${_authService.accessToken}'},
          body: {'status': 'TEMPORARILY_OFFLINE'},
        );
        _socketService.sendEvent({"type": "stream_paused"});
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isLive && liveId.isNotEmpty) {
        print("▶️ [LiveBroadcaster] Premier plan : retour en LIVE");
        http.patch(
          Uri.parse(ApiConstants.getUpdateLiveStatusEndpoint(liveId)),
          headers: {'Authorization': 'Bearer ${_authService.accessToken}'},
          body: {'status': 'LIVE'},
        );
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
        headers: {'Authorization': 'Bearer ${_authService.accessToken}'},
        body: {'status': 'ENDED'},
      ).catchError((_) => http.Response('', 500));
    }
    _socketSubscription?.cancel();
    _socketService.disconnect();
    _stopTimer();
    try {
      _controller?.stop();
      _controller?.dispose();
    } catch (e) {
      print("[LiveBroadcaster] Erreur lors du dispose du controleur: $e");
    }
    WakelockPlus.disable(); // Permet à l'écran de se remettre en veille
    super.dispose();
  }
}
