import 'dart:async';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
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

  StreamSubscription? _amplitudeSubscription;
  double _currentAmplitude = -160.0; // En dB, -160 est le silence absolu
  double get currentAmplitude => _currentAmplitude;

  void startListening() async {
    _isRecording = true;
    _agentResponse = null;
    notifyListeners();

    // On lance le vrai enregistrement du micro
    await _aiVoiceService.startRecording();
    
    // On écoute les variations de volume pour le visualiseur
    _amplitudeSubscription = _aiVoiceService.onAmplitudeChanged.listen((amplitude) {
      _currentAmplitude = amplitude.current;
      notifyListeners();
    });
  }

  void cancelRecording(Function(SheetResponse) completer) async {
    _isRecording = false;
    _amplitudeSubscription?.cancel();
    _currentAmplitude = -160.0;
    notifyListeners();
    
    await _aiVoiceService.cancelRecording();
    completer(SheetResponse(confirmed: false));
  }

  void toggleRecording(Function(SheetResponse) completer) async {
    if (_isRecording) {
      // Arrêt de l'enregistrement et envoi
      _isRecording = false;
      _amplitudeSubscription?.cancel();
      _currentAmplitude = -160.0;
      notifyListeners();

      _isProcessing = true;
      notifyListeners();

      try {
        final response = await _aiVoiceService.stopRecordingAndSend(
          onProgress: (status) {
            _agentResponse = status;
            notifyListeners(); // Met à jour l'UI en temps réel !
          }
        );
        
        if (response.containsKey('error')) {
          _agentResponse = response['error'];
        } else {
          _agentResponse = response['transcription'];
          final vector = response['vector'];
          
          if (vector != null) {
            // Laisse le temps à l'utilisateur de lire la transcription avant de fermer
            Future.delayed(const Duration(milliseconds: 1500), () {
              completer(SheetResponse(
                confirmed: true, 
                data: {
                  'vector': vector,
                  'transcription': _agentResponse,
                },
              ));
            });
          }
        }
      } catch (e) {
        _agentResponse = "Désolé, une erreur s'est produite lors de la connexion.";
      }

      _isProcessing = false;
      notifyListeners();
    } else {
      // Si l'utilisateur clique sur le micro pour relancer
      startListening();
    }
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    super.dispose();
  }
}
