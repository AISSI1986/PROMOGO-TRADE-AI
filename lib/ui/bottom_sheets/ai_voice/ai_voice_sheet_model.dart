import 'package:stacked/stacked.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/services/ai_voice_service.dart';

class AiVoiceSheetModel extends BaseViewModel {
  final _aiVoiceService = locator<AiVoiceService>();

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _agentResponse;
  String? get agentResponse => _agentResponse;

  void startListening() async {
    _isRecording = true;
    _agentResponse = null;
    notifyListeners();

    // On lance le vrai enregistrement du micro
    await _aiVoiceService.startRecording();
    
    // L'enregistrement continue jusqu'à ce que l'utilisateur reclique sur le bouton
  }

  void toggleRecording() async {
    if (_isRecording) {
      // Arrêt de l'enregistrement et envoi
      _isRecording = false;
      notifyListeners();

      _isProcessing = true;
      notifyListeners();

      try {
        // Arrête le micro, sauvegarde le fichier, et l'envoie à Django via WebSocket
        final response = await _aiVoiceService.stopRecordingAndSend(
          onProgress: (status) {
            _agentResponse = status;
            notifyListeners(); // Met à jour l'UI en temps réel !
          }
        );
        _agentResponse = response;
      } catch (e) {
        _agentResponse = "Désolé, une erreur s'est produite lors de la connexion.";
      }

      _isProcessing = false;
      notifyListeners();
    } else {
      // Si l'utilisateur clique sur le micro pour relancer, on relance avec l'arrêt automatique
      startListening();
    }
  }
}
