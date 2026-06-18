class ApiConstants {
  // L'adresse IP de base de votre serveur backend.
  // En local avec l'émulateur Android : '10.0.2.2:8000'
  // En production : 'api.promogo.com' ou 'votre-ip:8000'
  // --- Serveur FastAPI (Moteur IA) ---
  static const String iaServerHost = 'affirmation-promogo-voice-search.hf.space';
  static const String wsBaseUrl = 'wss://$iaServerHost';
  static String getAnalyseAudioWs(String langue) => '$wsBaseUrl/ws/analyser-audio/$langue';

  // --- Serveur Django (Backend Principal) ---
  // DÉCOMMENTER LA LIGNE SUIVANTE POUR TESTER EN LOCAL SUR L'ÉMULATEUR
  // static const String djangoServerHost = '10.0.2.2';
  
  // DÉCOMMENTER LA LIGNE SUIVANTE POUR LA PRODUCTION (Génération de l'APK) OU UTILISER LES DONNÉES DU SERVEUR
  static const String djangoServerHost = '31.97.116.73';
  static const String djangoRootUrl = 'http://$djangoServerHost:8085';
  static const String djangoBaseUrl = '$djangoRootUrl/api';
  static const String djangoWsBaseUrl = 'ws://$djangoServerHost:8085';

  // Routes Authentification
  static const String sendOtpEndpoint = '$djangoBaseUrl/auth/otp/send/';
  static const String verifyOtpEndpoint = '$djangoBaseUrl/auth/otp/verify/';
  static const String registerEndpoint = '$djangoBaseUrl/auth/registration/';
  static const String loginEndpoint = '$djangoBaseUrl/auth/login/';
  static const String userMeEndpoint = '$djangoBaseUrl/auth/user/me/';
  static const String refreshTokenEndpoint = '$djangoBaseUrl/auth/token/refresh/';
  static const String categoriesEndpoint = '$djangoBaseUrl/categories/';
  static const String adsEndpoint = '$djangoBaseUrl/ads/';
  static const String searchAdsEndpoint = '${adsEndpoint}search/';
  static const String addAdEndpoint = '$djangoBaseUrl/ads/add/';
  static const String myAdsEndpoint = '$djangoBaseUrl/ads/me/';
  static const String subscriptionPlansEndpoint = '$djangoBaseUrl/subscription-plans/';
  static const String mySubscriptionsEndpoint = '$djangoBaseUrl/my-subscriptions/';
  static const String activeSubscriptionEndpoint = '$djangoBaseUrl/my-subscriptions/active/';
  static const String initializePaymentEndpoint = '$djangoBaseUrl/payments/initialize/';
  static const String verifyPaymentEndpoint = '$djangoBaseUrl/payments/verify/';
  static String getBulkPricesEndpoint(int adId) => '$djangoBaseUrl/ads/$adId/bulk-prices/';

  // Academy
  static const String academyCoursesEndpoint = '$djangoBaseUrl/academy/courses/';
  static const String academyTagsEndpoint = '$djangoBaseUrl/academy/tags/';
  static String getAcademyCourseDetailEndpoint(String id) => '$academyCoursesEndpoint$id/';

  // --- Serveur SRS (Streaming Vidéo) ---
  static const String srsHost = djangoServerHost;
  static String getRtmpPushUrl(String streamKey) => 'rtmp://$srsHost:1935/live/$streamKey';
  static String getHttpFlvPlayUrl(String streamKey) => 'http://$srsHost:8080/live/$streamKey.flv';
  static String getHlsPlayUrl(String streamKey) => 'http://$srsHost:8080/live/$streamKey.m3u8';

  // --- Endpoints Live Commerce ---
  static const String liveBaseEndpoint = '$djangoBaseUrl/live/';
  static const String createLiveEndpoint = '${liveBaseEndpoint}create/';
  static const String activeLivesEndpoint = '${liveBaseEndpoint}active/';
  static const String getAgoraTokenEndpoint = '${liveBaseEndpoint}agora-token/';
  static const String liveProductsEndpoint = '${liveBaseEndpoint}products';
  static String getAddProductsToLiveEndpoint(String liveId) => '$liveBaseEndpoint$liveId/add-products/';
  static String getUpdateLiveStatusEndpoint(String liveId) => '$liveBaseEndpoint$liveId/update-status/';
  static String getUpdateLiveProductEndpoint(String productId) => '${liveBaseEndpoint}product/$productId/update/';
  static String getLiveOrdersEndpoint(String liveId) => '$liveBaseEndpoint$liveId/orders/';
  static String getLiveChatHistoryEndpoint(String liveId) => '$liveBaseEndpoint$liveId/chat/';

  // --- Endpoints Chat (Messagerie) ---
  static const String chatRoomsEndpoint = '$djangoBaseUrl/chat/rooms/';
  static const String chatGetOrCreateRoomEndpoint = '$djangoBaseUrl/chat/rooms/get-or-create/';
  static String getChatMessagesEndpoint(int roomId) => '$djangoBaseUrl/chat/rooms/$roomId/messages/';
  static String getSendChatMessageEndpoint(int roomId) => '$djangoBaseUrl/chat/rooms/$roomId/messages/send/';
  static String getChatWebSocketUrl(int roomId) => '$djangoWsBaseUrl/ws/chat/$roomId/';
}
