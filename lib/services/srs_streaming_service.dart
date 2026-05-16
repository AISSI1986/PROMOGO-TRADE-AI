import 'package:promogoai/ui/common/api_constants.dart';
import 'package:stacked/stacked.dart';

class SrsStreamingService {
  /// Génère l'URL RTMP pour le Broadcaster (Vendeur)
  String getRtmpPushUrl(String streamKey) {
    return ApiConstants.getRtmpPushUrl(streamKey);
  }

  /// Génère l'URL HLS pour le Viewer (Acheteur) - Bonne compatibilité iOS/Android
  String getHlsPlayUrl(String streamKey) {
    return ApiConstants.getHlsPlayUrl(streamKey);
  }

  /// Génère l'URL HTTP-FLV pour le Viewer (Acheteur) - Basse Latence
  String getHttpFlvPlayUrl(String streamKey) {
    return ApiConstants.getHttpFlvPlayUrl(streamKey);
  }
}
