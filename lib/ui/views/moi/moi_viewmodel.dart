import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';

enum SellerStatus { buyer, pending, verified }

class MoiViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  SellerStatus _sellerStatus = SellerStatus.verified;
  SellerStatus get sellerStatus => _sellerStatus;

  int _publicationsCount = 12; // Example count
  int get publicationsCount => _publicationsCount;

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

  void navigateToHome() {
    _navigationService.clearStackAndShow(Routes.startupView);
  }
}
