import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';

class MyPublicationsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  void onBack() {
    _navigationService.back();
  }
}
