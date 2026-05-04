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
import 'package:promogoai/ui/views/mon_academie/mon_academie_view.dart';
import 'package:promogoai/ui/views/demande_devis/demande_devis_view.dart';
import 'package:promogoai/ui/views/price_comparator/price_comparator_view.dart';
import 'package:promogoai/app/app.bottomsheets.dart';
import 'package:promogoai/services/ad_service.dart';
import 'package:promogoai/services/ai_voice_service.dart';
import 'package:promogoai/services/translation_service.dart';

class HomeViewModel extends BaseViewModel {
  final _adService = AdService();
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _aiVoiceService = locator<AiVoiceService>();
  final _translationService = locator<TranslationService>();
  
  bool _showAiVoiceBar = false;
  bool get showAiVoiceBar => _showAiVoiceBar;

  void setShowAiVoiceBar(bool value) {
    _showAiVoiceBar = value;
    notifyListeners();
  }

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

  List<Product> get allAds => _adService.ads;
  List<Product> get searchAds => _adService.searchAds;

  String _currentLanguageCode = 'fr';
  String get currentLanguageCode => _currentLanguageCode;

  Future<void> init(String languageCode) async {
    _currentLanguageCode = languageCode;
    setBusy(true);
    await _adService.loadAds();
    await autoTranslateAll(languageCode);
    setBusy(false);
  }

  Future<void> autoTranslateAll(String languageCode) async {
    _currentLanguageCode = languageCode;
    
    print("🌍 [HomeViewModel] Traduction automatique intelligente vers $languageCode...");
    
    // On traduit les titres des produits chargés UNIQUEMENT si la langue est différente
    for (var product in allAds) {
      if (product.originalLanguage != languageCode) {
        product.name = await _translationService.translate(product.name, languageCode);
        product.description = await _translationService.translate(product.description, languageCode);
      }
    }
    
    for (var product in searchAds) {
      if (product.originalLanguage != languageCode) {
        product.name = await _translationService.translate(product.name, languageCode);
        product.description = await _translationService.translate(product.description, languageCode);
      }
    }
    
    notifyListeners();
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
  /// Requests microphone permission and shows the persistent AI Voice bar.
  Future<void> onVoiceIAClicked() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _showAiVoiceBar = !_showAiVoiceBar;
      notifyListeners();
    } else {
      print('Microphone permission denied');
    }
  }

  Future<void> handleAiResult(Map<String, dynamic> data) async {
    print("🎯 [HomeViewModel] handleAiResult déclenché avec data: ${data.keys.toList()}");
    final vector = data['vector'];
    final transcription = data['transcription'] ?? "";
    
    if (vector != null) {
      setBusy(true);
      // On cache la barre après un court délai pour laisser lire la transcription
      Future.delayed(const Duration(milliseconds: 1000), () {
        _showAiVoiceBar = false;
        notifyListeners();
      });

      // On bascule sur l'onglet produits pour voir les résultats de la recherche IA
      _currentTopTab = 1; 
      _selectedCategory = "Tous"; // On réinitialise la catégorie
      
      print("🔍 [HomeViewModel] Recherche IA pour: $transcription");
      await _adService.searchAdsByVector(vector);

      // Traduction automatique des nouveaux résultats
      await autoTranslateAll(_currentLanguageCode);

      setBusy(false);
    }
  }

  void navigateToProductDetail(Product product) {
    _navigationService.navigateWithTransition(
      ProductDetailView(product: product),
      transitionStyle: Transition.fade,
    );
  }

  void navigateToPriceComparator() {
    _navigationService.navigateWithTransition(
      const PriceComparatorView(),
      transitionStyle: Transition.rightToLeft,
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

  void navigateToMonAcademie() {
    _navigationService.navigateWithTransition(
      const MonAcademieView(),
      transitionStyle: Transition.rightToLeft,
    );
  }

  void navigateToDemandeDevis() {
    _navigationService.navigateWithTransition(
      const DemandeDevisView(),
      transitionStyle: Transition.rightToLeft,
    );
  }
}
