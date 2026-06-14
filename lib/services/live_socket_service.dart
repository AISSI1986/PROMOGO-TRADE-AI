import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:promogoai/ui/common/api_constants.dart';

class LiveSocketService {
  WebSocketChannel? _channel;
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  String? _currentLiveId;
  int _reconnectAttempts = 0;
  bool _shouldReconnect = true;

  Stream<Map<String, dynamic>> get events => _eventController.stream;

  void connect(String liveId) {
    _currentLiveId = liveId;
    _shouldReconnect = true;
    _reconnectAttempts = 0;
    _connectInternal();
  }

  void _connectInternal() {
    if (_currentLiveId == null) return;
    if (_channel != null) {
      print("⚠️ [WebSocket] Déjà connecté, on ferme l'ancienne connexion avant de reconnecter.");
      _channel!.sink.close();
      _channel = null;
    }
    
    final url = 'ws://${ApiConstants.djangoServerHost}:8085/ws/live/$_currentLiveId/';
    print("🌐 [WebSocket] Tentative de connexion sur : $url (Essai $_reconnectAttempts)");
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _channel!.stream.listen(
        (message) {
          // Connexion réussie, on réinitialise le compteur d'essais
          _reconnectAttempts = 0;
          print("📩 [WebSocket] Message reçu : $message");
          try {
            _eventController.add(jsonDecode(message));
          } catch (e) {
            print("❌ [WebSocket] Erreur de décodage JSON : $e");
          }
        },
        onError: (error) {
          print("❌ [WebSocket] ERREUR : $error");
          _channel = null;
          _handleConnectionLoss();
        },
        onDone: () {
          print("🔌 [WebSocket] CONNEXION FERMÉE");
          _channel = null;
          _handleConnectionLoss();
        },
      );
    } catch (e) {
      print("❌ [WebSocket] Erreur lors de la connexion : $e");
      _channel = null;
      _handleConnectionLoss();
    }
  }

  void _handleConnectionLoss() {
    if (!_shouldReconnect) return;
    
    if (_reconnectAttempts < 3) {
      _reconnectAttempts++;
      final delay = _reconnectAttempts * 3;
      print("🔄 [WebSocket] Connexion perdue. Nouvelle tentative dans $delay secondes...");
      Future.delayed(Duration(seconds: delay), () {
        if (_shouldReconnect && _channel == null) {
          _connectInternal();
        }
      });
    } else {
      print("❌ [WebSocket] Impossible de se reconnecter après 3 tentatives.");
      _eventController.add({"type": "live_ended", "reason": "socket_closed"});
    }
  }

  void sendEvent(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(data));
    }
  }

  void disconnect() {
    _shouldReconnect = false;
    _reconnectAttempts = 0;
    _channel?.sink.close();
    _channel = null;
    _currentLiveId = null;
  }
}
