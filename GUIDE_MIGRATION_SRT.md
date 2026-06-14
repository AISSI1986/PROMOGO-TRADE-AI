# 🔄 MIGRATION SRT - Guide Complet

## 📚 Qu'est-ce que SRT ?

**SRT (Secure Reliable Transport)** est un protocole UDP moderne pour le streaming vidéo en direct

### Comparaison RTMP vs SRT

| Aspect                 | RTMP             | SRT                      |
| ---------------------- | ---------------- | ------------------------ |
| **Protocole Base**     | TCP              | UDP                      |
| **Latence**            | 2-3s             | 500ms-1s                 |
| **Pertes Paquets**     | ❌ Bloque        | ✅ FEC (correction auto) |
| **Connexions Mobiles** | ❌ Problématique | ✅ Excellent             |
| **Débit Adaptatif**    | ❌ Non           | ✅ Oui                   |
| **Firewall Traversal** | ⚠️ Complexe      | ✅ Simple                |
| **CPU Serveur**        | Modéré           | Bas                      |
| **Scalabilité**        | Moyennes         | Excellente               |

---

## 🛠️ SETUP SRS avec SRT

### Step 1: Compiler SRS avec SRT

#### Option A: Docker (Recommandé)

```bash
# Créer un Dockerfile pour SRS avec SRT
FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    libssl-dev \
    pkg-config

# Clone SRS
RUN git clone https://github.com/ossrs/srs.git /srs
WORKDIR /srs/trunk

# Compiler avec SRT support
RUN ./configure --with-srt=on && \
    make -j4

EXPOSE 1935 8080 10080 8081
WORKDIR /srs/trunk/objs

CMD ["./srs", "-c", "conf/srs.conf"]
```

Lancer:

```bash
docker build -t srs-with-srt .
docker run -p 1935:1935 -p 8080:8080 -p 10080:10080 srs-with-srt
```

#### Option B: Compilation Locale

```bash
# Sur votre serveur Linux
cd /opt
git clone https://github.com/ossrs/srs.git
cd srs/trunk

# Configurer avec SRT
./configure --with-srt=on --with-ssl=on

# Compiler
make -j4

# Démarrer
./objs/srs -c conf/srs.conf
```

### Step 2: Configuration SRS (`srs.conf`)

```conf
# SRS Configuration avec SRT Support

# RTMP Input (toujours supporté pour compatibilité)
listen              1935;
max_connections     1000;

# HTTP Server
http_server {
    enabled         on;
    listen          8080;
    dir             ./objs/nginx/html;
}

# SRT Input Server
srt_server {
    enabled         on;
    listen          10080;  # SRT Port

    # Latency settings (ms)
    latency         500;    # 500ms max latency

    # Loss tolerence
    max_bw          100000; # 100 Mbps max
}

# Main VHOST
vhost __defaultVhost__ {
    # SRT settings
    srt {
        enabled on;
    }

    # HTTP FLV Live Stream
    http_flv {
        enabled on;
    }

    # HLS
    hls {
        enabled on;
        hls_fragment    10;
        hls_window      60;
    }

    # RTMP Relay (si vous avez d'autres services)
    rtmp_auto_start on;
}
```

---

## 📱 IMPLEMENTATION FLUTTER - Broadcaster

### Step 1: Créer `SrtStreamingService`

```dart
import 'package:promogoai/ui/common/api_constants.dart';

class SrtStreamingService {
  /// Générer l'URL SRT pour le Broadcaster
  /// Format: srt://host:10080?streamid={streamKey},m=publish
  String getSrtPushUrl(String streamKey) {
    // srt://server:10080?streamid=live/streamKey,m=publish
    return 'srt://${ApiConstants.srsHost}:10080?streamid=live/$streamKey,m=publish';
  }

  /// Fallback RTMP si SRT non disponible
  String getRtmpPushUrl(String streamKey) {
    return ApiConstants.getRtmpPushUrl(streamKey);
  }

  /// URL pour viewer
  String getHttpFlvPlayUrl(String streamKey) {
    return ApiConstants.getHttpFlvPlayUrl(streamKey);
  }

  /// Obtenir l'URL de push optimale
  Future<String> getOptimalPushUrl(String streamKey) async {
    // 🆕 Essayer SRT d'abord
    if (await _testSrtConnectivity()) {
      return getSrtPushUrl(streamKey);
    }

    // Fallback sur RTMP
    return getRtmpPushUrl(streamKey);
  }

  /// Tester la connectivité SRT
  Future<bool> _testSrtConnectivity() async {
    try {
      // Tentative de connection simple
      // Cette logique dépend de votre implémentation de socket SRT
      // Pour Flutter, il faudrait utiliser un plugin comme flutter_srt

      // Pour l'instant, retourner false et utiliser RTMP
      return false;
    } catch (e) {
      return false;
    }
  }
}
```

### Step 2: Mettre à jour `SrsStreamingService`

```dart
import 'package:promogoai/ui/common/api_constants.dart';

class SrsStreamingService {
  // 🆕 SRT Support
  String getSrtPushUrl(String streamKey) {
    return 'srt://${ApiConstants.srsHost}:10080?streamid=live/$streamKey,m=publish';
  }

  /// Générer l'URL RTMP (fallback)
  String getRtmpPushUrl(String streamKey) {
    return ApiConstants.getRtmpPushUrl(streamKey);
  }

  /// Générer l'URL HLS pour le Viewer
  String getHlsPlayUrl(String streamKey) {
    return ApiConstants.getHlsPlayUrl(streamKey);
  }

  /// Générer l'URL HTTP-FLV pour le Viewer (basse latence)
  String getHttpFlvPlayUrl(String streamKey) {
    return ApiConstants.getHttpFlvPlayUrl(streamKey);
  }

  /// 🆕 Obtenir l'URL de push optimale selon la connexion
  Future<String> getOptimalPushUrl(String streamKey) async {
    // Pour une future implémentation avec un plugin SRT
    // Pour maintenant, utiliser RTMP
    return getRtmpPushUrl(streamKey);
  }
}
```

### Step 3: Mettre à jour les API Constants

```dart
// Dans api_constants.dart

class ApiConstants {
  // ... URLs existantes ...

  // --- Serveur SRS (Streaming Vidéo) ---
  static const String srsHost = djangoServerHost;

  // RTMP
  static String getRtmpPushUrl(String streamKey) => 'rtmp://$srsHost:1935/live/$streamKey';

  // 🆕 SRT (Nouveau)
  static String getSrtPushUrl(String streamKey) => 'srt://$srsHost:10080?streamid=live/$streamKey,m=publish';

  // HTTP-FLV (Viewing)
  static String getHttpFlvPlayUrl(String streamKey) => 'http://$srsHost:8080/live/$streamKey.flv';

  // HLS (Fallback)
  static String getHlsPlayUrl(String streamKey) => 'http://$srsHost:8080/live/$streamKey.m3u8';
}
```

---

## 📊 RESULTATS ESPERÉS

### Avant SRT (RTMP seul)

```
🌐 Connection: TCP pur
⏱️ Latence: 2-3 secondes
📉 Pertes paquets: bloquent tout
🔴 Connexion 4G instable: Déconnexions fréquentes
```

### Après SRT

```
🌐 Connection: UDP + FEC
⏱️ Latence: 500ms-1s
📉 Pertes paquets: auto-corrigées
🟢 Connexion 4G instable: Streaming fluide
```

---

## 🚀 TRANSITION PROGRESSIVE

### Phase 1: Garder RTMP (Maintenant)

- Broadcaster: RTMP
- Viewer: HTTP-FLV + HLS fallback
- Service: AdaptiveStreamService + StreamQualityService

### Phase 2: Ajouter SRT (Prochaine)

- Broadcaster: SRT (primaire) + RTMP (fallback)
- Viewer: HTTP-FLV + HLS
- Monitoring: Comparer latence/stabilité

### Phase 3: Migration Complète SRT (Plus tard)

- Broadcaster: SRT uniquement
- Viewer: HTTP-FLV optimisé pour SRT
- Backend: Optimisé pour SRT

---

## 📝 CONFIGURATION DETAILS

### Ajuster Latency pour votre cas

```conf
srt_server {
    latency 200;    # Ultra-low: 200ms (moins de buffer tolérances)
    latency 500;    # Low: 500ms (balance latence/stabilité)
    latency 1000;   # Medium: 1s (plus stable sur connexions faibles)
    latency 2000;   # High: 2s (très stable mais moins immédiat)
}
```

### Réglages Broadcaster côté Client

```dart
// Dans ApiVideoLiveStreamController
ApiVideoLiveStreamController(
  initialAudioConfig: AudioConfig(
    bitrate: 64000,
  ),
  initialVideoConfig: VideoConfig.withDefaultBitrate(
    resolution: Resolution.RESOLUTION_480,
  ),
  // 🆕 Optimisations pour SRT
  // À ajouter si ApiVideoLiveStream supporte les options
  networkConfig: NetworkConfig(
    protocol: 'srt',           // Utiliser SRT
    timeout: 5000,             // 5s timeout
    reconnectAttempts: 5,      // 5 tentatives
    lowLatencyMode: true,      // Mode ultra-basse latence
  ),
)
```

---

## ✅ CHECKLIST MIGRATION

- [ ] Compiler SRS avec SRT support
- [ ] Configurer `srs.conf` pour SRT
- [ ] Tester connexion SRT en local
- [ ] Mettre à jour API Constants
- [ ] Créer `SrtStreamingService` (optionnel)
- [ ] Tester broadcaster avec SRT
- [ ] Tester viewers avec HTTP-FLV depuis SRT
- [ ] Déployer sur production
- [ ] Monitor latence/stabilité

---

## 🐛 TROUBLESHOOTING

### Erreur: "SRT server not responding"

```bash
# Vérifier que le port 10080 est ouvert
netstat -tuln | grep 10080

# Vérifier les logs SRS
tail -f objs/srs.log

# Redémarrer SRS
pkill -f objs/srs
./objs/srs -c conf/srs.conf
```

### Broadcaster: Connection timeout

```bash
# Vérifier firewall
sudo ufw allow 10080/udp

# Vérifier la config SRT
grep -A5 "srt_server" conf/srs.conf
```

### Viewer: Buffering excessif

```conf
# Augmenter la latence SRT (dans srs.conf)
srt_server {
    latency 1000;  # Augmenter à 1000ms
}
```

---
