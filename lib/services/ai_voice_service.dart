import 'dart:io';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:promogoai/ui/common/api_constants.dart';

class AiVoiceService {
  final _logger = Logger();
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordingPath;

  // --- NOUVEAU : On mémorise la langue ici pour qu'elle soit accessible partout ---
  String _selectedLangue = 'fra';
  String get selectedLangue => _selectedLangue;
  
  void setLangue(String langue) {
    _selectedLangue = langue;
    _logger.i('Langue IA changée pour : $langue');
  }

  /// Lance l'enregistrement audio
  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _recordingPath = '${dir.path}/voice_command.wav';
        
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav, bitRate: 128000, sampleRate: 16000), 
          path: _recordingPath!
        );
        _logger.i('Enregistrement démarré: $_recordingPath');
      } else {
        _logger.e("Permission micro refusée");
      }
    } catch (e) {
      _logger.e('Erreur lors du démarrage du micro: $e');
    }
  }

  /// Arrête l'enregistrement et envoie le fichier au backend
  Future<String> stopRecordingAndSend({Function(String)? onProgress}) async {
    _logger.i('Arrêt de l\'enregistrement (Langue actuelle: $_selectedLangue)...');
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        return await sendVoiceToBackend(path, onProgress: onProgress);
      }
    } catch (e) {
      _logger.e('Erreur lors de l\'arrêt du micro: $e');
    }
    return "Erreur lors de l'enregistrement vocal.";
  }

  /// Envoie le fichier audio au backend FastAPI via WebSocket
  Future<String> sendVoiceToBackend(String audioFilePath, {Function(String)? onProgress}) async {
    _logger.i('Connexion WebSocket au moteur IA ($_selectedLangue)...');
    
    // On utilise la langue mémorisée dans le service
    final wsUrl = Uri.parse(ApiConstants.getAnalyseAudioWs(_selectedLangue));

    try {
      final channel = WebSocketChannel.connect(wsUrl);
      
      if (onProgress != null) onProgress("Envoi de l'audio ($_selectedLangue)...");
      
      final audioFile = File(audioFilePath);
      final bytes = await audioFile.readAsBytes();
      channel.sink.add(bytes);
      
      if (onProgress != null) onProgress("Analyse en cours...");

      String finalResult = "Analyse terminée.";

      await for (var message in channel.stream) {
        _logger.i('Message WebSocket reçu: $message');
        
        try {
          final data = jsonDecode(message as String);
          
          if (data['status'] != null) {
            if (onProgress != null) onProgress(data['status']);
          }
          
          if (data.containsKey('transcription')) {
            finalResult = data['transcription']?.toString() ?? "Analyse terminée.";
            break; 
          } else if (data.containsKey('error')) {
            finalResult = "Erreur: ${data['error']}";
            break;
          }
        } catch (e) {
          finalResult = message.toString();
        }
      }
      
      channel.sink.close();
      return finalResult;
      
    } catch (e) {
      _logger.e('Erreur de connexion WebSocket: $e');
      return "Erreur de connexion au serveur IA.";
    }
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}
