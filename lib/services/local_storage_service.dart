import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  static const String _onboardingFileName = 'onboarding_complete.txt';

  bool _hasSeenOnboarding = false;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_onboardingFileName');
      if (await file.exists()) {
        _hasSeenOnboarding = true;
      }
    } catch (e) {
      _hasSeenOnboarding = false;
    }
  }

  Future<void> setOnboardingComplete() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_onboardingFileName');
      await file.writeAsString('true');
      _hasSeenOnboarding = true;
    } catch (e) {
      // Handle error if necessary
    }
  }
}
