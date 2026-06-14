# 🧪 PLAN DE TEST - VALIDATION COMPLÈTE

## 📋 PRE-TEST CHECKLIST

Avant de tester, vérifier:

- [ ] Fichiers `adaptive_stream_service.dart` et `stream_quality_service.dart` créés ✓
- [ ] Services enregistrés dans `app.locator.dart`
- [ ] Imports ajoutés dans `LiveViewerViewModel`
- [ ] 8 changements appliqués dans `LiveViewerViewModel`
- [ ] UI badges ajoutés dans `live_viewer_view.dart`
- [ ] Compilation réussie: `flutter build apk` sans erreur
- [ ] Device connecté (réel ou émulateur)

---

## 🧪 TEST 1: Vérification Démarrage (5 min)

### Objectif

Vérifier que l'app démarre sans crash et que les services sont chargés.

### Étapes

1. Nettoyer: `flutter clean && flutter pub get`
2. Compiler: `flutter build apk`
3. Installer: `flutter install`
4. Lancer: `flutter run`
5. Vérifier les logs pour ces messages:

```
✅ [AdaptiveStream] Service initialized
✅ [StreamQuality] Service initialized
✅ [LiveViewer] Page changed: -1 → 0
```

### Résultat Attendu

```
✅ L'app démarre sans crash
✅ Logs affichent initialization
❌ Crash → vérifier imports/locator
```

---

## 🧪 TEST 2: Connexion HTTP-FLV (10 min)

### Objectif

Vérifier que le stream se connecte et affiche la vidéo.

### Étapes

1. Ouvrir l'app
2. Naviguer vers Live Hub
3. Cliquer sur un live
4. Observer les logs:

```
🌐 [AdaptiveStream] Testing connectivity for HTTP-FLV
📡 [AdaptiveStream] Successfully connected to HTTP-FLV
✅ [LiveViewer] Controller initialized for index 0
```

### Vérification UI

- [ ] Vidéo affichée dans le player
- [ ] Badge qualité visible (ex: "480p")
- [ ] Point vert visible en bas-droit (stream healthy)
- [ ] Chat messages affichés
- [ ] Boutons action actifs (like, share, contact)

### Résultat Attendu

```
✅ Stream vidéo affiché
✅ Badges visible
✅ Qualité affichée correctement
❌ Vidéo noire → URL invalide
❌ Badge pas visible → UI pas appliquée
```

---

## 🧪 TEST 3: Fallback HLS (10 min)

### Objectif

Vérifier que le système fallback sur HLS si HTTP-FLV échoue.

### Étapes

1. Temporairement modifier `adaptive_stream_service.dart`:

```dart
// Dans getOptimalStreamUrl(), commenter la première tentative:
/*
if (await _testStreamConnectivity(flvUrl, StreamProtocol.httpFlv)) {
  // ... FLV logic
}
*/

// Forcer le fallback sur HLS
```

2. Relancer l'app
3. Observer les logs:

```
❌ [AdaptiveStream] HTTP-FLV test failed
⚠️ [AdaptiveStream] Fallback sur HLS: http://...m3u8
🔄 [AdaptiveStream] Protocol changed to HLS
```

4. Vérifier que le stream fonctionne toujours

### Résultat Attendu

```
✅ Fallback sur HLS automatique
✅ Stream toujours affiché
❌ Crash → vérifier le fallback logic
```

---

## 🧪 TEST 4: Reconnexion Auto (15 min)

### Objectif

Vérifier que la reconnexion automatique fonctionne.

### Étapes

#### 4A: Tester avec interruption réseau

1. Lancer un live avec le stream FLV actif
2. Dans Android Studio:
   - Tools → Device Monitor → Network Throttle → Network Off
3. Observer les logs:

```
❌ [AdaptiveStream] Playback error: No internet
🔄 [AdaptiveStream] Reconnect attempt 1/10 in Duration(seconds: 2)
```

4. Réactiver le réseau: Network Throttle → Full (or WiFi)
5. Attendre 2 secondes
6. Observer:

```
✅ [AdaptiveStream] Reconnected successfully
▶️ [LiveViewer] Stream resumed
```

#### 4B: Tester avec Slow 3G

1. Network Throttle → Slow 3G
2. Lancer un live
3. Observer qualité downgrade:

```
📉 [StreamQuality] Downgraded: medium → low
Qualité: 360p (affiché dans le badge)
```

### Résultat Attendu

```
✅ Reconnexion auto après interrupt
✅ Qualité adapte à la bande passante
✅ Pas de crash, pause puis resume
❌ Stream reste coupé → vérifier retry logic
```

---

## 🧪 TEST 5: Changement de Qualité (10 min)

### Objectif

Vérifier que la qualité change selon la bande passante.

### Étapes

1. Lancer un live
2. Vérifier la qualité initiale (badge affiche ex "480p")
3. Utiliser Network Throttle:

```
WiFi (100 Mbps)  → Badge: 720p (High)
4G (20 Mbps)     → Badge: 480p (Medium)
3G (5 Mbps)      → Badge: 360p (Low)
```

4. Observer les logs:

```
📊 [StreamQuality] Chunk: 512KB in 100ms => 40960kbps
📈 [StreamQuality] Upgraded: low → high
Badge affiche: "720p"
```

### Résultat Attendu

```
✅ Badge change selon throttle réseau
✅ Pas de buffering excessif
✅ Transition lisse entre qualités
❌ Badge fixe → updateBufferLevel pas appelé
```

---

## 🧪 TEST 6: Buffering Handling (15 min)

### Objectif

Vérifier que les bufferings sont minimisés et gérés correctement.

### Étapes

1. Mettre Network Throttle sur "Slow 3G"
2. Lancer un live
3. Observer si buffering visible
4. Vérifier les logs:

```
⚠️ [AdaptiveStream] Buffering event #1
🔴 [AdaptiveStream] Health: CRITICAL
📉 [StreamQuality] Downgraded to: 360p
```

5. Attendre 5 secondes (buffer reconstitue)
6. Observer recovery:

```
✅ [AdaptiveStream] Health: HEALTHY
```

### Résultat Attendu

```
✅ Buffering < 2 secondes
✅ Qualité downgrade automatique
✅ Recovery rapide
❌ Buffering > 5 secondes → config SRS à améliorer
```

---

## 🧪 TEST 7: Changement Page/Slide (10 min)

### Objectif

Vérifier que le changement de page reinitialise correctement.

### Étapes

1. Lancer un live (index 0)
2. Scroll vers le bas pour voir le prochain live (PageView vertical)
3. Observer les logs:

```
▶️ [LiveViewer] Playing existing controller at index 0
📄 [LiveViewer] Page changed: 0 → 1
🔧 [LiveViewer] Initializing new controller for index 1
```

4. Vérifier que le nouveau stream se charge
5. Scroll back
6. Vérifier que l'ancien revient

### Résultat Attendu

```
✅ Changement de page smooth
✅ Ancien stream en pause
✅ Nouveau stream initialise et joue
❌ Freeze/lag → controller pas bien nettoyé
```

---

## 🧪 TEST 8: Monitoring Badges (5 min)

### Objectif

Vérifier que les badges affichent les bonnes infos.

### Étapes

1. Lancer un live
2. Vérifier les 2 badges:

```
Badge Gauche:   "480p" (qualité vidéo)
Badge Droit:    Cercle vert/orange/rouge (santé)
```

3. Changer throttle réseau et observer:

```
WiFi     → Badge gauche: "720p", Cercle vert
Slow 3G  → Badge gauche: "360p", Cercle orange
Off      → Badge gauche: "360p", Cercle rouge
```

### Résultat Attendu

```
✅ Badge qualité affichée et changeable
✅ Badge santé affiche le bon statut
✅ Couleurs correctes (vert/orange/rouge)
❌ Badge pas visible → CSS pas appliqué
```

---

## 🧪 TEST 9: Snackbar Messages (5 min)

### Objectif

Vérifier que les messages informatifs s'affichent.

### Étapes

1. Lancer un live
2. Changer Network Throttle
3. Observer les snackbars:

```
Quality Degraded     → "Qualité réduite - connexion faible"
Network Reconnect    → "Tentative de reconnexion..."
Stream Unavailable   → "Stream indisponible"
Quality Changed      → "Qualité: 720p"
```

### Résultat Attendu

```
✅ Messages affichés au bon moment
✅ Texte lisible et approprié
✅ Auto-dismiss après 2-3 secondes
❌ Pas de messages → callback pas appelé
```

---

## 🧪 TEST 10: Logs & Performance (10 min)

### Objectif

Vérifier que les services ne créent pas de memory leak et logs sont corrects.

### Étapes

1. Lancer l'app et rester sur un live 5 minutes
2. Vérifier les logs pour ces patterns:

```
✅ [AdaptiveStream] en continu
✅ [StreamQuality] en continu
✅ [LiveViewer] actions principales
```

3. Observer pas de doublons ou erreurs répétées
4. Vérifier pas de crash après long usage
5. Fermer le live (quitter la page)
6. Vérifier les logs de cleanup:

```
🛑 [LiveViewer] Stopping adaptive services
✅ Disposed properly
```

### Résultat Attendu

```
✅ Pas de memory leak observable
✅ Logs utiles et pas spammés
✅ Cleanup correct on dispose
❌ Logs > 1000 messages/min → loop infini?
```

---

## 📊 TEMPLATE RAPPORT DE TEST

```
=== RAPPORT DE TEST ===
Date: [DATE]
Device: [MODEL] Android [VERSION]
Réseau: [WiFi/4G/3G]

TEST 1: Démarrage           ✅ PASS / ❌ FAIL / ⚠️ PARTIEL
  Commentaire: [détail si besoin]

TEST 2: HTTP-FLV            ✅ PASS / ❌ FAIL / ⚠️ PARTIEL
  Commentaire: [détail si besoin]

TEST 3: Fallback HLS        ✅ PASS / ❌ FAIL / ⚠️ PARTIEL
  Commentaire: [détail si besoin]

TEST 4: Reconnexion         ✅ PASS / ❌ FAIL / ⚠️ PARTIEL
  Commentaire: [détail si besoin]

TEST 5: Quality Change      ✅ PASS / ❌ FAIL / ⚠️ PARTIEL
  Commentaire: [détail si besoin]

TEST 6: Buffering           ✅ PASS / ❌ FAIL / ⚠️ PARTIEL
  Commentaire: [détail si besoin]

TEST 7: Page Change         ✅ PASS / ❌ FAIL / ⚠️ PARTIEL
  Commentaire: [détail si besoin]

TEST 8: Badges              ✅ PASS / ❌ FAIL / ⚠️ PARTIEL
  Commentaire: [détail si besoin]

TEST 9: Snackbars           ✅ PASS / ❌ FAIL / ⚠️ PARTIEL
  Commentaire: [détail si besoin]

TEST 10: Performance        ✅ PASS / ❌ FAIL / ⚠️ PARTIEL
  Commentaire: [détail si besoin]

RÉSULTAT GLOBAL: ✅ READY / ⚠️ NEEDS FIXES / ❌ CRITICAL ISSUES

Issues à fixer: [liste]
Priorité: [HIGH/MEDIUM/LOW]
```

---

## 🚀 TESTER EN PRODUCTION

Une fois tous les tests locaux passent:

1. **Déployer sur Staging**

   ```bash
   flutter build apk --release
   # Installer sur device
   ```

2. **Tester 24h en continu**
   - Monitor les logs
   - Vérifier pas de crash
   - Vérifier pas de memory leak

3. **Tester à plusieurs spectateurs**
   - 5+ persons simultané
   - Vérifier scalabilité

4. **Déployer sur Production**
   - Deployer progressivement (5% → 25% → 100%)
   - Monitor crashlytics
   - Monitor analytics

---

## 📞 SI UN TEST ÉCHOUE

### Erreur Compilation

```
Cannot find 'AdaptiveStreamService'
→ Vérifier app.locator.dart enregistrement
```

### Erreur Runtime

```
Null safety error: _adaptiveStreamService is null
→ Vérifier imports + locator dans ViewModel
```

### Pas de Video

```
Stream URL is null
→ Vérifier SRS server fonctionne
→ Vérifier URL de stream correcte
→ Vérifier http.head() test connectivité
```

### Pas de Reconnexion

```
Stream reste coupé après interruption
→ Vérifier _retryWithExponentialBackoff() appelée
→ Vérifier ExponentialBackoff delays correctes
→ Vérifier SRS up et accessible
```

### Quality Pas Change

```
Badge toujours "480p"
→ Vérifier updateBufferLevel() appelée
→ Vérifier reportChunkDownload() appelée
→ Vérifier adapting timer actif
```

---

## ✅ TOUS LES TESTS PASSENT?

Félicitations! 🎉

La Phase 1 est complete:

- ✅ Reconnexion automatique
- ✅ Fallback protocol intelligent
- ✅ Quality adaptative
- ✅ Monitoring continu
- ✅ UX améliorée

**Prochaine étape**: Phase 2 - Migration SRT pour broadcaster

---
