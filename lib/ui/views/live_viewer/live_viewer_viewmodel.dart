import 'package:stacked/stacked.dart';
import '../../../../app/app.locator.dart';
import '../../../../services/srs_streaming_service.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';

class LiveViewerViewModel extends BaseViewModel {
  final _srsService = locator<SrsStreamingService>();
  
  Map<int, VideoPlayerController> controllers = {};
  int currentVideoIndex = 0;
  
  final List<String> dummyVideoUrls = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://www.w3schools.com/html/mov_bbb.mp4', // Big Buck Bunny (très stable)
  ];

  final List<String> broadcasterNames = [
    'PromoGo Officiel',
    'Fashion Boutique CI',
    'Tech Gadgets Abidjan'
  ];

  // Simulation de données pour le live
  final String streamKey = "demo_stream";
  final String broadcasterName = "PromoGo Officiel";
  int viewerCount = 1250;
  
  // Chat système
  List<Map<String, String>> chatMessages = [
    {"user": "Alice", "message": "J'adore ce produit !"},
    {"user": "Marc", "message": "Est-ce qu'il y a des réductions ?"},
    {"user": "Sarah", "message": "Wow magnifique !"},
  ];

  // Gestion des coeurs flottants
  List<int> floatingHearts = [];
  int heartCounter = 0;

  void initViewer() async {
    setBusy(true);
    await _initController(0);
    
    // Preload de la deuxième vidéo en arrière-plan
    if (dummyVideoUrls.length > 1) {
      _initController(1);
    }

    // Simulation de l'arrivée de nouveaux messages
    _simulateLiveChat();
    
    setBusy(false);
  }

  void _simulateLiveChat() async {
    final names = ["John", "Katy", "Luigi", "Sofia", "Ahmed"];
    final messages = ["Super stream !", "Je veux l'acheter !", "Bonjour de Paris", "C'est dispo en M ?", "Top !"];
    final random = Random();

    while (true) {
      await Future.delayed(Duration(seconds: random.nextInt(3) + 2));
      if (chatMessages.length > 30) chatMessages.removeAt(0);
      chatMessages.add({
        "user": names[random.nextInt(names.length)],
        "message": messages[random.nextInt(messages.length)],
      });
      notifyListeners();
    }
  }

  Future<void> _initController(int index) async {
    if (index < 0 || index >= dummyVideoUrls.length || controllers.containsKey(index)) return;

    var baseController = VideoPlayerController.networkUrl(Uri.parse(dummyVideoUrls[index]));
    controllers[index] = baseController;
    
    try {
      await baseController.initialize();
      baseController.setLooping(true);
      if (index == currentVideoIndex) {
        baseController.play();
      }
      notifyListeners();
    } catch (e) {
      print("Erreur vidéo: $e");
    }
  }

  void onPageChanged(int index) {
    // Pause previous
    controllers[currentVideoIndex]?.pause();
    
    currentVideoIndex = index;
    
    // Play current
    if (controllers[index] != null && controllers[index]!.value.isInitialized) {
      controllers[index]!.play();
    } else {
      _initController(index);
    }
    
    // Preload next logically
    if (index + 1 < dummyVideoUrls.length && !controllers.containsKey(index + 1)) {
      _initController(index + 1);
    }

    // Libérer la mémoire des vidéos lointaines (TikTok strategy)
    if (controllers.containsKey(index - 2)) {
      controllers[index - 2]?.dispose();
      controllers.remove(index - 2);
    }
    
    notifyListeners();
  }

  void addLike() {
    heartCounter++;
    floatingHearts.add(heartCounter);
    notifyListeners();
    
    // Supprimer le coeur après 2 secondes (fin de l'animation)
    Future.delayed(const Duration(seconds: 2), () {
      if (floatingHearts.isNotEmpty) {
        floatingHearts.removeAt(0);
        notifyListeners();
      }
    });
  }

  void showProductDetails() {
    // Logique pour afficher le BottomSheet du produit
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
