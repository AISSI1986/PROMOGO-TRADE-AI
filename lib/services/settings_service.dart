import 'package:stacked/stacked.dart';

class SettingsService with ListenableServiceMixin {
  String _selectedCountry = 'Togo';
  String get selectedCountry => _selectedCountry;

  String _selectedCurrency = 'XOF';
  String get selectedCurrency => _selectedCurrency;

  void setSelectedCountry(String country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void setSelectedCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }
}
