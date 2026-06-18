import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:http/http.dart' as http;
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/services/ai_voice_service.dart';

class ModeIaViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _aiVoiceService = locator<AiVoiceService>();

  final TextEditingController textController = TextEditingController();
  final ScrollController chatScrollController = ScrollController();

  final List<Map<String, String>> messages = [
    {
      'sender': 'sura',
      'text': 'Bonjour ! Je suis SURA IA, votre assistante officielle Promogo. Posez-moi vos questions ou écrivez votre demande ici. 🎙️'
    }
  ];

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  String get selectedLanguage => _aiVoiceService.selectedLangue;
  String get textQuery => textController.text;

  ModeIaViewModel() {
    textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    notifyListeners();
  }

  void setLanguage(String lang) {
    _aiVoiceService.setLangue(lang);
    notifyListeners(); // Met à jour l'UI
  }

  void clearTextQuery() {
    textController.clear();
    notifyListeners();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatScrollController.hasClients) {
        chatScrollController.animateTo(
          chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> sendChatMessage(String prompt) async {
    if (prompt.trim().isEmpty) return;

    // 1. Ajouter le message de l'utilisateur
    messages.add({'sender': 'user', 'text': prompt});
    clearTextQuery();
    _isTyping = true;
    notifyListeners();
    scrollToBottom();

    // 2. Préparer le message de SURA qui va recevoir le flux de texte
    final int responseIndex = messages.length;
    messages.add({'sender': 'sura', 'text': ''});
    notifyListeners();

    try {
      final request = http.Request(
        'POST',
        Uri.parse('https://affirmation-promogo-voice-search.hf.space/chat-stream'),
      );
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'prompt': prompt});

      final http.StreamedResponse response = await http.Client().send(request);

      await for (final String chunk in response.stream.transform(utf8.decoder)) {
        messages[responseIndex]['text'] = (messages[responseIndex]['text'] ?? '') + chunk;
        notifyListeners();
        scrollToBottom();
      }
    } catch (e) {
      messages[responseIndex]['text'] = "Désolé, je rencontre des difficultés pour joindre le serveur IA.";
      notifyListeners();
    } finally {
      _isTyping = false;
      notifyListeners();
      scrollToBottom();
    }
  }

  void goBack() {
    _navigationService.back();
  }

  @override
  void dispose() {
    textController.removeListener(_onTextChanged);
    textController.dispose();
    chatScrollController.dispose();
    super.dispose();
  }
}
