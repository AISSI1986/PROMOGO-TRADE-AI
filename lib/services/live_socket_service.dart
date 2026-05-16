import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:promogoai/ui/common/api_constants.dart';

class LiveSocketService {
  WebSocketChannel? _channel;
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get events => _eventController.stream;

  void connect(String liveId) {
    if (_channel != null) {
      print("⚠️ [WebSocket] Déjà connecté, tentative ignorée.");
      return;
    }
    
    final url = 'ws://${ApiConstants.djangoServerHost}/ws/live/$liveId/';
    print("🌐 [WebSocket] Tentative de connexion sur : $url");
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _channel!.stream.listen(
        (message) {
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
        },
        onDone: () {
          print("🔌 [WebSocket] CONNEXION FERMÉE PAR LE SERVEUR");
          _channel = null;
        },
      );
    } catch (e) {
      print("❌ [WebSocket] Erreur lors de la connexion : $e");
      _channel = null;
    }
  }

  void sendEvent(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(data));
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
