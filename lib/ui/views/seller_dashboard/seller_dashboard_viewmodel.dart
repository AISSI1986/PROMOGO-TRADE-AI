import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';

class SellerDashboardViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  int _publicationsCount = 12;
  int get publicationsCount => _publicationsCount;

  double _walletBalance = 450.50;
  double get walletBalance => _walletBalance;

  int _totalClicks = 1240;
  int get totalClicks => _totalClicks;

  int _pendingNotifications = 3;
  int get pendingNotifications => _pendingNotifications;

  void navigateToMyPublications() {
    _navigationService.navigateToMyPublicationsView();
  }

  void navigateToLiveBroadcasterView() {
    _navigationService.navigateToPreLiveSetupView();
  }

  void navigateToPreLiveSetupView() {
    _navigationService.navigateToPreLiveSetupView();
  }
}
