# 🎯 CHANGEMENTS EXACTS À APPLIQUER

## 📍 Fichier 1: `lib/app/app.locator.dart`

### Localiser cette section:

```dart
void setupLocator() {
  // Tous les locator.registerSingleton() existants
  locator.registerSingleton<XyzService>(XyzService());
  // ... plus de services ...
}
```

### Ajouter à la fin (avant la fermeture `}`)

```dart
// 🆕 AJOUTER CES 2 LIGNES:
locator.registerSingleton<AdaptiveStreamService>(
  AdaptiveStreamService(),
);

locator.registerSingleton<StreamQualityService>(
  StreamQualityService(),
);
```

### Ajouter les imports en haut du fichier

```dart
// 🆕 AJOUTER CES 2 IMPORTS:
import 'package:promogoai/services/adaptive_stream_service.dart';
import 'package:promogoai/services/stream_quality_service.dart';
```

---

## 📍 Fichier 2: `lib/ui/views/live_viewer/live_viewer_viewmodel.dart`

### CHANGEMENT A: Ajouter les imports en haut

```dart
// 🆕 AJOUTER APRÈS les autres imports:
import 'package:promogoai/services/adaptive_stream_service.dart';
import 'package:promogoai/services/stream_quality_service.dart';
```

### CHANGEMENT B: Ajouter les dépendances à la classe

Localiser:

```dart
class LiveViewerViewModel extends BaseViewModel {
  final _srsService = locator<SrsStreamingService>();
  final _socketService = locator<LiveSocketService>();
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
```

Ajouter après:

```dart
  // 🆕 AJOUTER CES 2 LIGNES:
  final _adaptiveStreamService = locator<AdaptiveStreamService>();
  final _qualityService = locator<StreamQualityService>();
```

### CHANGEMENT C: Initialiser dans `initViewer()`

Localiser cette ligne:

```dart
await WakelockPlus.enable(); // Garde l'écran allumé
```

Ajouter immédiatement après:

```dart
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
```

### CHANGEMENT D: Remplacer `_initController()`

**TROUVER** cette méthode existante ET **REMPLACER LE DÉBUT** complètement:

```dart
// 🔴 ANCIEN CODE (À REMPLACER):
Future<void> _initController(int index, {bool autoPlay = true}) async {
  if (controllers.containsKey(index)) return;

  final url = videoUrls[index];
  try {
    // ... ancien code ...
```

**PAR** (NOUVEAU CODE):

```dart
// 🟢 NOUVEAU CODE:
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

### CHANGEMENT E: Ajouter la nouvelle méthode `_retryWithExponentialBackoff()`

**AJOUTER CETTE NOUVELLE MÉTHODE** n'importe où dans la classe:

```dart
/// 🆕 AJOUTER CETTE NOUVELLE MÉTHODE:
/// Reconnecter avec backoff exponentiel en cas d'erreur
Future<void> _retryWithExponentialBackoff(int index) async {
  if (index >= sessions.length || _isDisposed) return;

  final streamId = sessions[index]['id'].toString();
  int attempt = 0;
  const maxAttempts = 5;

  print("🔄 [LiveViewer] Starting reconnection for stream $index");

  while (attempt < maxAttempts && !_isDisposed) {
    attempt++;

    final delay = Duration(seconds: attempt * 2);
    print("⏳ [LiveViewer] Reconnection attempt $attempt/$maxAttempts in $delay");

    await Future.delayed(delay);

    final success = await _adaptiveStreamService.reconnect(streamId);

    if (success) {
      await _initController(index, autoPlay: currentVideoIndex == index);
      print("✅ [LiveViewer] Reconnected to stream $index");
      return;
    }
  }

  print("❌ [LiveViewer] Failed to reconnect after $maxAttempts attempts");
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

### CHANGEMENT F: Remplacer `onPageChanged()`

**TROUVER** et **REMPLACER COMPLÈTEMENT**:

```dart
// 🔴 ANCIEN CODE:
void onPageChanged(int index) {
  if (index == currentVideoIndex) return;

  currentVideoIndex = index;
  // ... ancien code ...
}

// 🟢 NOUVEAU CODE:
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

### CHANGEMENT G: Ajouter 2 nouveaux callbacks

**AJOUTER CES 2 NOUVELLES MÉTHODES** n'importe où dans la classe:

```dart
/// 🆕 AJOUTER CES 2 MÉTHODES:
void _onStreamHealthChanged(StreamHealthStatus health) {
  print("🏥 [LiveViewer] Stream health: ${health.toString()}");

  if (_isDisposed) return;

  switch (health) {
    case StreamHealthStatus.healthy:
      print("✅ [LiveViewer] Stream is healthy");
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

### CHANGEMENT H: Mettre à jour `onDispose()`

**LOCALISER** (dans le fichier):

```dart
@override
void onDispose(LiveViewerViewModel viewModel) {
  viewModel.getPlayer(viewModel.currentVideoIndex)?.pause();
  // ... reste du code ...
  super.onDispose(viewModel);
}
```

**AJOUTER AVANT** `super.onDispose(viewModel);`:

```dart
  // 🆕 AJOUTER CES LIGNES AVANT super.onDispose:
  print("🛑 [LiveViewer] Stopping adaptive services");
  viewModel._adaptiveStreamService.dispose();
  viewModel._qualityService.stop();

  for (var controller in viewModel.controllers.values) {
    controller.dispose();
  }
```

---

## 📍 Fichier 3: `lib/ui/views/live_viewer/live_viewer_view.dart`

### Localiser le widget Stack dans `_buildBottomSection()`

Trouver la section qui commence par:

```dart
const SizedBox(height: 15),

// 5. CONTACT BUTTON
if (bottomInset == 0) _buildContactButton(),
```

### Ajouter avant la fermeture du Column:

```dart
        const SizedBox(height: 15),

        // 5. CONTACT BUTTON
        if (bottomInset == 0) _buildContactButton(),
      ],
    ),
  );
}

// 🆕 AJOUTER CES WIDGETS:
// Badge de qualité
Positioned(
  bottom: 70,
  left: 20,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.videocam, color: Colors.white, size: 12),
        const SizedBox(width: 6),
        ValueListenableBuilder<VideoQuality>(
          valueListenable: ValueNotifier(viewModel._qualityService.currentQuality),
          builder: (context, quality, _) {
            return Text(
              quality.shortLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ],
    ),
  ),
),

// Badge de santé du stream
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

## ✅ RÉSUMÉ DES FICHIERS À MODIFIER

| Fichier                      | Type             | Lignes     | Difficulté     |
| ---------------------------- | ---------------- | ---------- | -------------- |
| `app.locator.dart`           | Ajouter 6 lignes | 2-5        | ⭐ Très facile |
| `live_viewer_viewmodel.dart` | 8 changements    | ~80 lignes | ⭐⭐ Facile    |
| `live_viewer_view.dart`      | Ajouter UI       | ~50 lignes | ⭐⭐ Facile    |

**Total lignes**: ~136 lignes nouvelles
**Temps estimation**: 1-2 heures

---

## 🚨 NOTES IMPORTANTES

### ✋ Avant de modifier:

1. Sauvegarder vos fichiers actuels (git commit)
2. Vérifier que vous utilisez la version complète du code
3. Ne pas couper-coller blindement, adapter si votre code est légèrement différent

### ✅ Après modification:

1. Compiler: `flutter pub get && flutter build apk`
2. Vérifier les erreurs: `flutter analyze`
3. Tester sur device réel

### 🐛 Si compilation échoue:

1. Vérifier les imports
2. Vérifier le `app.locator.dart`
3. Vérifier les types (StreamHealthStatus, VideoQuality, etc.)
4. Faire `flutter clean && flutter pub get`

---

## 🎯 ORDRE D'APPLICATION

1️⃣ **app.locator.dart** (2 min) - Services enregistrés
2️⃣ **live_viewer_viewmodel.dart** (30 min) - Logique principale
3️⃣ **live_viewer_view.dart** (10 min) - UI badges

**Testez après chaque fichier!**

---
