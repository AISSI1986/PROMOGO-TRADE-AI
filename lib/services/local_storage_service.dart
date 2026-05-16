import 'dart:io';
import 'dart:convert';
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

  Future<void> saveData(String fileName, String content) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  Future<String?> getData(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      print("Error reading data: $e");
    }
    return null;
  }

  Future<void> saveJson(String key, dynamic json) async {
    try {
      final content = jsonEncode(json);
      await saveData(key, content);
    } catch (e) {
      print("Error saving JSON: $e");
    }
  }

  Future<dynamic> getJson(String key) async {
    try {
      final content = await getData(key);
      if (content != null) {
        return jsonDecode(content);
      }
    } catch (e) {
      print("Error reading JSON: $e");
    }
    return null;
  }

  Future<void> clearData(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print("Error clearing data: $e");
    }
  }

  Future<void> clearAll() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final entities = await directory.list().toList();
      for (var entity in entities) {
        if (entity is File) {
          await entity.delete();
        }
      }
    } catch (e) {
      print("Error clearing all data: $e");
    }
  }
}
