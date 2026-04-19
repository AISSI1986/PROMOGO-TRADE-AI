import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';

class PromogoFairViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  String _fullName = '';
  String _phone = '';
  String _country = 'Pays de provenance';
  String _companyName = '';
  String _standType = 'Petit'; // Default selection
  String _sector = 'Secteur d\'activité';

  String get fullName => _fullName;
  String get phone => _phone;
  String get country => _country;
  String get companyName => _companyName;
  String get standType => _standType;
  String get sector => _sector;

  void setFullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setCountry(String value) {
    _country = value;
    notifyListeners();
  }

  void setCompanyName(String value) {
    _companyName = value;
    notifyListeners();
  }

  void setStandType(String value) {
    _standType = value;
    notifyListeners();
  }

  void setSector(String value) {
    _sector = value;
    notifyListeners();
  }

  void goBack() {
    _navigationService.back();
  }

  void preRegister() {
    // Logic for pre-registration
    print('Registering with: $_fullName, $_phone, $_country, $_companyName, $_standType, $_sector');
    // You can add validation or API calls here
  }
}
