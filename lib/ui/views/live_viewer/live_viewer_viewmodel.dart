import 'package:flutter/material.dart';
import 'package:promogoai/services/live_socket_service.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:stacked/stacked.dart';
import '../../../../app/app.locator.dart';
import '../../../../services/srs_streaming_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:promogoai/ui/common/api_constants.dart';
import 'dart:async';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/ui/common/setup_snackbar_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LivePlayerData {
  final Player player;
  final VideoController videoController;
  bool isInitialized = false;

  LivePlayerData({required this.player, required this.videoController});
  
  void dispose() {
    player.dispose();
  }
}

class LiveViewerViewModel extends BaseViewModel {
  final _srsService = locator<SrsStreamingService>();
  final _socketService = locator<LiveSocketService>();
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  
  // Pool de contrôleurs (TikTok Strategy)
  Map<int, LivePlayerData> controllers = {};
  int currentVideoIndex = 0;
  PageController? pageController;
  Set<int> failedVideoIndices = {};
  bool isViewingFullScreen = false;
  Timer? _hubRefreshTimer;
  
  // Contrôleur pour le chat
  final TextEditingController chatController = TextEditingController();
  final FocusNode chatFocusNode = FocusNode();

  // ID du Live
  String liveId = "";

  bool isControllerInitialized(int index) {
    return controllers.containsKey(index) && controllers[index]!.isInitialized;
  }

  VideoController? getVideoController(int index) {
    if (_isDisposed) return null;
    return controllers[index]?.videoController;
  }
  
  Player? getPlayer(int index) {
    if (_isDisposed) return null;
    return controllers[index]?.player;
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
  StreamSubscription<dynamic>? _socketSubscription;

  List<String> videoUrls = [];
  List<Map<String, dynamic>> sessions = [];

  Future<void> initViewer({bool initializeVideo = true, bool autoPlay = true}) async {
    setBusy(true);
    failedVideoIndices.clear();
    await WakelockPlus.enable(); // Garde l'écran allumé pendant le visionnage du Live !
    
    try {
      // 1. Récupérer les lives actifs depuis le backend
      final response = await http.get(Uri.parse(ApiConstants.activeLivesEndpoint));
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

        // Tri : Les sessions avec le statut "LIVE" sont placées en première position
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

    // 2. Construire la liste (Utilise HTTP-FLV pour le vrai temps réel avec media_kit)
    videoUrls = [];
    for (var s in sessions) {
      videoUrls.add(_srsService.getHttpFlvPlayUrl(s['id'].toString()));
    }
    videoUrls.addAll(dummyVideoUrls); // On ajoute les démos après

    if (sessions.isNotEmpty) {
      liveId = sessions[0]['id'].toString();
      await _fetchLiveProducts(liveId); // Charger les produits du 1er live
    } else {
      currentLiveProducts = List.from(liveProducts); // Produits démo par défaut
    }

    // 3. Initialisation de toutes les vidéos pour générer les frames de prévisualisation
    if (initializeVideo && videoUrls.isNotEmpty) {
      setBusy(false);
      for (int i = 0; i < videoUrls.length; i++) {
        // On initialise en différé pour ne pas bloquer l'UI
        Future.delayed(Duration(milliseconds: 300 * i), () async {
          await _initController(i, autoPlay: i == currentVideoIndex && autoPlay);
        });
      }
    } else {
      setBusy(false);
    }

    // 4. CONNEXION RÉELLE WEBSOCKET
    if (liveId.isNotEmpty) {
      await _fetchChatHistory(liveId);
      _socketService.connect(liveId);
      
      _socketSubscription = _socketService.events.listen((event) {
        final type = event['type'];
        if (type == 'chat_message') {
          chatMessages.add({
            "user": (event['user'] ?? "Anonyme").toString(),
            "message": event['message']?.toString() ?? "",
          });
          notifyListeners();
        } else if (type == 'pin_product') {
          _pinnedProduct = event['product'] as Map<String, dynamic>?;
          notifyListeners();
        } else if (type == 'unpin_product') {
          final prodId = event['product_id']?.toString();
          if (_pinnedProduct != null && _pinnedProduct!['id']?.toString() == prodId) {
            _pinnedProduct = null;
            notifyListeners();
          }
        } else if (type == 'unpin_all_products') {
          _pinnedProduct = null;
          notifyListeners();
        } else if (type == 'like_event') {
          addLike(remote: true);
        } else if (type == 'live_ended' || (type == 'live_status' && event['status'] == 'ended')) {
          if (event['reason'] == 'socket_closed') {
            print("⚠️ [LiveViewer] WebSocket déconnecté définitivement, mais conservation du flux vidéo.");
            _snackbarService.showCustomSnackBar(
              variant: SnackbarType.warning,
              message: "Connexion au chat interrompue.",
            );
          } else {
            handleLiveEnded(currentVideoIndex);
          }
        }
      });
    }
    
    // 5. Démarrer le rafraîchissement périodique du hub
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
      final response = await http.get(Uri.parse(ApiConstants.activeLivesEndpoint));
      if (_isDisposed) return;
      
      List<Map<String, dynamic>> newSessions = [];
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is List) {
          newSessions = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data.containsKey('results')) {
          newSessions = List<Map<String, dynamic>>.from(data['results'] as Iterable);
        } else if (data is Map && data.containsKey('data')) {
          newSessions = List<Map<String, dynamic>>.from(data['data'] as Iterable);
        }

        // Tri : Les sessions avec le statut "LIVE" sont placées en première position
        newSessions.sort((a, b) {
          final statusA = (a['status']?.toString() ?? '').toUpperCase();
          final statusB = (b['status']?.toString() ?? '').toUpperCase();
          if (statusA == 'LIVE' && statusB != 'LIVE') return -1;
          if (statusA != 'LIVE' && statusB == 'LIVE') return 1;
          return 0;
        });
      }

      // Comparer et mettre à jour seulement si la liste a changé
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
        print("🔄 [LiveViewer] Liste des lives mise à jour périodiquement (Trié)");
        sessions = newSessions;
        
        // Recréer la liste des urls
        videoUrls = [];
        for (var s in sessions) {
          videoUrls.add(_srsService.getHttpFlvPlayUrl(s['id'].toString()));
        }
        videoUrls.addAll(dummyVideoUrls);

        // Nettoyer les anciens contrôleurs et réinitialiser la première vidéo si nécessaire
        for (var key in controllers.keys.toList()) {
          // Ne pas toucher à la vidéo actuellement en cours de lecture
          if (key != currentVideoIndex) {
            controllers[key]?.dispose();
            controllers.remove(key);
          }
        }
        failedVideoIndices.clear();

        // Réinitialiser le Hero en silencieux
        if (videoUrls.isNotEmpty && !controllers.containsKey(0)) {
          await _initController(0, autoPlay: false);
        }
        notifyListeners();
      }
    } catch (e) {
      print("[LiveViewer] Erreur refresh active lives: $e");
    }
  }

  Future<void> startVideo({bool autoPlay = true}) async {
    if (videoUrls.isNotEmpty && !_isDisposed) {
      await _initController(currentVideoIndex, autoPlay: autoPlay);
      if (videoUrls.length > 1 && currentVideoIndex + 1 < videoUrls.length) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!_isDisposed) _initController(currentVideoIndex + 1, autoPlay: false);
        });
      }
    }
  }

  Future<void> _initController(int index, {bool autoPlay = true, int retryCount = 0}) async {
    if (_isDisposed) return;
    if (index >= videoUrls.length) return;

    // Éviter de réinitialiser si déjà prêt
    if (controllers.containsKey(index)) {
      if (controllers[index]!.isInitialized) {
        if (index == currentVideoIndex && autoPlay) {
          await controllers[index]!.player.play();
        }
        return;
      }
    }
    
    final String url = videoUrls[index];
    
    try {
      final player = Player();
      final videoController = VideoController(player);
      
      controllers[index] = LivePlayerData(player: player, videoController: videoController);
      
      // Configuration FLV / Live
      if (url.startsWith('assets/')) {
        player.setPlaylistMode(PlaylistMode.loop);
      } else {
        player.setPlaylistMode(PlaylistMode.none);
        // Configuration media_kit pour un flux en direct très basse latence
        try {
          if (player.platform is NativePlayer) {
            final nativePlayer = player.platform as NativePlayer;
            await nativePlayer.setProperty('profile', 'low-latency');
            await nativePlayer.setProperty('cache', 'no');
            await nativePlayer.setProperty('cache-pause', 'no');
            await nativePlayer.setProperty('demuxer-lavf-o', 'fflags=+nobuffer');
            await nativePlayer.setProperty('demuxer-lavf-analyzeduration', '0.1');
            await nativePlayer.setProperty('demuxer-lavf-probe-info', 'nostreams');
            await nativePlayer.setProperty('stream-buffer-size', '4096');
            await nativePlayer.setProperty('video-sync', 'audio');
            await nativePlayer.setProperty('video-latency-hacks', 'yes');
            await nativePlayer.setProperty('demuxer-max-bytes', '500000');
            await nativePlayer.setProperty('demuxer-max-back-bytes', '0');
            await nativePlayer.setProperty('vd-lavc-fast', 'yes');
            await nativePlayer.setProperty('framedrop', 'vo');
            print("[LiveViewer] Propriétés MPV ultra low-latency appliquées");
          }
        } catch (e) {
          print("[LiveViewer] Erreur configuration low-latency: $e");
        }
      }
      
      final String openUrl = url.startsWith('assets/') ? 'asset:///$url' : url;
      await player.open(Media(openUrl), play: autoPlay && index == currentVideoIndex);
      await player.setVolume(100.0);
      
      controllers[index]!.isInitialized = true;
      failedVideoIndices.remove(index);
      
      // Écoute des erreurs de flux
      player.stream.error.listen((event) {
        if (_isDisposed) return;
        print("❌ [LiveViewer] Erreur media_kit ($url): $event");
        if (index == currentVideoIndex && !failedVideoIndices.contains(index)) {
          failedVideoIndices.add(index);
          controllers[index]?.dispose();
          controllers.remove(index);
          notifyListeners();
          
          Future.delayed(const Duration(seconds: 3), () {
            if (!_isDisposed && index == currentVideoIndex) {
              _initController(index, autoPlay: true);
            }
          });
        }
      });
      
      print("[LiveViewer] Vidéo $index prête (autoPlay: $autoPlay) ($url)");
    } catch (e) {
      if (_isDisposed) return;
      print("[LiveViewer] Échec ou timeout vidéo $index ($url) (Essai $retryCount/4): $e");
      controllers[index]?.dispose();
      controllers.remove(index);
      failedVideoIndices.add(index);

      if (!url.startsWith('assets/')) {
        if (retryCount < 4 && !_isDisposed) {
          print("🔄 [LiveViewer] Flux non prêt. Nouvelle tentative dans 3 secondes ($retryCount/4)...");
          await Future<void>.delayed(const Duration(seconds: 3));
          if (!_isDisposed) {
            return _initController(index, autoPlay: autoPlay, retryCount: retryCount + 1);
          }
        } else {
          if (index == currentVideoIndex && pageController != null) {
            handleLiveEnded(index);
          }
        }
      }
    } finally {
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  void handleLiveEnded(int index) {
    if (_isDisposed) return;
    
    print("🔴 [LiveViewer] Le Live $index est terminé ou interrompu.");
    
    // 1. Informer le client
    _snackbarService.showCustomSnackBar(
      variant: SnackbarType.warning,
      message: "🔴 Le Live est terminé ou a été interrompu par le vendeur.",
    );

    // 2. Supprimer dynamiquement la session terminée de nos listes locales pour éviter les lives fantômes
    if (index >= 0 && index < sessions.length) {
      sessions.removeAt(index);
      if (index < videoUrls.length) {
        videoUrls.removeAt(index);
      }
      
      // Nettoyer et libérer le lecteur de ce live
      controllers[index]?.player.dispose();
      controllers.remove(index);
      
      // Réorganiser les index des contrôleurs restants dans le pool
      final updatedControllers = <int, LivePlayerData>{};
      for (var entry in controllers.entries) {
        if (entry.key > index) {
          updatedControllers[entry.key - 1] = entry.value;
        } else {
          updatedControllers[entry.key] = entry.value;
        }
      }
      controllers = updatedControllers;

      // Réorganiser les index des erreurs restantes dans le pool
      final updatedFailed = <int>{};
      for (var idx in failedVideoIndices) {
        if (idx > index) {
          updatedFailed.add(idx - 1);
        } else if (idx < index) {
          updatedFailed.add(idx);
        }
      }
      failedVideoIndices = updatedFailed;

      // Si le PageController est actif, on glisse le live suivant qui prend sa place
      if (pageController != null && pageController!.hasClients) {
        notifyListeners();
        
        if (sessions.isEmpty) {
          // Plus aucun live disponible
          print("🚪 [LiveViewer] Plus aucun Live disponible. Retour au Hub.");
          _navigationService.back<dynamic>();
        } else {
          // Relancer la lecture du live qui glisse à la position actuelle
          onPageChanged(currentVideoIndex);
        }
        return;
      }
    }

    // Comportement de secours (fallback)
    if (index + 1 < videoUrls.length) {
      if (pageController?.hasClients ?? false) {
        pageController!.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        onPageChanged(index + 1);
      }
    } else {
      _navigationService.back<dynamic>();
    }
  }

  List<Map<String, dynamic>> currentLiveProducts = [];

  Future<void> _fetchLiveProducts(String id) async {
    // 1. Vérifier si la session contient déjà la liste des produits préchargés par Django
    try {
      final session = sessions.firstWhere((s) => s['id'].toString() == id, orElse: () => {});
      if (session.isNotEmpty && session['products'] != null && session['products'] is List && (session['products'] as List).isNotEmpty) {
        currentLiveProducts = List<Map<String, dynamic>>.from(session['products'] as Iterable);
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
      print("[LiveViewer] Erreur fetch produits live: $e");
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
    return "Live Officiel";
  }

  String getCurrentUserName() {
    if (_authService.userData != null) {
      final user = _authService.userData!;
      if (user['username'] != null && user['username'].toString().isNotEmpty) {
        return user['username'].toString();
      }
      if (user['first_name'] != null && user['first_name'].toString().isNotEmpty) {
        return user['first_name'].toString();
      }
    }
    return getCurrentLiveTitle();
  }

  Future<void> _fetchChatHistory(String id) async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.getLiveChatHistoryEndpoint(id)));
      final liveTitle = getCurrentLiveTitle();
      
      List<Map<String, String>> history = [
        {"user": "SURA IA", "message": "Bienvenue dans le live $liveTitle !"},
      ];

      if (response.statusCode == 200) {
        final dynamic data = json.decode(utf8.decode(response.bodyBytes));
        if (data is List) {
          final lastMessages = data.length > 10 ? data.sublist(data.length - 10) : data;
          for (var m in lastMessages) {
            history.add({
              "user": m['user']?.toString() ?? "Anonyme",
              "message": m['message']?.toString() ?? "",
            });
          }
        }
      }
      chatMessages = history;
      notifyListeners();
    } catch (e) {
      print("❌ [LiveViewer] Erreur fetch chat history: $e");
      final liveTitle = getCurrentLiveTitle();
      chatMessages = [
        {"user": "SURA IA", "message": "Bienvenue dans le live $liveTitle !"},
      ];
      notifyListeners();
    }
  }

  void onPageChanged(int index) async {
    // 1. Pause la vidéo précédente
    await controllers[currentVideoIndex]?.player.pause();
    
    currentVideoIndex = index;
    
    // 2. Logique de connexion (Live vs Replay)
    if (index < sessions.length) {
      liveId = sessions[index]['id'].toString();
      await _fetchLiveProducts(liveId);
      await _fetchChatHistory(liveId);
      _socketService.connect(liveId); 
    } else {
      currentLiveProducts = List.from(liveProducts);
    }

    // 3. Lancer la lecture de la nouvelle vidéo de manière robuste
    if (controllers[index] != null && controllers[index]!.isInitialized) {
      await controllers[index]!.player.play();
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

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  void setBusy(bool value) {
    if (_isDisposed) return;
    super.setBusy(value);
  }

  void sendMessage() {
    final text = chatController.text.trim();
    if (text.isEmpty) return;
    
    final userName = getCurrentUserName();
    
    final payload = {
      "type": "chat_message",
      "user": userName, 
      "message": text,
    };

    _socketService.sendEvent(payload);
    
    chatMessages.add({
      "user": userName,
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
    _hubRefreshTimer?.cancel();
    _socketSubscription?.cancel();
    _socketService.disconnect();
    chatController.dispose();
    chatFocusNode.dispose();
    pageController?.dispose();
    for (var controller in controllers.values) {
      controller.dispose();
    }
    WakelockPlus.disable(); // Remet l'écran en veille normale
    super.dispose();
  }
}
