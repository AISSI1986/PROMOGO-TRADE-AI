import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:promogoai/ui/common/api_constants.dart';

enum StreamProtocol { httpFlv, hls }

enum StreamHealthStatus {
  healthy, // Flux stable, bon bitrate
  degraded, // Buffering léger, connexion instable
  critical, // Forte dégradation, risque de coupure
  offline, // Pas de connexion
}

/// Service de gestion adaptative du streaming vidéo
/// Gère: reconnexion automatique, fallback de protocole, monitoring de qualité
class AdaptiveStreamService {
  // Configuration
  static const int maxReconnectAttempts = 10;
  static const Duration baseReconnectDelay = Duration(seconds: 2);
  static const Duration maxReconnectDelay = Duration(seconds: 30);
  static const Duration healthCheckInterval = Duration(seconds: 5);
  static const int minBufferMillis = 2500; // 2.5s minimum pour éviter buffering
  static const int maxBufferMillis = 20000; // 20s max
  static const int maxBufferWithPreload = 30000; // 30s en preload

  // État du stream
  String? _currentStreamUrl;
  StreamProtocol _currentProtocol = StreamProtocol.httpFlv;
  StreamProtocol _preferredProtocol = StreamProtocol.httpFlv;

  int _reconnectAttempts = 0;
  bool _isConnecting = false;
  bool _shouldReconnect = true;

  // Monitoring
  final _healthStreamController =
      StreamController<StreamHealthStatus>.broadcast();
  final _bufferLevelController = StreamController<double>.broadcast();
  final _protocolChangeController =
      StreamController<StreamProtocol>.broadcast();

  Stream<StreamHealthStatus> get healthStream => _healthStreamController.stream;
  Stream<double> get bufferLevelStream => _bufferLevelController.stream;
  Stream<StreamProtocol> get protocolChangeStream =>
      _protocolChangeController.stream;

  StreamHealthStatus _currentHealth = StreamHealthStatus.offline;
  StreamHealthStatus get currentHealth => _currentHealth;

  Timer? _healthCheckTimer;
  DateTime? _lastSuccessfulConnection;
  int _totalBufferingEvents = 0;
  double _averageBufferLevel = 0;

  // Callbacks
  Function(String url)? onStreamUrlChanged;
  Function(String error)? onStreamError;

  /// Initialiser le service
  void initialize() {
    _resetState();
    _startHealthMonitoring();
  }

  /// Obtenir l'URL optimale pour un stream ID selon la connexion
  /// Essaie HTTP-FLV d'abord, puis fallback sur HLS
  Future<String?> getOptimalStreamUrl(String streamId) async {
    _currentStreamUrl = null;
    _shouldReconnect = true;
    _isConnecting = true;

    try {
      // 1️⃣ Retourner directement HTTP-FLV la première fois (pas de HEAD request qui fait planter SRS)
      if (_preferredProtocol == StreamProtocol.httpFlv && _reconnectAttempts == 0) {
        final flvUrl = ApiConstants.getHttpFlvPlayUrl(streamId);
        _currentStreamUrl = flvUrl;
        _currentProtocol = StreamProtocol.httpFlv;
        _lastSuccessfulConnection = DateTime.now();
        _updateHealth(StreamHealthStatus.healthy);
        return flvUrl;
      }

      // 2️⃣ Fallback sur HLS si on essaie de se reconnecter
      final hlsUrl = ApiConstants.getHlsPlayUrl(streamId);
      _currentStreamUrl = hlsUrl;
      _currentProtocol = StreamProtocol.hls;
      _preferredProtocol = StreamProtocol.hls; // On reste sur HLS
      _updateHealth(StreamHealthStatus.degraded);
      _protocolChangeController.add(StreamProtocol.hls);
      onStreamUrlChanged?.call(hlsUrl);
      print("⚠️ [AdaptiveStream] Fallback sur HLS: $hlsUrl");
      return hlsUrl;
      
    } finally {
      _isConnecting = false;
    }
  }

  /// Reconnecter avec stratégie intelligente
  Future<bool> reconnect(String streamId) async {
    if (_isConnecting || !_shouldReconnect) return false;

    if (_reconnectAttempts >= maxReconnectAttempts) {
      print("❌ [AdaptiveStream] Max reconnect attempts reached");
      _updateHealth(StreamHealthStatus.offline);
      return false;
    }

    // Backoff exponentiel
    final delay = _calculateBackoffDelay();
    _reconnectAttempts++;

    print(
        "🔄 [AdaptiveStream] Reconnect attempt $_reconnectAttempts/$maxReconnectAttempts in $delay");
    await Future.delayed(delay);

    try {
      final url = await getOptimalStreamUrl(streamId);
      if (url != null) {
        _reconnectAttempts = 0;
        print("✅ [AdaptiveStream] Reconnected successfully");
        return true;
      }
    } catch (e) {
      print("❌ [AdaptiveStream] Reconnect failed: $e");
    }

    return false;
  }

  /// Mettre à jour le niveau de buffer (appelé par le lecteur vidéo)
  void updateBufferLevel(double bufferLevel) {
    _averageBufferLevel = bufferLevel;
    _bufferLevelController.add(bufferLevel);

    // Mettre à jour la santé basée sur le buffer
    if (bufferLevel < minBufferMillis) {
      if (_currentHealth != StreamHealthStatus.critical) {
        _updateHealth(StreamHealthStatus.critical);
      }
    } else if (bufferLevel < minBufferMillis * 1.5) {
      if (_currentHealth == StreamHealthStatus.healthy) {
        _updateHealth(StreamHealthStatus.degraded);
      }
    } else if (bufferLevel > minBufferMillis * 2 &&
        _currentHealth != StreamHealthStatus.healthy) {
      _updateHealth(StreamHealthStatus.healthy);
    }
  }

  /// Détecter une coupure de buffering
  void onBufferingDetected() {
    _totalBufferingEvents++;
    print("⚠️ [AdaptiveStream] Buffering event #$_totalBufferingEvents");
    _updateHealth(StreamHealthStatus.critical);
  }

  /// Vérifier la connectivité d'un stream
  Future<bool> _testStreamConnectivity(
      String url, StreamProtocol protocol) async {
    try {
      // Timeout rapide pour le test
      final response = await http.head(
        Uri.parse(url),
        headers: {'Range': 'bytes=0-1'}, // Demande just les premiers bytes
      ).timeout(const Duration(seconds: 5));

      // Pour FLV: check 200 ou 206 (partial content)
      if (protocol == StreamProtocol.httpFlv) {
        return response.statusCode == 200 || response.statusCode == 206;
      }

      // Pour HLS: check 200
      return response.statusCode == 200;
    } catch (e) {
      print("❌ [AdaptiveStream] Connectivity test failed for $protocol: $e");
      return false;
    }
  }

  /// Calculer le délai de backoff exponentiel
  Duration _calculateBackoffDelay() {
    final exponentialDelay = baseReconnectDelay * (1 << _reconnectAttempts);
    return exponentialDelay.compareTo(maxReconnectDelay) > 0
        ? maxReconnectDelay
        : exponentialDelay;
  }

  /// Monitoring continu de la santé du stream
  void _startHealthMonitoring() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(healthCheckInterval, (_) {
      _checkStreamHealth();
    });
  }

  /// Vérifier la santé du stream
  void _checkStreamHealth() {
    if (_currentStreamUrl == null) {
      _updateHealth(StreamHealthStatus.offline);
      return;
    }

    // Si buffering excessif
    if (_totalBufferingEvents > 3) {
      if (_currentHealth != StreamHealthStatus.critical) {
        _updateHealth(StreamHealthStatus.critical);
      }
    }

    // Si buffer très faible
    if (_averageBufferLevel < minBufferMillis) {
      if (_currentHealth != StreamHealthStatus.critical) {
        _updateHealth(StreamHealthStatus.critical);
      }
    }
  }

  /// Mettre à jour l'état de santé
  void _updateHealth(StreamHealthStatus status) {
    if (_currentHealth != status) {
      _currentHealth = status;
      _healthStreamController.add(status);

      switch (status) {
        case StreamHealthStatus.healthy:
          print("✅ [AdaptiveStream] Health: HEALTHY");
          break;
        case StreamHealthStatus.degraded:
          print("⚠️ [AdaptiveStream] Health: DEGRADED");
          break;
        case StreamHealthStatus.critical:
          print("🔴 [AdaptiveStream] Health: CRITICAL");
          break;
        case StreamHealthStatus.offline:
          print("❌ [AdaptiveStream] Health: OFFLINE");
          break;
      }
    }
  }

  /// Obtenir les statistiques
  Map<String, dynamic> getStats() {
    return {
      'currentProtocol': _currentProtocol.toString(),
      'streamUrl': _currentStreamUrl,
      'health': _currentHealth.toString(),
      'reconnectAttempts': _reconnectAttempts,
      'bufferingEvents': _totalBufferingEvents,
      'averageBufferLevel': _averageBufferLevel,
      'lastSuccessfulConnection': _lastSuccessfulConnection?.toIso8601String(),
    };
  }

  /// Arrêter le monitoring
  void stop() {
    _shouldReconnect = false;
    _healthCheckTimer?.cancel();
    _currentStreamUrl = null;
    _resetState();
  }

  /// Réinitialiser l'état
  void _resetState() {
    _reconnectAttempts = 0;
    _isConnecting = false;
    _totalBufferingEvents = 0;
    _averageBufferLevel = 0;
  }

  /// Nettoyer les ressources
  void dispose() {
    stop();
    _healthStreamController.close();
    _bufferLevelController.close();
    _protocolChangeController.close();
    _healthCheckTimer?.cancel();
  }
}
