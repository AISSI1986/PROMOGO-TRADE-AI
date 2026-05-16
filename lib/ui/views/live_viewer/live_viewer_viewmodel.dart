import 'package:flutter/material.dart';
import 'package:promogoai/services/live_socket_service.dart';
import 'package:stacked/stacked.dart';
import '../../../../app/app.locator.dart';
import '../../../../services/srs_streaming_service.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:promogoai/ui/common/api_constants.dart';
import 'dart:math';
import 'dart:async';

class LiveViewerViewModel extends BaseViewModel {
  final _srsService = locator<SrsStreamingService>();
  final _socketService = locator<LiveSocketService>();
  
  // Pool de contrôleurs (TikTok Strategy)
  Map<int, VideoPlayerController> controllers = {};
  int currentVideoIndex = 0;
  
  // Contrôleur pour le chat
  final TextEditingController chatController = TextEditingController();
  final FocusNode chatFocusNode = FocusNode();

  // Simulation ID du Live
  String liveId = "live_test_123";

  bool isControllerInitialized(int index) {
    return controllers.containsKey(index) && controllers[index]!.value.isInitialized;
  }

  VideoPlayerController? getController(int index) {
    return controllers[index];
  }
  
  String getBroadcasterName(int index) {
    if (index < sessions.length) {
      final s = sessions[index];
      if (s['seller_name'] != null && s['seller_name'].toString().isNotEmpty) {
        return s['seller_name'].toString();
      }
      if (s['seller'] != null) {
        if (s['seller'] is Map && s['seller']['username'] != null) {
          return s['seller']['username'].toString();
        }
        return s['seller'].toString();
      }
      if (s['title'] != null && s['title'].toString().isNotEmpty) {
        return s['title'].toString();
      }
      return "Vendeur #${s['id']}";
    }
    return broadcasterNames[index % broadcasterNames.length];
  }

  final List<String> dummyVideoUrls = [
    'assets/video/live1.mp4',
    'assets/video/live2.mp4',
    'assets/video/live1.mp4',
    'assets/video/live2.mp4',
  ];

  final List<String> broadcasterNames = [
    'PromoGo Officiel',
    'Fashion Boutique CI',
    'Vendeur Pro Africa',
    'Boutique Solaire',
  ];

  final List<Map<String, dynamic>> liveProducts = [
    {
      "id": "p1",
      "name": "Veste Blazer Multicolore",
      "price": "450 GHS",
      "image": "assets/images/logo_app.png", 
      "isHot": true,
    },
  ];

  Map<String, dynamic>? _pinnedProduct;
  Map<String, dynamic>? get pinnedProduct => _pinnedProduct;

  void setPinnedProduct(Map<String, dynamic>? product) {
    _pinnedProduct = product;
    notifyListeners();
  }

  int viewerCount = 1250;
  List<Map<String, String>> chatMessages = [
    {"user": "SURA IA", "message": "Bienvenue sur le live !"},
  ];

  List<int> floatingHearts = [];
  int heartCounter = 0;
  StreamSubscription? _socketSubscription;

  List<String> videoUrls = [];
  List<Map<String, dynamic>> sessions = [];

  Future<void> initViewer({bool initializeVideo = true, bool autoPlay = true}) async {
    setBusy(true);
    
    try {
      // 1. Récupérer les lives actifs depuis le backend
      final response = await http.get(Uri.parse(ApiConstants.activeLivesEndpoint));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is List) {
          sessions = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data.containsKey('results')) {
          sessions = List<Map<String, dynamic>>.from(data['results']);
        } else if (data is Map && data.containsKey('data')) {
          sessions = List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      print("❌ [LiveViewer] Erreur fetch lives: $e");
    }

    // 2. Construire la liste (On bascule sur HLS .m3u8 qui est 100% natif sur mobile Android/iOS)
    videoUrls = [];
    for (var s in sessions) {
      videoUrls.add(_srsService.getHlsPlayUrl(s['id'].toString()));
    }
    videoUrls.addAll(dummyVideoUrls); // On ajoute les démos après

    if (sessions.isNotEmpty) {
      liveId = sessions[0]['id'].toString();
      _fetchLiveProducts(liveId); // Charger les produits du 1er live
    } else {
      currentLiveProducts = List.from(liveProducts); // Produits démo par défaut
    }

    // 3. Initialisation prioritaire de la première vidéo (Live ou Replay)
    if (initializeVideo && videoUrls.isNotEmpty) {
      await _initController(0, autoPlay: autoPlay);
      setBusy(false);
      
      if (videoUrls.length > 1) {
        Future.delayed(const Duration(milliseconds: 500), () => _initController(1, autoPlay: false));
      }
    } else {
      setBusy(false);
    }

    // 4. CONNEXION RÉELLE WEBSOCKET
    if (liveId.isNotEmpty) {
      _socketService.connect(liveId);
      
      _socketSubscription = _socketService.events.listen((event) {
        final type = event['type'];
        if (type == 'chat_message') {
          chatMessages.add({
            "user": event['user'] ?? "Anonyme",
            "message": event['message'],
          });
          notifyListeners();
        } else if (type == 'pin_product') {
          _pinnedProduct = event['product'];
          notifyListeners();
        } else if (type == 'like_event') {
          addLike(remote: true);
        }
      });
    }
  }

  Future<void> _initController(int index, {bool autoPlay = true}) async {
    if (index < 0 || index >= videoUrls.length) return;
    if (controllers.containsKey(index)) {
      if (controllers[index]!.value.isInitialized) {
        if (index == currentVideoIndex && autoPlay) {
          await controllers[index]!.play();
        }
        return;
      }
    }
    
    final String url = videoUrls[index];
    VideoPlayerController controller;

    try {
      if (url.startsWith('assets/')) {
        controller = VideoPlayerController.asset(url);
      } else {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      }

      controllers[index] = controller;
      
      final timeoutDuration = url.startsWith('assets/') ? const Duration(seconds: 10) : const Duration(seconds: 10);
      
      await controller.initialize().timeout(timeoutDuration);
      controller.setLooping(true);
      controller.setVolume(1.0);
      
      if (index == currentVideoIndex && autoPlay) {
        await controller.play();
      }
      print("✅ [LiveViewer] Vidéo $index prête (autoPlay: $autoPlay) ($url)");
    } catch (e) {
      print("⚠️ [LiveViewer] Échec ou timeout vidéo $index ($url): $e");
      controllers[index]?.dispose();
      controllers.remove(index);

      // --- STRATÉGIE D'AUTO-GUÉRISON (SELF-HEALING) ---
      // Si c'est un flux réseau (vrai Live fantôme sans activité SRS) qui a échoué,
      // on remplace immédiatement l'URL par un Replay de secours pour ne JAMAIS bloquer l'acheteur !
      if (!url.startsWith('assets/')) {
        print("🔄 [LiveViewer] Bascule automatique du Live fantôme $index vers un Replay de secours...");
        videoUrls[index] = dummyVideoUrls[index % dummyVideoUrls.length];
        _initController(index, autoPlay: autoPlay);
      }
    } finally {
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> currentLiveProducts = [];

  Future<void> _fetchLiveProducts(String id) async {
    // 1. Vérifier si la session contient déjà la liste des produits préchargés par Django
    try {
      final session = sessions.firstWhere((s) => s['id'].toString() == id, orElse: () => {});
      if (session.isNotEmpty && session['products'] != null && session['products'] is List && (session['products'] as List).isNotEmpty) {
        currentLiveProducts = List<Map<String, dynamic>>.from(session['products']);
        notifyListeners();
        return;
      }
    } catch (_) {}

    // 2. Sinon, tenter l'appel HTTP dédié
    try {
      final response = await http.get(Uri.parse("${ApiConstants.liveProductsEndpoint}/$id/"));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          currentLiveProducts = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data.containsKey('results') && (data['results'] as List).isNotEmpty) {
          currentLiveProducts = List<Map<String, dynamic>>.from(data['results']);
        } else if (data is Map && data.containsKey('data') && (data['data'] as List).isNotEmpty) {
          currentLiveProducts = List<Map<String, dynamic>>.from(data['data']);
        } else {
          currentLiveProducts = List.from(liveProducts);
        }
      } else {
        currentLiveProducts = List.from(liveProducts);
      }
    } catch (e) {
      print("❌ [LiveViewer] Erreur fetch produits live: $e");
      currentLiveProducts = List.from(liveProducts);
    }
    notifyListeners();
  }

  void onPageChanged(int index) async {
    // 1. Pause la vidéo précédente
    controllers[currentVideoIndex]?.pause();
    
    currentVideoIndex = index;
    
    // 2. Logique de connexion (Live vs Replay)
    if (index < sessions.length) {
      liveId = sessions[index]['id'].toString();
      _fetchLiveProducts(liveId);
      _socketService.connect(liveId); 
    } else {
      currentLiveProducts = List.from(liveProducts);
    }

    // 3. Lancer la lecture de la nouvelle vidéo de manière robuste
    if (controllers[index] != null && controllers[index]!.value.isInitialized) {
      await controllers[index]!.play();
    } else {
      await _initController(index, autoPlay: true);
    }

    _managePool(index);
    notifyListeners();
  }

  void _managePool(int index) {
    // Précharger la vidéo suivante EN PAUSE (autoPlay: false) pour ne pas voler le focus audio/vidéo
    if (index + 1 < videoUrls.length) {
      _initController(index + 1, autoPlay: false);
    }
    final keysToRemove = controllers.keys.where((k) => k != index && k != index + 1).toList();
    for (var key in keysToRemove) {
      controllers[key]?.dispose();
      controllers.remove(key);
    }
  }

  bool _isDisposed = false;

  void sendMessage() {
    final text = chatController.text.trim();
    if (text.isEmpty) return;
    
    final payload = {
      "type": "chat_message",
      "user": "Moi", 
      "message": text,
    };

    _socketService.sendEvent(payload);
    
    chatMessages.add({
      "user": "Moi",
      "message": text,
    });
    
    chatController.clear();
    notifyListeners();
  }

  bool _showEmojiPicker = false;
  bool get showEmojiPicker => _showEmojiPicker;

  bool _showStickerPicker = false;
  bool get showStickerPicker => _showStickerPicker;

  void toggleEmojiPicker() {
    _showEmojiPicker = !_showEmojiPicker;
    _showStickerPicker = false;
    notifyListeners();
  }

  void toggleStickerPicker() {
    _showStickerPicker = !_showStickerPicker;
    _showEmojiPicker = false;
    notifyListeners();
  }

  void addSpecificEmoji(String emoji) {
    final currentText = chatController.text;
    chatController.text = "$currentText$emoji";
    chatController.selection = TextSelection.fromPosition(TextPosition(offset: chatController.text.length));
    notifyListeners();
  }

  void addMention() {
    final currentText = chatController.text;
    chatController.text = "$currentText@";
    chatController.selection = TextSelection.fromPosition(TextPosition(offset: chatController.text.length));
    notifyListeners();
  }

  void confirmOrder({
    required Map<String, dynamic> product,
    required String buyerName,
    required String phone,
    required String location,
  }) {
    final orderPayload = {
      "type": "order_request",
      "product_id": product['id'],
      "product_name": product['name'],
      "buyer_name": buyerName,
      "buyer_phone": phone,
      "buyer_location": location,
    };

    _socketService.sendEvent(orderPayload);

    chatMessages.add({
      "user": "SYSTEME",
      "message": "FÉLICITATIONS à $buyerName qui vient de commander ${product['name']}",
    });

    notifyListeners();
  }

  void sendSpecificSticker(String icon, String label) {
    final payload = {
      "type": "chat_message",
      "user": "Moi",
      "message": "$icon a envoyé un $label !",
    };
    _socketService.sendEvent(payload);
    
    chatMessages.add(payload);
    notifyListeners();
  }

  void addLike({bool remote = false}) {
    if (!remote) {
      _socketService.sendEvent({"type": "like_event"});
    }

    heartCounter++;
    floatingHearts.add(heartCounter);
    notifyListeners();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isDisposed) {
        if (floatingHearts.isNotEmpty) {
          floatingHearts.removeAt(0);
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _socketSubscription?.cancel();
    _socketService.disconnect();
    chatController.dispose();
    chatFocusNode.dispose();
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
