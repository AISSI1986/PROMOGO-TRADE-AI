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
import 'package:promogoai/ui/views/live_viewer/live_hub_view.dart';
import 'package:promogoai/ui/views/mon_academie/mon_academie_view.dart';
import 'package:promogoai/ui/views/demande_devis/demande_devis_view.dart';
import 'package:promogoai/ui/views/price_comparator/price_comparator_view.dart';
import 'package:promogoai/app/app.bottomsheets.dart';
import 'package:promogoai/services/ad_service.dart';
import 'package:promogoai/services/ai_voice_service.dart';
import 'package:promogoai/services/translation_service.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/app/app.router.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeViewModel extends BaseViewModel {
  final _adService = AdService();
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _aiVoiceService = locator<AiVoiceService>();
  final _translationService = locator<TranslationService>();
  final _authService = locator<AuthService>();
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _hasError = false;
  bool get hasError => _hasError;

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
  final ScrollController productsScrollController = ScrollController();
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
    if (_isInitialized && !_hasError) return;
    
    _isInitialized = true;
    _hasError = false;
    _currentLanguageCode = languageCode;
    
    // 1. Charger d'abord le cache pour un affichage immédiat
    await _adService.loadCachedAds();
    if (allAds.isNotEmpty) {
      notifyListeners();
    }

    // 2. Ne mettre l'état "busy" (shimmer) que si on n'a absolument rien à afficher
    if (allAds.isEmpty) {
      setBusy(true);
    }

    try {
      // 3. Charger les données fraîches depuis le réseau
      await _adService.loadAds();
      
      // Si après chargement c'est toujours vide et qu'on n'est pas en cache
      if (allAds.isEmpty) {
        _hasError = true;
      }
    } catch (e) {
      _hasError = true;
      print("❌ [HomeViewModel] Error during init: $e");
    } finally {
      setBusy(false);
      notifyListeners();
    }
    
    // 4. Traduire si nécessaire (en arrière-plan par rapport à l'affichage)
    if (allAds.isNotEmpty) {
      await autoTranslateAll(languageCode);
    }
  }

  Future<void> retry(String languageCode) async {
    _hasError = false;
    _isInitialized = false;
    await init(languageCode);
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
    productsScrollController.dispose();
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
    // Si l'utilisateur clique sur "Vendre" (index 2)
    if (index == 2) {
      if (!_authService.isLogged) {
        _showAuthRequiredModal();
        return; // On ne change pas d'index
      }
    }

    // Dès qu'on clique sur 'Home' (index 0), on réinitialise sur 'Produits' (index 1)
    if (index == 0) {
      _currentTopTab = 1;
    }
    _currentIndex = index;
    notifyListeners();
  }

  void _showAuthRequiredModal() {
    _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.authRequired,
      title: 'auth_modal.title'.tr(),
      description: 'auth_modal.message'.tr(),
      mainButtonTitle: 'auth_modal.btn_login'.tr(),
      secondaryButtonTitle: 'auth_modal.btn_cancel'.tr(),
    ).then((sheetResponse) {
      if (sheetResponse != null && sheetResponse.confirmed) {
        // Navigation directe vers la page de Login
        _navigationService.navigateToLoginView();
      }
    });
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
    final transcription = (data['transcription'] ?? "").toString().toLowerCase();
    
    // --- NOUVEAU : Détection d'intention de navigation par la voix ---
    final sellKeywords = [
      'vendre', 'vente', 'vends', 'sell', 'sale', 'selling', 
      'sayar', 'sayarwa', 'sayda', // Haoussa
      'dzra', 'dzradzra', 'djra', 'dra', 'zra', 'dza',  // Ewe (avec variantes phonétiques de l'IA)
      'sanou', 'ndja sanou', 'pley nou', 'ple nou', 'dzanou', 'asanou' // Mina / Parlé local
    ];
    bool intentToSell = sellKeywords.any((kw) => transcription.contains(kw));

    if (intentToSell) {
      print("🚀 [HomeViewModel] Intention de vente détectée ! Navigation vers l'onglet Vendre.");
      _showAiVoiceBar = false;
      setIndex(2); // Index 2 est la page "Vendre"
      notifyListeners();
      return;
    }

    // --- Suite de la logique existante pour la recherche de produits ---
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
      _currentIndex = 0; // On s'assure d'être sur la home
      
      print("🔍 [HomeViewModel] Recherche IA pour: $transcription");
      await _adService.searchAdsByVector(vector);

      // Remontée automatique et élégante vers le haut de la page pour voir les résultats
      if (productsScrollController.hasClients) {
        productsScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }

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
      const LiveHubView(),
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
