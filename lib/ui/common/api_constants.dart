class ApiConstants {
  // L'adresse IP de base de votre serveur backend.
  // En local avec l'émulateur Android : '10.0.2.2:8000'
  // En production : 'api.promogo.com' ou 'votre-ip:8000'
  // --- Serveur FastAPI (Moteur IA) ---
  static const String iaServerHost = 'affirmation-promogo-voice-search.hf.space';
  static const String wsBaseUrl = 'wss://$iaServerHost';
  static String getAnalyseAudioWs(String langue) => '$wsBaseUrl/ws/analyser-audio/$langue';

  // --- Serveur Django (Backend Principal) ---
  static const String djangoServerHost = '8c06-74-244-119-137.ngrok-free.app';
  static const String djangoBaseUrl = 'https://$djangoServerHost/api';

  // Routes Authentification
  static const String sendOtpEndpoint = '$djangoBaseUrl/auth/otp/send/';
  static const String verifyOtpEndpoint = '$djangoBaseUrl/auth/otp/verify/';
  static const String registerEndpoint = '$djangoBaseUrl/auth/registration/';
  static const String loginEndpoint = '$djangoBaseUrl/auth/login/';
  static const String userMeEndpoint = '$djangoBaseUrl/auth/user/me/';
  static const String refreshTokenEndpoint = '$djangoBaseUrl/auth/token/refresh/';
  static const String categoriesEndpoint = '$djangoBaseUrl/categories/';
  static const String addAdEndpoint = '$djangoBaseUrl/ads/add/';
  static const String myAdsEndpoint = '$djangoBaseUrl/ads/me/';
  static const String subscriptionPlansEndpoint = '$djangoBaseUrl/subscription-plans/';
  static const String mySubscriptionsEndpoint = '$djangoBaseUrl/my-subscriptions/';
  static String getBulkPricesEndpoint(int adId) => '$djangoBaseUrl/ads/$adId/bulk-prices/';
}

