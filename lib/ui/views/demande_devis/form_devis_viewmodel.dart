import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';

class FormDevisViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  String _description = '';
  String get description => _description;
  
  int _charCount = 0;
  int get charCount => _charCount;

  String _selectedUnit = 'Pièces';
  String get selectedUnit => _selectedUnit;

  bool _shareBusinessCard = false;
  bool get shareBusinessCard => _shareBusinessCard;

  bool _acceptTerms = true;
  bool get acceptTerms => _acceptTerms;

  final List<String> units = ['Pièces', 'Lots', 'kg', 'mètres', 'm²', 'Acre'];

  void updateDescription(String value) {
    _description = value;
    _charCount = value.length;
    notifyListeners();
  }

  void updateUnit(String? value) {
    if (value != null) {
      _selectedUnit = value;
      notifyListeners();
    }
  }

  void toggleShareBusinessCard(bool? value) {
    _shareBusinessCard = value ?? false;
    notifyListeners();
  }

  void toggleAcceptTerms(bool? value) {
    _acceptTerms = value ?? false;
    notifyListeners();
  }

  void goBack() {
    _navigationService.back();
  }

  void submitForm() {
    // Logic for submission would go here
    _navigationService.back();
  }
}
