import 'package:stacked/stacked.dart';

class SrsStreamingService {
  // Configuration pour le serveur SRS (Simple Realtime Server)
  // En production, cette URL devrait être cryptée ou récupérée via une API sécurisée
  final String _srsRtmpBaseUrl = "rtmp://votre-serveur-srs.com/live";
  final String _srsHlsBaseUrl = "http://votre-serveur-srs.com:8080/live";
  final String _srsHttpFlvBaseUrl = "http://votre-serveur-srs.com:8080/live";

  /// Génère l'URL RTMP pour le Broadcaster (Vendeur)
  String getRtmpPushUrl(String streamKey) {
    return "$_srsRtmpBaseUrl/$streamKey";
  }

  /// Génère l'URL HLS pour le Viewer (Acheteur) - Bonne compatibilité iOS/Android
  String getHlsPlayUrl(String streamKey) {
    return "$_srsHlsBaseUrl/$streamKey.m3u8";
  }

  /// Génère l'URL HTTP-FLV pour le Viewer (Acheteur) - Basse Latence
  String getHttpFlvPlayUrl(String streamKey) {
    return "$_srsHttpFlvBaseUrl/$streamKey.flv";
  }
}
