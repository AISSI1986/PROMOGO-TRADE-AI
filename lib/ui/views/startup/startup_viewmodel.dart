import 'package:stacked/stacked.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

import 'package:promogoai/services/local_storage_service.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/services/category_service.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _localStorageService = locator<LocalStorageService>();
  final _authService = locator<AuthService>();
  final _categoryService = locator<CategoryService>();

  // Place anything here that needs to happen before we get into the application
  Future runStartupLogic() async {
    // Initialisation du service d'authentification (chargement des tokens)
    await _authService.init();
    
    // Chargement des catégories en arrière-plan pendant le splash screen
    await _categoryService.loadCategories();

    await Future.delayed(const Duration(seconds: 3));

    if (_localStorageService.hasSeenOnboarding) {
      _navigationService.replaceWithHomeView();
    } else {
      _navigationService.replaceWithLanguageView();
    }
  }
}
