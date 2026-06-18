import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:http/http.dart' as http;
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/services/live_socket_service.dart';
import 'package:promogoai/services/live_streaming_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:video_player/video_player.dart';
import 'package:promogoai/ui/common/setup_snackbar_ui.dart';

class LiveViewerViewModel extends BaseViewModel with WidgetsBindingObserver {
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _authService = locator<AuthService>();
  final _socketService = locator<LiveSocketService>();
  final _streamingService = locator<LiveStreamingService>();

  LiveStreamingService get streamingService => _streamingService;

  int currentVideoIndex = 0;
  String liveId = "";
  bool isStreamPaused = false;
  bool isMuted = false;
  bool isViewingFullScreen = false;
  bool _isDisposed = false;

  Timer? _hubRefreshTimer;

  final TextEditingController chatController = TextEditingController();
  final FocusNode chatFocusNode = FocusNode();
  PageController? pageController;

  bool showEmojiPicker = false;
  bool showStickerPicker = false;

  void toggleEmojiPicker() {
    showEmojiPicker = !showEmojiPicker;
    if (showEmojiPicker) showStickerPicker = false;
    notifyListeners();
  }

  void toggleStickerPicker() {
    showStickerPicker = !showStickerPicker;
    if (showStickerPicker) showEmojiPicker = false;
    notifyListeners();
  }

  Map<String, VideoPlayerController> preloadedVideoControllers = {};
  VideoPlayerController? videoController;

  String getBroadcasterName(int index) {
    if (index >= sessions.length) {
      final dummyIdx = index - sessions.length;
      if (dummyIdx < broadcasterNames.length) return broadcasterNames[dummyIdx];
      return "Vendeur ${dummyIdx + 1}";
    }
    final s = sessions[index];
    if (s['seller_name'] != null && s['seller_name'].toString().isNotEmpty) return s['seller_name'].toString();
    if (s['seller__store_name'] != null && s['seller__store_name'].toString().isNotEmpty) return s['seller__store_name'].toString();
    if (s['title'] != null && s['title'].toString().isNotEmpty) return s['title'].toString();
    return "Vendeur Inconnu";
  }

  String getBroadcasterInitials(int index) {
    final name = getBroadcasterName(index);
    if (name.startsWith("Vendeur")) return "V";
    if (name.contains("Fashion")) return name.split(" ")[0];
    if (name.isNotEmpty) return name[0].toUpperCase();
    return "V";
  }

  final List<String> dummyVideoUrls = [
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

  List<Map<String, dynamic>> floatingHearts = [];
  int heartCounter = 0;
  StreamSubscription<dynamic>? _socketSubscription;

  List<String> videoUrls = [];
  List<Map<String, dynamic>> sessions = [];
  List<Map<String, dynamic>> currentLiveProducts = [];

  Future<void> initViewer({bool initializeVideo = true, bool autoPlay = true}) async {
    setBusy(true);
    await WakelockPlus.enable(); 
    
    _streamingService.initialize();
    _streamingService.setRemoteUserCallback((uid) {
      notifyListeners();
    });

    try {
      WidgetsBinding.instance.addObserver(this);
      final Map<String, String> headers = {};
      if (_authService.accessToken != null) {
        headers['Authorization'] = 'Bearer ${_authService.accessToken}';
      }
      final response = await http.get(
        Uri.parse(ApiConstants.activeLivesEndpoint),
        headers: headers,
      );
      if (_isDisposed) return;
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is List) {
          sessions = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data.containsKey('results')) {
          sessions = List<Map<String, dynamic>>.from(data['results'] as Iterable);
        } else if (data is Map && data.containsKey('data')) {
          sessions = List<Map<String, dynamic>>.from(data['data'] as Iterable);
        }

        sessions.sort((a, b) {
          final statusA = (a['status']?.toString() ?? '').toUpperCase();
          final statusB = (b['status']?.toString() ?? '').toUpperCase();
          if (statusA == 'LIVE' && statusB != 'LIVE') return -1;
          if (statusA != 'LIVE' && statusB == 'LIVE') return 1;
          return 0;
        });
      }
    } catch (e) {
      print("[LiveViewer] Erreur fetch lives: $e");
    }

    videoUrls = [];
    for (var s in sessions) {
      videoUrls.add("");
    }
    videoUrls.addAll(dummyVideoUrls); 

    // Précharger toutes les vidéos (VODs) pour un affichage instantané
    for (var url in dummyVideoUrls) {
      if (!preloadedVideoControllers.containsKey(url)) {
        VideoPlayerController ctrl;
        if (url.startsWith('assets/')) {
          ctrl = VideoPlayerController.asset(url);
        } else {
          ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
        }
        try {
          await ctrl.initialize();
          ctrl.setLooping(true);
          preloadedVideoControllers[url] = ctrl;
        } catch (e) {
          print("[LiveViewer] Erreur pre-chargement vidéo: $e");
        }
      }
    } 

    if (sessions.isNotEmpty) {
      liveId = sessions[0]['id'].toString();
      await _fetchLiveProducts(liveId);
    } else {
      currentLiveProducts = List.from(liveProducts);
    }

    setBusy(false);

    if (initializeVideo) {
      onPageChanged(0);
    }

    if (liveId.isNotEmpty) {
      await _fetchChatHistory(liveId);
      _socketService.connect(liveId);
      _setupSocketListener();
    }
    
    startHubRefreshTimer();
  }

  void startHubRefreshTimer() {
    _hubRefreshTimer?.cancel();
    _hubRefreshTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!isViewingFullScreen && !_isDisposed) {
        refreshActiveLives();
      }
    });
  }

  Future<void> refreshActiveLives() async {
    try {
      final Map<String, String> headers = {};
      if (_authService.accessToken != null) {
        headers['Authorization'] = 'Bearer ${_authService.accessToken}';
      }
      final response = await http.get(
        Uri.parse(ApiConstants.activeLivesEndpoint),
        headers: headers,
      );
      if (_isDisposed) return;
      
      List<Map<String, dynamic>> newSessions = [];
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is List) {
          newSessions = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data.containsKey('results')) {
          newSessions = List<Map<String, dynamic>>.from(data['results'] as Iterable);
        }
        
        newSessions.sort((a, b) {
          final statusA = (a['status']?.toString() ?? '').toUpperCase();
          final statusB = (b['status']?.toString() ?? '').toUpperCase();
          if (statusA == 'LIVE' && statusB != 'LIVE') return -1;
          if (statusA != 'LIVE' && statusB == 'LIVE') return 1;
          return 0;
        });
      }

      bool hasChanged = newSessions.length != sessions.length;
      if (!hasChanged) {
        for (int i = 0; i < sessions.length; i++) {
          if (sessions[i]['id'].toString() != newSessions[i]['id'].toString() ||
              sessions[i]['status'] != newSessions[i]['status']) {
            hasChanged = true;
            break;
          }
        }
      }

      if (hasChanged) {
        final oldIsLive = currentVideoIndex < sessions.length;
        final oldLiveId = oldIsLive ? sessions[currentVideoIndex]['id'].toString() : null;
        final oldUrl = videoUrls.isNotEmpty && currentVideoIndex < videoUrls.length ? videoUrls[currentVideoIndex] : null;

        sessions = newSessions;
        videoUrls = [];
        for (var s in sessions) {
          videoUrls.add("");
        }
        videoUrls.addAll(dummyVideoUrls);
        
        notifyListeners();

        final newIsLive = currentVideoIndex < sessions.length;
        final newLiveId = newIsLive ? sessions[currentVideoIndex]['id'].toString() : null;
        final newUrl = videoUrls.isNotEmpty && currentVideoIndex < videoUrls.length ? videoUrls[currentVideoIndex] : null;

        // Si la vidéo que l'on regarde actuellement change (un nouveau live prend sa place par exemple), on recharge
        if (oldIsLive != newIsLive || oldLiveId != newLiveId || oldUrl != newUrl) {
          onPageChanged(currentVideoIndex);
        }
      }
    } catch (e) {
      print("[LiveViewer] Erreur catch refresh lives: $e");
    }
  }

  void _setupSocketListener() {
    _socketSubscription?.cancel();
    _socketSubscription = _socketService.events.listen((data) {
      if (!_isDisposed) {
        if (data['type'] == 'like') {
          viewerCount++;
          heartCounter++;
          _showLocalHeart(heartCounter);
        } else {
          chatMessages.insert(0, {
            "user": data['user']?.toString() ?? "Utilisateur",
            "message": data['message']?.toString() ?? ""
          });
        }
        notifyListeners();
      }
    });
  }

  String getCurrentUserName() {
    final userData = _authService.userData;
    if (userData != null) {
      return userData['first_name']?.toString().isNotEmpty == true 
          ? userData['first_name'].toString() 
          : (userData['username']?.toString() ?? "Utilisateur");
    }
    return "Utilisateur";
  }

  Future<void> onPageChanged(int index) async {
    if (_isDisposed) return;
    
    currentVideoIndex = index;
    
    videoController?.pause();
    videoController = null;
    
    await _streamingService.leaveChannel();

    if (index < sessions.length) {
      isStreamPaused = false;
      liveId = sessions[index]['id'].toString();
      _socketService.connect(liveId);
      
      String? token;
      try {
        final Map<String, String> headers = {};
        if (_authService.accessToken != null) {
          headers['Authorization'] = 'Bearer ${_authService.accessToken}';
        }
        
        final tokenResponse = await http.get(
          Uri.parse("${ApiConstants.getAgoraTokenEndpoint}?channelName=$liveId&role=audience"),
          headers: headers,
        );
        if (tokenResponse.statusCode == 200) {
          final data = jsonDecode(tokenResponse.body);
          token = data['token'];
        }
      } catch(e) {
        print("Erreur Token Agora Viewer: $e");
      }
      await _streamingService.joinChannelAsViewer(liveId, token: token);
      
      Future.delayed(const Duration(seconds: 1), () {
        _socketService.sendEvent({
          "type": "chat_message",
          "user": "SURA IA",
          "message": "${getCurrentUserName()} a rejoint le live ! 👋"
        });
      });
      
      _fetchChatHistory(liveId);
      _fetchLiveProducts(liveId); 
    } else {
      currentLiveProducts = List.from(liveProducts);
      liveId = ""; 
      
      final url = videoUrls[index];
      videoController = preloadedVideoControllers[url];
      
      // Fallback si non préchargée
      if (videoController == null) {
        if (url.startsWith('assets/')) {
          videoController = VideoPlayerController.asset(url);
        } else {
          videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        }
        await videoController!.initialize();
        videoController!.setLooping(true);
        preloadedVideoControllers[url] = videoController!;
      }
      
      videoController!.play();
    }

    notifyListeners();
  }

  void skipToNextLive() {
    if (currentVideoIndex + 1 < videoUrls.length) {
      if (pageController?.hasClients ?? false) {
        pageController!.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        onPageChanged(currentVideoIndex + 1);
      }
    } else {
      _navigationService.back<dynamic>();
    }
  }

  Future<void> _fetchLiveProducts(String id) async {
    try {
      final session = sessions.firstWhere((s) => s['id'].toString() == id, orElse: () => {});
      if (session.isNotEmpty && session['products'] != null && session['products'] is List && (session['products'] as List).isNotEmpty) {
        currentLiveProducts = List<Map<String, dynamic>>.from(session['products'] as Iterable);
        notifyListeners();
        return;
      }
    } catch (_) {}
 
    try {
      final response = await http.get(Uri.parse("${ApiConstants.liveProductsEndpoint}/$id/"));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          currentLiveProducts = List<Map<String, dynamic>>.from(data as Iterable);
        } else if (data is Map && data.containsKey('results') && (data['results'] as List).isNotEmpty) {
          currentLiveProducts = List<Map<String, dynamic>>.from(data['results'] as Iterable);
        } else if (data is Map && data.containsKey('data') && (data['data'] as List).isNotEmpty) {
          currentLiveProducts = List<Map<String, dynamic>>.from(data['data'] as Iterable);
        } else {
          currentLiveProducts = List.from(liveProducts);
        }
      } else {
        currentLiveProducts = List.from(liveProducts);
      }
    } catch (e) {
      currentLiveProducts = List.from(liveProducts);
    }
    notifyListeners();
  }

  String getCurrentLiveTitle() {
    if (sessions.isNotEmpty && currentVideoIndex < sessions.length) {
      final s = sessions[currentVideoIndex];
      if (s['title'] != null && s['title'].toString().isNotEmpty) {
        return s['title'].toString();
      }
    }
    return getBroadcasterName(currentVideoIndex);
  }

  Future<void> _fetchChatHistory(String id) async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.getLiveChatHistoryEndpoint(id)));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is Map && data['history'] is List) {
          chatMessages = List<Map<String, String>>.from((data['history'] as List).map((e) => {
            "user": e["user"].toString(),
            "message": e["message"].toString()
          }));
          notifyListeners();
        }
      }
    } catch (e) {
      print("[LiveViewer] Erreur fetch chat: $e");
    }
  }

  void sendMessage() {
    final text = chatController.text.trim();
    if (text.isNotEmpty) {
      final userName = getCurrentUserName();
      final msg = {"user": userName, "message": text};
      // Le message local n'est plus inséré manuellement ici pour éviter les doublons avec le retour WebSockets.
      // Il sera affiché quand il sera reçu via _socketService.events.listen.

      if (liveId.isNotEmpty) {
        _socketService.sendEvent({
          "type": "chat_message",
          "user": userName,
          "message": text
        });
      }

      chatController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void addSpecificEmoji(String emoji) {
    chatController.text += emoji;
    notifyListeners();
  }

  void sendSpecificSticker(String icon, String label) {
    final userName = getCurrentUserName();
    final text = "$icon a envoyé un $label !";
    final msg = {"user": userName, "message": text};
    // Pareil pour les cadeaux, pas d'ajout manuel.

    if (liveId.isNotEmpty) {
      _socketService.sendEvent({
        "type": "chat_message",
        "user": userName,
        "message": text
      });
    }
  }

  void confirmOrder({
    required Map<String, dynamic> product,
    required String buyerName,
    required String phone,
    required String location,
  }) {
    final text = "🛍️ Nouvelle commande : ${product['name']} par $buyerName";
    // Pareil pour les commandes.

    if (liveId.isNotEmpty) {
      _socketService.sendEvent({
        "type": "chat_message",
        "user": "SURA IA",
        "message": text
      });
    }
  }

  void addLike() {
    viewerCount++;
    heartCounter++;
    final currentId = heartCounter;
    
    _showLocalHeart(currentId);

    if (liveId.isNotEmpty) {
      _socketService.sendEvent({
        "type": "like",
        "user": getCurrentUserName(),
      });
    }
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

  void _hideLocalHeart(int id) {
    if (!_isDisposed) {
      floatingHearts.remove(id);
      notifyListeners();
    }
  }

  void togglePlayPause() {
    if (currentVideoIndex >= sessions.length) {
      if (videoController != null) {
        if (videoController!.value.isPlaying) {
          videoController!.pause();
          isStreamPaused = true;
        } else {
          videoController!.play();
          isStreamPaused = false;
        }
        notifyListeners();
      }
    }
  }

  void toggleMute() {
    isMuted = !isMuted;
    if (currentVideoIndex >= sessions.length) {
      videoController?.setVolume(isMuted ? 0.0 : 1.0);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;
    _hubRefreshTimer?.cancel();
    _socketSubscription?.cancel();
    _socketService.disconnect();
    chatController.dispose();
    chatFocusNode.dispose();
    pageController?.dispose();
    
    for (var ctrl in preloadedVideoControllers.values) {
      ctrl.dispose();
    }
    preloadedVideoControllers.clear();
    videoController = null;
    _streamingService.dispose();
    
    WakelockPlus.disable();
    super.dispose();
  }
}
