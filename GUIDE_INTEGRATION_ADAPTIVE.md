# 🎯 GUIDE INTEGRATION - ADAPTIVE STREAMING

## 📋 ÉTAPES D'INTEGRATION

### 1. Enregistrer les services dans `app.locator.dart`

```dart
// ✅ AJOUTER ces lignes dans setupLocator()
final locator = GetIt.instance;

void setupLocator() {
  // ... autres services ...

  // 🆕 Streaming Adaptatif
  locator.registerSingleton<AdaptiveStreamService>(
    AdaptiveStreamService(),
  );

  locator.registerSingleton<StreamQualityService>(
    StreamQualityService(),
  );
}
```

---

## 2. Mettre à jour `LiveViewerViewModel`

### Changement 1: Ajouter les dépendances

```dart
class LiveViewerViewModel extends BaseViewModel {
  final _srsService = locator<SrsStreamingService>();
  final _socketService = locator<LiveSocketService>();
  final _authService = locator<AuthService>();

  // 🆕 Services adaptatifs
  final _adaptiveStreamService = locator<AdaptiveStreamService>();
  final _qualityService = locator<StreamQualityService>();

  // ... reste du code ...
}
```

### Changement 2: Initialiser dans `initViewer()`

```dart
Future<void> initViewer({bool initializeVideo = true, bool autoPlay = true}) async {
  setBusy(true);
  failedVideoIndices.clear();
  await WakelockPlus.enable();

  // 🆕 Initialiser les services
  _adaptiveStreamService.initialize();
  _qualityService.initialize();

  // 🆕 Listen aux changements de santé
  _adaptiveStreamService.healthStream.listen((health) {
    _onStreamHealthChanged(health);
  });

  // 🆕 Listen aux changements de qualité
  _qualityService.addListener(() {
    _onQualityChanged();
  });

  // ... reste du code ...
}
```

### Changement 3: Initialiser les contrôleurs avec reconnexion

```dart
Future<void> _initController(int index, {bool autoPlay = true}) async {
  if (controllers.containsKey(index)) return;

  // 🆕 Obtenir l'URL optimale avec fallback
  final url = await _adaptiveStreamService.getOptimalStreamUrl(
    sessions[index]['id'].toString(),
  );

  if (url == null) {
    failedVideoIndices.add(index);
    print("❌ Failed to get stream URL for index $index");
    return;
  }

  try {
    final player = Player();
    final videoController = VideoController(player);

    // 🆕 Mettre à jour le service de qualité
    _qualityService.setQuality(_qualityService.getRecommendedQuality());

    await player.open(Media(url));

    controllers[index] = LivePlayerData(
      player: player,
      videoController: videoController,
    );
    controllers[index]?.isInitialized = true;

    if (autoPlay) {
      player.play();
    }

    // 🆕 Listen au buffer level pour monitoring
    player.stream.bufferingProgress.listen((progress) {
      _adaptiveStreamService.updateBufferLevel(progress * 100); // 0-100
    });

    notifyListeners();
  } catch (e) {
    print("❌ Error initializing controller $index: $e");
    failedVideoIndices.add(index);
  }
}
```

### Changement 4: Gérer le changement de page avec reconnexion

```dart
void onPageChanged(int index) {
  if (index == currentVideoIndex) return;

  currentVideoIndex = index;

  // Pause ancien
  if (currentVideoIndex != index) {
    getPlayer(currentVideoIndex)?.pause();
  }

  // 🆕 Initialiser le nouveau avec reconnexion
  if (!isControllerInitialized(index)) {
    Future.delayed(const Duration(milliseconds: 100), () async {
      final url = await _adaptiveStreamService.getOptimalStreamUrl(
        sessions[index]['id'].toString(),
      );

      if (url != null) {
        await _initController(index, autoPlay: true);
      } else {
        // 🆕 Tentative de reconnexion
        await _retryWithExponentialBackoff(index);
      }
    });
  } else {
    getPlayer(index)?.play();
  }

  notifyListeners();
}
```

### Changement 5: Nouvelle méthode de reconnexion

```dart
/// Reconnecter avec backoff exponentiel
Future<void> _retryWithExponentialBackoff(int index) async {
  if (index >= sessions.length) return;

  final streamId = sessions[index]['id'].toString();
  int attempt = 0;
  const maxAttempts = 5;

  while (attempt < maxAttempts) {
    final success = await _adaptiveStreamService.reconnect(streamId);

    if (success) {
      await _initController(index, autoPlay: true);
      print("✅ Reconnected to stream $index after attempt $attempt");
      return;
    }

    attempt++;
    if (attempt < maxAttempts) {
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }

  print("❌ Failed to reconnect to stream $index after $maxAttempts attempts");
  failedVideoIndices.add(index);
  notifyListeners();
}
```

### Changement 6: Nouvelles callbacks pour monitoring

```dart
/// Appelé quand la santé du stream change
void _onStreamHealthChanged(StreamHealthStatus health) {
  print("🏥 Stream health changed: $health");

  switch (health) {
    case StreamHealthStatus.healthy:
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.success,
        message: "Connexion excellente",
      );
      break;

    case StreamHealthStatus.degraded:
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.warning,
        message: "Qualité réduite - connexion faible",
      );
      break;

    case StreamHealthStatus.critical:
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.warning,
        message: "Tentative de reconnexion...",
      );
      break;

    case StreamHealthStatus.offline:
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: "Stream indisponible",
      );
      break;
  }

  notifyListeners();
}

/// Appelé quand la qualité change
void _onQualityChanged() {
  final newQuality = _qualityService.currentQuality.shortLabel;
  print("📺 Quality changed to: $newQuality");

  _snackbarService.showCustomSnackBar(
    variant: SnackbarType.info,
    message: "Qualité: $newQuality",
    duration: const Duration(seconds: 2),
  );

  notifyListeners();
}
```

### Changement 7: Mettre à jour onDispose

```dart
@override
void onDispose(LiveViewerViewModel viewModel) {
  // Pause la vidéo
  viewModel.getPlayer(viewModel.currentVideoIndex)?.pause();

  // 🆕 Arrêter les services
  viewModel._adaptiveStreamService.dispose();
  viewModel._qualityService.stop();

  // Nettoyer les contrôleurs
  for (var controller in viewModel.controllers.values) {
    controller.dispose();
  }

  viewModel._socketSubscription?.cancel();
  super.onDispose(viewModel);
}
```

---

## 3. Mettre à jour `LiveViewerView` pour afficher la qualité

### Dans la UI, ajouter un badge de qualité

```dart
// Dans _buildHeader() ou _buildBottomSection()
Positioned(
  bottom: 60,
  left: 20,
  child: StreamBuilder<StreamQualityService>(
    stream: _qualityService.stream, // Si changement notifié
    builder: (context, snapshot) {
      final quality = viewModel._qualityService.currentQuality;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.green.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              quality.shortLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    },
  ),
)
```

---

## 4. Mettre à jour le Broadcaster aussi

### Dans `LiveBroadcasterViewModel`

```dart
Future<void> _initStreaming() async {
  try {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // 🆕 Adapter la résolution selon la qualité recommandée
    final qualityService = locator<StreamQualityService>();
    final recommendedQuality = qualityService.getRecommendedQuality();

    final resolution = _getResolutionForQuality(recommendedQuality);

    final controller = ApiVideoLiveStreamController(
      initialAudioConfig: AudioConfig(bitrate: 64000),
      initialVideoConfig: VideoConfig.withDefaultBitrate(
        resolution: resolution,
      ),
      onConnectionSuccess: () {
        print("[LiveBroadcaster] RTMP Connected with $resolution");
      },
      onConnectionFailed: (error) {
        print("[LiveBroadcaster] RTMP Error: $error");
      },
    );

    _isFrontCamera = true;
    await controller.initialize();

    _controller = controller;
    _isStreamingInitialized = true;
    notifyListeners();
  } catch (e) {
    print("[LiveBroadcaster] Init Error: $e");
  }
}

Resolution _getResolutionForQuality(VideoQuality quality) {
  switch (quality) {
    case VideoQuality.low:
      return Resolution.RESOLUTION_360;
    case VideoQuality.medium:
      return Resolution.RESOLUTION_480;
    case VideoQuality.high:
      return Resolution.RESOLUTION_720;
    case VideoQuality.ultra:
      return Resolution.RESOLUTION_1080;
  }
}
```

---

## 5. Configuration SRS Backend (Optionnel mais Recommandé)

### Ajouter dans `srs.conf`

```conf
# Enable HTTP FLV streaming
http_server {
  enabled on;
  listen 8080;

  # Cache settings for reliability
  cache {
    enabled on;
    max_age 300;
  }
}

# RTMP Input
rtmp_server {
  listen 1935;

  # GOP (Group of Pictures) optimization
  gop_cache {
    enabled on;
  }
}

# HTTP FLV specific
stream {
  # Low latency settings
  min_latency_level 1;
  send_low_latency_packet true;
}
```

---

## 📊 RESULTATS ATTENDUS

### Avant Intégration

```
❌ Les spectateurs voient des coupures
❌ Pas de reconnexion automatique
❌ Pas d'adaptation de qualité
❌ Qualité fixe 480p peu importe la connexion
```

### Après Intégration

```
✅ Reconnexion automatique en cas de coupure
✅ Fallback HTTP-FLV → HLS automatique
✅ Adaptation qualité 360p-1080p selon bande passante
✅ Monitoring continu de la santé du stream
✅ UX fluide comme TikTok
✅ Buffering minimal
```

---

## 🚀 PROCHAINES ÉTAPES

1. **Tester** avec throttle réseau (DevTools)
2. **Ajouter SRT** pour le broadcaster (plus robuste que RTMP)
3. **Configurer un CDN** pour réduire latence
4. **Ajouter Analytics** pour tracker qualité en production
