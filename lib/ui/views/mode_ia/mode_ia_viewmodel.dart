import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/services/ai_voice_service.dart';

class ModeIaViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _aiVoiceService = locator<AiVoiceService>();

  String get selectedLanguage => _aiVoiceService.selectedLangue;

  void setLanguage(String lang) {
    _aiVoiceService.setLangue(lang);
    notifyListeners(); // Met à jour l'UI
  }

  void goBack() {
    _navigationService.back();
  }
}
