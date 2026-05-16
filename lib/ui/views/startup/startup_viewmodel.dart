import 'package:stacked/stacked.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

import 'package:promogoai/services/local_storage_service.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/services/category_service.dart';
import 'package:promogoai/services/subscription_service.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _localStorageService = locator<LocalStorageService>();
  final _authService = locator<AuthService>();
  final _categoryService = locator<CategoryService>();
  final _subscriptionService = locator<SubscriptionService>();

  // Place anything here that needs to happen before we get into the application
  Future runStartupLogic() async {
    print("🚀 [Startup] Démarrage de la logique initiale...");
    
    // 1. Initialisation du service d'authentification (chargement des tokens)
    await _authService.init();
    
    // 2. Vérification proactive de la session si un token existe
    if (_authService.isLogged) {
      print("🔑 [Startup] Session détectée, vérification de la validité...");
      // fetchUserProfile gère déjà le refresh auto sur 401
      // et le logout() total si le refresh échoue.
      final bool sessionValid = await _authService.fetchUserProfile();
      if (!sessionValid) {
        print("⚠️ [Startup] Session expirée ou invalide. Nettoyage effectué.");
      } else {
        print("✅ [Startup] Session valide pour: ${_authService.userData?['username']}");
      }
    } else {
      print("👤 [Startup] Aucune session active (Mode invité).");
    }

    // 3. Chargement des données en arrière-plan pendant le splash screen
    try {
      print("📂 [Startup] Chargement des catégories...");
      await _categoryService.loadCategories();
    } catch (e) {
      print("⚠️ [Startup] Erreur catégories : $e");
    }

    try {
      print("💎 [Startup] Chargement des abonnements...");
      await _subscriptionService.fetchPlans();
    } catch (e) {
      print("⚠️ [Startup] Erreur abonnements : $e");
    }

    await Future.delayed(const Duration(seconds: 1));

    if (_localStorageService.hasSeenOnboarding) {
      _navigationService.replaceWithHomeView();
    } else {
      _navigationService.replaceWithLanguageView();
    }
  }
}
