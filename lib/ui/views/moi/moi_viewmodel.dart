import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';

class MoiViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  void navigateToSettings() {
    _navigationService.navigateToReglagesView();
  }

  void onConnectOrRegister() {
    // Navigate to connect or register
  }
}
