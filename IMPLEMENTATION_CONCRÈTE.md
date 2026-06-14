# 🔧 IMPLEMENTATION CONCRÈTE - CODE À AJOUTER

## 1️⃣ ENREGISTRER LES SERVICES (app.locator.dart)

Trouver votre fichier `app/app.locator.dart` et ajouter:

```dart
// En haut du fichier, ajouter les imports
import 'package:promogoai/services/adaptive_stream_service.dart';
import 'package:promogoai/services/stream_quality_service.dart';

// Dans la fonction setupLocator()
void setupLocator() {
  // ... services existants ...

  // 🆕 AJOUTER CES LIGNES:
  // Streaming Adaptatif
  locator.registerSingleton<AdaptiveStreamService>(
    AdaptiveStreamService(),
  );

  locator.registerSingleton<StreamQualityService>(
    StreamQualityService(),
  );
}
```

---

## 2️⃣ METTRE À JOUR LiveViewerViewModel

### CHANGEMENT 2.1: Ajouter les imports

```dart
// En haut du fichier, ajouter:
import 'package:promogoai/services/adaptive_stream_service.dart';
import 'package:promogoai/services/stream_quality_service.dart';
```

### CHANGEMENT 2.2: Ajouter les dépendances au début de la classe

```dart
class LiveViewerViewModel extends BaseViewModel {
  final _srsService = locator<SrsStreamingService>();
  final _socketService = locator<LiveSocketService>();
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  // 🆕 AJOUTER CES LIGNES:
  final _adaptiveStreamService = locator<AdaptiveStreamService>();
  final _qualityService = locator<StreamQualityService>();

  // ... reste du code existant ...
```

### CHANGEMENT 2.3: Mettre à jour `initViewer()`

Trouver la méthode `initViewer()` et ajouter après `await WakelockPlus.enable();`:

```dart
Future<void> initViewer({bool initializeVideo = true, bool autoPlay = true}) async {
  setBusy(true);
  failedVideoIndices.clear();
  await WakelockPlus.enable();

  // 🆕 AJOUTER CES LIGNES:
  // Initialiser les services adaptatifs
  _adaptiveStreamService.initialize();
  _qualityService.initialize();

  // Listen aux changements de santé du stream
  _adaptiveStreamService.healthStream.listen((health) {
    _onStreamHealthChanged(health);
  });

  // Listen aux changements de qualité
  _qualityService.addListener(() {
    _onQualityChanged();
  });

  // ... reste du code existant ...
```

### CHANGEMENT 2.4: Mettre à jour `_initController()`

**TROUVER** cette méthode (elle génère les contrôleurs vidéo)

**REMPLACER LE DÉBUT** par:

```dart
Future<void> _initController(int index, {bool autoPlay = true}) async {
  if (controllers.containsKey(index)) return;

  if (index >= sessions.length) return;

  // 🆕 Obtenir l'URL optimale avec fallback intelligent
  final streamId = sessions[index]['id'].toString();
  final url = await _adaptiveStreamService.getOptimalStreamUrl(streamId);

  if (url == null) {
    failedVideoIndices.add(index);
    print("❌ [LiveViewer] Failed to get stream URL for index $index");
    _snackbarService.showCustomSnackBar(
      variant: SnackbarType.error,
      message: "Impossible de charger le stream",
    );
    return;
  }

  try {
    final player = Player();
    final videoController = VideoController(player);

    // 🆕 Adapter la qualité recommandée
    final recommendedQuality = _qualityService.getRecommendedQuality();
    _qualityService.setQuality(recommendedQuality);

    // Ouvrir le stream
    await player.open(Media(url));

    // Créer le contrôleur
    controllers[index] = LivePlayerData(
      player: player,
      videoController: videoController,
    );
    controllers[index]?.isInitialized = true;

    // 🆕 Listen au buffer level
    player.stream.bufferingProgress.listen((progress) {
      // Convertir 0-1 en 0-100%
      final bufferPercent = progress * 100;
      _adaptiveStreamService.updateBufferLevel(bufferPercent);
    });

    // 🆕 Listen aux erreurs de lecture
    player.stream.error.listen((error) {
      print("❌ [LiveViewer] Playback error: $error");
      _adaptiveStreamService.onStreamError?.call(error.toString());
    });

    if (autoPlay) {
      player.play();
    }

    print("✅ [LiveViewer] Controller initialized for index $index");
    notifyListeners();

  } catch (e) {
    print("❌ [LiveViewer] Error initializing controller $index: $e");
    failedVideoIndices.add(index);

    // 🆕 Tentative de reconnexion
    await _retryWithExponentialBackoff(index);
  }
}
```

### CHANGEMENT 2.5: Ajouter la méthode de reconnexion

**AJOUTER CETTE NOUVELLE METHODE** à la classe:

```dart
/// Reconnecter avec backoff exponentiel en cas d'erreur
Future<void> _retryWithExponentialBackoff(int index) async {
  if (index >= sessions.length || _isDisposed) return;

  final streamId = sessions[index]['id'].toString();
  int attempt = 0;
  const maxAttempts = 5;

  print("🔄 [LiveViewer] Starting reconnection for stream $index");

  while (attempt < maxAttempts && !_isDisposed) {
    attempt++;

    // Calculer le délai (2s, 4s, 8s, 16s, 32s)
    final delay = Duration(seconds: attempt * 2);
    print("⏳ [LiveViewer] Reconnection attempt $attempt/$maxAttempts in $delay");

    await Future.delayed(delay);

    // Tenter une reconnexion
    final success = await _adaptiveStreamService.reconnect(streamId);

    if (success) {
      // Réessayer d'initialiser le contrôleur
      await _initController(index, autoPlay: currentVideoIndex == index);
      print("✅ [LiveViewer] Reconnected to stream $index");
      return;
    }
  }

  // Si reconnexion échouée après tous les essais
  print("❌ [LiveViewer] Failed to reconnect to stream $index after $maxAttempts attempts");
  failedVideoIndices.add(index);

  if (!_isDisposed) {
    _snackbarService.showCustomSnackBar(
      variant: SnackbarType.error,
      message: "Stream indisponible",
    );
    notifyListeners();
  }
}
```

### CHANGEMENT 2.6: Mettre à jour `onPageChanged()`

**TROUVER** cette méthode et **REMPLACER** le contenu:

```dart
void onPageChanged(int index) {
  if (index == currentVideoIndex) return;

  final previousIndex = currentVideoIndex;
  currentVideoIndex = index;

  print("📄 [LiveViewer] Page changed: $previousIndex → $index");

  // 🆕 Pause la vidéo précédente
  if (previousIndex < videoUrls.length && previousIndex != index) {
    getPlayer(previousIndex)?.pause();
  }

  // 🆕 Initialiser ou jouer la nouvelle
  if (!isControllerInitialized(index)) {
    print("🔧 [LiveViewer] Initializing new controller for index $index");

    Future.delayed(const Duration(milliseconds: 100), () async {
      if (!_isDisposed && currentVideoIndex == index) {
        await _initController(index, autoPlay: true);
      }
    });
  } else {
    print("▶️ [LiveViewer] Playing existing controller at index $index");
    getPlayer(index)?.play();
  }

  notifyListeners();
}
```

### CHANGEMENT 2.7: Ajouter les callbacks de monitoring

**AJOUTER CES DEUX NOUVELLES MÉTHODES**:

```dart
/// Appelé quand la santé du stream change
void _onStreamHealthChanged(StreamHealthStatus health) {
  print("🏥 [LiveViewer] Stream health: ${health.toString()}");

  if (_isDisposed) return;

  switch (health) {
    case StreamHealthStatus.healthy:
      print("✅ [LiveViewer] Stream is healthy");
      // Optionnel: afficher un message positif
      break;

    case StreamHealthStatus.degraded:
      print("⚠️ [LiveViewer] Stream quality degraded");
      if (!_isDisposed) {
        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.warning,
          message: "Qualité réduite - connexion faible",
          duration: const Duration(seconds: 3),
        );
      }
      break;

    case StreamHealthStatus.critical:
      print("🔴 [LiveViewer] Stream health critical");
      if (!_isDisposed) {
        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.warning,
          message: "Tentative de reconnexion...",
          duration: const Duration(seconds: 2),
        );
      }
      break;

    case StreamHealthStatus.offline:
      print("❌ [LiveViewer] Stream offline");
      if (!_isDisposed) {
        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.error,
          message: "Stream indisponible",
        );
      }
      break;
  }

  notifyListeners();
}

/// Appelé quand la qualité vidéo change
void _onQualityChanged() {
  if (_isDisposed) return;

  final newQuality = _qualityService.currentQuality;
  print("📺 [LiveViewer] Quality changed to: ${newQuality.shortLabel}");

  _snackbarService.showCustomSnackBar(
    variant: SnackbarType.info,
    message: "Qualité: ${newQuality.shortLabel}",
    duration: const Duration(seconds: 2),
  );

  notifyListeners();
}
```

### CHANGEMENT 2.8: Mettre à jour `onDispose()`

**TROUVER** la méthode `onDispose` et ajouter avant `super.onDispose(viewModel)`:

```dart
@override
void onDispose(LiveViewerViewModel viewModel) {
  // Pause la vidéo
  viewModel.getPlayer(viewModel.currentVideoIndex)?.pause();

  // 🆕 Arrêter les services adaptatifs
  print("🛑 [LiveViewer] Stopping adaptive services");
  viewModel._adaptiveStreamService.dispose();
  viewModel._qualityService.stop();

  // Nettoyer les contrôleurs vidéo
  for (var controller in viewModel.controllers.values) {
    controller.dispose();
  }

  // Canceller les subscriptions
  viewModel._socketSubscription?.cancel();

  super.onDispose(viewModel);
}
```

---

## 3️⃣ AJOUTER UN BADGE DE QUALITÉ DANS LA VUE

Dans `live_viewer_view.dart`, dans la méthode `builder()`, ajouter ce Positioned widget dans le Stack:

```dart
// Dans le Stack de _buildBottomSection(), après les autres éléments UI
Positioned(
  bottom: 70,
  left: 20,
  child: Consumer<StreamQualityService>(
    builder: (context, qualityService, _) {
      final quality = qualityService.currentQuality;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam, color: Colors.white, size: 12),
            const SizedBox(width: 6),
            Text(
              quality.shortLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    },
  ),
),

// Aussi ajouter un badge de santé du stream
Positioned(
  bottom: 70,
  right: 20,
  child: StreamBuilder<StreamHealthStatus>(
    stream: viewModel._adaptiveStreamService.healthStream,
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox.shrink();

      final health = snapshot.data!;
      final colors = {
        StreamHealthStatus.healthy: Colors.green,
        StreamHealthStatus.degraded: Colors.orange,
        StreamHealthStatus.critical: Colors.red,
        StreamHealthStatus.offline: Colors.grey,
      };

      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: colors[health],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors[health]!.withOpacity(0.5),
              blurRadius: 4,
            ),
          ],
        ),
      );
    },
  ),
),
```

---

## 4️⃣ METTRE À JOUR ApiConstants (optionnel - pour SRT futur)

Dans `lib/ui/common/api_constants.dart`, ajouter:

```dart
// Ajouter après les URLs SRS existantes:
static String getSrtPushUrl(String streamKey) => 'srt://$srsHost:10080?streamid=live/$streamKey,m=publish';
```

---

## ✅ CHECKLIST D'IMPLEMENTATION

- [ ] Créer `adaptive_stream_service.dart` ✓
- [ ] Créer `stream_quality_service.dart` ✓
- [ ] Enregistrer les services dans `app.locator.dart`
- [ ] Mettre à jour `LiveViewerViewModel` (8 changements)
- [ ] Ajouter le badge de qualité dans `live_viewer_view.dart`
- [ ] Tester avec réseau throttlé
- [ ] Vérifier les logs

---

## 🧪 TESTER L'IMPLÉMENTATION

### Test 1: Vérifier les services sont enregistrés

```dart
// Dans la console
final adaptive = locator<AdaptiveStreamService>();
final quality = locator<StreamQualityService>();
print("Services registered: $adaptive, $quality");
```

### Test 2: Throttle réseau (DevTools)

1. Ouvrir DevTools Android Studio
2. Set Network Throttle: "Slow 3G"
3. Lancer un live
4. Observer les logs pour "downgraded", "buffering"

### Test 3: Couper la connexion

1. Mettre l'app en background
2. Couper WiFi
3. Remettre l'app en foreground
4. Observer si reconnexion automatique

---

## 📊 LOGS À OBSERVER

Rechercher dans les logs:

```
✅ [AdaptiveStream] Fallback sur HLS
🔄 [LiveViewer] Reconnection attempt
📉 [StreamQuality] Downgraded
📈 [StreamQuality] Upgraded
🏥 [LiveViewer] Stream health
```

---
