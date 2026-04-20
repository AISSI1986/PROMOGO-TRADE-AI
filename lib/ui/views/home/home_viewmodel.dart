import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/models/product.dart';
import 'package:promogoai/ui/views/product_detail/product_detail_view.dart';
import 'dart:ui';
import 'package:permission_handler/permission_handler.dart';
import 'package:promogoai/ui/views/promogo_fair/promogo_fair_view.dart';
import 'package:promogoai/ui/views/live_viewer/live_viewer_view.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  int _currentTopTab = 1; // 1 = Produits
  int get currentTopTab => _currentTopTab;

  int _currentPromoIndex = 0;
  int get currentPromoIndex => _currentPromoIndex;

  bool _showPromotion = true;
  bool get showPromotion => _showPromotion;

  String _selectedCategory = "Tous";
  String get selectedCategory => _selectedCategory;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Voice recording state
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  // Controls whether the voice recording bottom sheet should be shown
  bool _showVoiceSheet = false;
  bool get showVoiceSheet => _showVoiceSheet;

  void togglePromotion(bool value) {
    _showPromotion = value;
    notifyListeners();
  }

  final PageController promoPageController = PageController(initialPage: 0);
  Timer? _promoTimer;
  final int _promoCount = 4;

  HomeViewModel() {
    _startPromoTimer();
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    promoPageController.dispose();
    super.dispose();
  }

  void _startPromoTimer() {
    _promoTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (promoPageController.hasClients) {
        int nextPage = _currentPromoIndex + 1;
        if (nextPage >= _promoCount) {
          nextPage = 0;
          promoPageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          promoPageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void onPromoPageChanged(int index) {
    _currentPromoIndex = index;
    notifyListeners();
  }

  void setTopTab(int index) {
    _currentTopTab = index;
    notifyListeners();
  }

  void setIndex(int index) {
    // Dès qu'on clique sur 'Home' (index 0), on réinitialise sur 'Produits' (index 1)
    if (index == 0) {
      _currentTopTab = 1;
    }
    _currentIndex = index;
    notifyListeners();
  }

  /// Called when the IA button is tapped.
  /// Requests microphone permission and toggles the voice recording sheet.
  Future<void> onVoiceIAClicked() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _showVoiceSheet = true;
      notifyListeners();
    } else {
      print('Microphone permission denied');
    }
  }

  /// Toggles recording state (called from the voice sheet UI)
  void toggleRecording() {
    _isRecording = !_isRecording;
    notifyListeners();

    if (!_isRecording) {
      // Recording stopped — later, send audio to transformer model
      _processVoiceResult();
    }
  }

  /// Closes the voice sheet
  void closeVoiceSheet() {
    _showVoiceSheet = false;
    _isRecording = false;
    notifyListeners();
  }

  /// Placeholder: process voice result
  /// Later this will send audio data to a transformer model
  void _processVoiceResult() {
    print('Audio enregistré — prêt à envoyer au modèle transformer');
    // TODO: Envoyer l'audio au modèle transformer pour:
    // - Recherche de produit
    // - Navigation (ex: "panier", "profil", etc.)
  }

  void navigateToProductDetail(Product product) {
    _navigationService.navigateWithTransition(
      ProductDetailView(product: product),
      transitionStyle: Transition.fade,
    );
  }

  void navigateToPromogoFair() {
    _navigationService.navigateWithTransition(
      const PromogoFairView(),
      transitionStyle: Transition.rightToLeft,
    );
  }

  void navigateToLiveViewer() {
    _navigationService.navigateWithTransition(
      const LiveViewerView(),
      transitionStyle: Transition.fade,
    );
  }
}
