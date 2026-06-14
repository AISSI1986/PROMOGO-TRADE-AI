import 'dart:async';
import 'package:flutter/foundation.dart';

/// Profil de qualité vidéo
enum VideoQuality {
  low, // 360p @ 500kbps  - Connexions très faibles
  medium, // 480p @ 1Mbps    - Connexions normales
  high, // 720p @ 2Mbps    - Connexions bonnes
  ultra, // 1080p @ 4Mbps   - Connexions excellentes
}

/// Configuration bitrate pour chaque qualité
class QualityProfile {
  final VideoQuality quality;
  final int resolution; // Hauteur en pixels
  final int targetBitrate; // Kbps
  final int maxBitrate; // Kbps (peak)
  final int audioBitrate; // Kbps

  const QualityProfile({
    required this.quality,
    required this.resolution,
    required this.targetBitrate,
    required this.maxBitrate,
    required this.audioBitrate,
  });

  static const Map<VideoQuality, QualityProfile> profiles = {
    VideoQuality.low: QualityProfile(
      quality: VideoQuality.low,
      resolution: 360,
      targetBitrate: 500,
      maxBitrate: 700,
      audioBitrate: 32,
    ),
    VideoQuality.medium: QualityProfile(
      quality: VideoQuality.medium,
      resolution: 480,
      targetBitrate: 1000,
      maxBitrate: 1500,
      audioBitrate: 64,
    ),
    VideoQuality.high: QualityProfile(
      quality: VideoQuality.high,
      resolution: 720,
      targetBitrate: 2000,
      maxBitrate: 3000,
      audioBitrate: 96,
    ),
    VideoQuality.ultra: QualityProfile(
      quality: VideoQuality.ultra,
      resolution: 1080,
      targetBitrate: 4000,
      maxBitrate: 6000,
      audioBitrate: 128,
    ),
  };

  static QualityProfile getByBandwidth(double bandwidthKbps) {
    if (bandwidthKbps < 800) return profiles[VideoQuality.low]!;
    if (bandwidthKbps < 1500) return profiles[VideoQuality.medium]!;
    if (bandwidthKbps < 3000) return profiles[VideoQuality.high]!;
    return profiles[VideoQuality.ultra]!;
  }

  @override
  String toString() => '$resolution@${targetBitrate}kbps';
}

/// Service de gestion de la qualité adaptative
/// Estime la bande passante et adjust la qualité en temps réel
class StreamQualityService extends ChangeNotifier {
  // État actuel
  VideoQuality _currentQuality = VideoQuality.medium;
  VideoQuality get currentQuality => _currentQuality;
  QualityProfile get currentProfile =>
      QualityProfile.profiles[_currentQuality]!;

  // Estimée bande passante (Kbps)
  double _estimatedBandwidth = 2000; // Default 2Mbps
  double get estimatedBandwidth => _estimatedBandwidth;

  // Historique pour moyenne mobile
  final List<double> _bandwidthHistory = [];
  static const int maxHistoryLength = 10;

  // Configuration d'adaptation
  static const Duration adaptationInterval = Duration(seconds: 10);
  static const double adaptationThreshold = 1.2; // 20% hysteresis

  // Timers
  Timer? _adaptationTimer;
  DateTime? _lastAdaptationTime;

  // Callbacks
  Function(VideoQuality oldQuality, VideoQuality newQuality)? onQualityChanged;
  Function(double bandwidth)? onBandwidthEstimated;

  // Monitoring
  int _totalBandwidthSamples = 0;
  int _qualityUpgrades = 0;
  int _qualityDowngrades = 0;
  DateTime? _initTime;

  /// Initialiser le service
  void initialize() {
    _initTime = DateTime.now();
    _startAdaptationLoop();
  }

  /// Rapporter la taille d'un chunk téléchargé et son temps de transfert
  /// Utilisé pour estimer la bande passante réelle
  void reportChunkDownload({
    required int chunkSizeBytes,
    required Duration downloadDuration,
  }) {
    if (downloadDuration.inMilliseconds == 0) return;

    // Calculer bande passante (Kbps)
    final bandwidthKbps =
        (chunkSizeBytes * 8) / (downloadDuration.inMilliseconds / 1000) / 1000;

    // Ajouter à l'historique (moyenne mobile)
    _bandwidthHistory.add(bandwidthKbps);
    if (_bandwidthHistory.length > maxHistoryLength) {
      _bandwidthHistory.removeAt(0);
    }

    // Calculer la moyenne
    _estimatedBandwidth =
        _bandwidthHistory.reduce((a, b) => a + b) / _bandwidthHistory.length;
    _totalBandwidthSamples++;

    print(
        "📊 [StreamQuality] Chunk: ${chunkSizeBytes ~/ 1024}KB in ${downloadDuration.inMilliseconds}ms => ${bandwidthKbps.toStringAsFixed(1)}kbps (avg: ${_estimatedBandwidth.toStringAsFixed(1)}kbps)");

    onBandwidthEstimated?.call(_estimatedBandwidth);
    notifyListeners();
  }

  /// Estimer la bande passante basée sur le buffer level
  /// Buffer faible = bande passante insuffisante
  void estimateBandwidthFromBuffer({
    required double bufferLevelMs,
    required Duration segmentDuration,
  }) {
    // Si buffer faible, bande passante < bitrate courant
    const double bufferThreshold = 5000; // 5 secondes

    if (bufferLevelMs < bufferThreshold) {
      final degradedBandwidth = _estimatedBandwidth * 0.8; // Réduire 20%
      _estimatedBandwidth = (_estimatedBandwidth + degradedBandwidth) / 2;
      print(
          "⚠️ [StreamQuality] Buffer low, reducing estimated bandwidth to ${_estimatedBandwidth.toStringAsFixed(1)}kbps");
    }

    notifyListeners();
  }

  /// Adapter la qualité basée sur la bande passante actuelle
  void _adaptQuality() {
    final recommendedQuality =
        QualityProfile.getByBandwidth(_estimatedBandwidth);

    if (recommendedQuality.quality == _currentQuality) return;

    // Appliquer hysteresis pour éviter trop de changements
    final currentBitrate = currentProfile.targetBitrate.toDouble();
    final recommendedBitrate = recommendedQuality.targetBitrate.toDouble();

    final ratio = recommendedBitrate / currentBitrate;
    if (ratio > 1 / adaptationThreshold && ratio < adaptationThreshold) {
      return; // Pas assez de différence
    }

    _setQuality(recommendedQuality.quality);
  }

  /// Définir manuellement la qualité
  void _setQuality(VideoQuality quality) {
    if (quality == _currentQuality) return;

    final oldQuality = _currentQuality;
    _currentQuality = quality;
    _lastAdaptationTime = DateTime.now();

    if (quality.index > oldQuality.index) {
      _qualityUpgrades++;
      print("📈 [StreamQuality] Upgraded: $oldQuality → $quality");
    } else {
      _qualityDowngrades++;
      print("📉 [StreamQuality] Downgraded: $oldQuality → $quality");
    }

    onQualityChanged?.call(oldQuality, quality);
    notifyListeners();
  }

  /// Forcer une qualité spécifique
  void setQuality(VideoQuality quality) {
    _setQuality(quality);
  }

  /// Obtenir toutes les qualités disponibles
  List<QualityProfile> getAvailableQualities() {
    return QualityProfile.profiles.values.toList();
  }

  /// Obtenir la qualité recommandée
  VideoQuality getRecommendedQuality() {
    return QualityProfile.getByBandwidth(_estimatedBandwidth).quality;
  }

  /// Lancer la boucle d'adaptation
  void _startAdaptationLoop() {
    _adaptationTimer?.cancel();
    _adaptationTimer = Timer.periodic(adaptationInterval, (_) {
      _adaptQuality();
    });
  }

  /// Obtenir les statistiques
  Map<String, dynamic> getStats() {
    final uptime = DateTime.now().difference(_initTime ?? DateTime.now());
    return {
      'currentQuality': _currentQuality.toString(),
      'estimatedBandwidth': '${_estimatedBandwidth.toStringAsFixed(1)} Kbps',
      'totalSamples': _totalBandwidthSamples,
      'qualityUpgrades': _qualityUpgrades,
      'qualityDowngrades': _qualityDowngrades,
      'uptime': uptime.inSeconds,
      'availableQualities': QualityProfile.profiles.length,
    };
  }

  /// Obtenir l'URL du stream adapté (si possible)
  String adaptStreamUrl(String baseUrl, VideoQuality? overrideQuality) {
    final quality = overrideQuality ?? _currentQuality;
    // Format: http://server:8080/live/streamKey_{quality}.flv
    // À adapter selon votre configuration SRS
    return '$baseUrl?quality=${quality.name}';
  }

  /// Réinitialiser les statistiques
  void resetStats() {
    _bandwidthHistory.clear();
    _estimatedBandwidth = 2000;
    _totalBandwidthSamples = 0;
    _qualityUpgrades = 0;
    _qualityDowngrades = 0;
    _initTime = DateTime.now();
    _currentQuality = VideoQuality.medium;
  }

  /// Arrêter l'adaptation
  void stop() {
    _adaptationTimer?.cancel();
  }

  /// Nettoyer les ressources
  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

/// Extension pour obtenir le label lisible
extension VideoQualityExt on VideoQuality {
  String get label {
    switch (this) {
      case VideoQuality.low:
        return '360p (Faible débit)';
      case VideoQuality.medium:
        return '480p (Normal)';
      case VideoQuality.high:
        return '720p (Bon débit)';
      case VideoQuality.ultra:
        return '1080p (Excellent débit)';
    }
  }

  String get shortLabel {
    switch (this) {
      case VideoQuality.low:
        return '360p';
      case VideoQuality.medium:
        return '480p';
      case VideoQuality.high:
        return '720p';
      case VideoQuality.ultra:
        return '1080p';
    }
  }

  int get emoji {
    switch (this) {
      case VideoQuality.low:
        return 0x1F534; // 🔴
      case VideoQuality.medium:
        return 0x1F7E0; // 🟠
      case VideoQuality.high:
        return 0x1F7E2; // 🟢
      case VideoQuality.ultra:
        return 0x1F535; // 🔵
    }
  }
}
