import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';

class LoginViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  String phoneNumber = '';
  String phoneCountryCode = '233'; // Par défaut: Ghana
  String phoneIsoCode = 'gh';

  void goBack() {
    _navigationService.back();
  }

  void navigateToRegister() {
    _navigationService.navigateToRegisterView();
  }

  void navigateToHome() {
    _navigationService.clearStackAndShow(Routes.homeView);
  }

  void navigateToForgotPassword() {
    // TODO: Implémenter la navigation vers la récupération de mot de passe
  }
}
