import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';

import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/ui/common/api_constants.dart';

enum SellerStatus { buyer, pending, verified }

class MoiViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();

  bool get isLogged => _authService.isLogged;
  String get userName => _authService.userData?['first_name'] ?? _authService.userData?['username'] ?? 'Utilisateur';
  
  String get userInitials {
    final firstName = _authService.userData?['first_name'] as String? ?? '';
    final lastName = _authService.userData?['last_name'] as String? ?? '';
    
    if (firstName.isEmpty && lastName.isEmpty) return '?';
    
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0].toUpperCase();
    if (lastName.isNotEmpty) initials += lastName[0].toUpperCase();
    
    return initials;
  }

  SellerStatus _sellerStatus = SellerStatus.verified;
  SellerStatus get sellerStatus => _sellerStatus;

  int _publicationsCount = 12; // Example count
  int get publicationsCount => _publicationsCount;

  Future<void> init() async {
    print("👤 [MoiViewModel] Initialisation de l'onglet Profil...");
    print("👤 [MoiViewModel] État isLogged: $isLogged");
    
    if (isLogged) {
      setBusy(true);
      print("👤 [MoiViewModel] Vérification de la session via API...");
      bool success = await _authService.fetchUserProfile();
      
      if (!success && !_authService.isLogged) {
        print("👤 [MoiViewModel] Session expirée détectée.");
      }
      
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  void setSellerStatus(SellerStatus status) {
    _sellerStatus = status;
    notifyListeners();
  }

  void navigateToSettings() {
    _navigationService.navigateToReglagesView();
  }

  void onConnectOrRegister() {
    _navigationService.navigateToLoginView();
  }

  void navigateToSupport() {
    _navigationService.navigateToSupportView();
  }

  void navigateToSellerKyc() {
    _navigationService.navigateToSellerKycView();
  }

  void navigateToSellerDashboard() {
    _navigationService.navigateToSellerDashboardView();
  }

  void navigateToSaved() {
    _navigationService.navigateToSavedView();
  }

  void navigateToAbonnement() {
    _navigationService.navigateToAbonnementView();
  }

  void navigateToHome() {
    _navigationService.clearStackAndShow(Routes.startupView);
  }
}
