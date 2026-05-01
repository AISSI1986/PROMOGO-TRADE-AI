class ApiConstants {
  // L'adresse IP de base de votre serveur backend.
  // En local avec l'émulateur Android : '10.0.2.2:8000'
  // En production : 'api.promogo.com' ou 'votre-ip:8000'
  // --- Serveur FastAPI (Moteur IA) ---
  static const String iaServerHost = '10.0.2.2:8001';
  static const String wsBaseUrl = 'ws://$iaServerHost';
  static String getAnalyseAudioWs(String langue) => '$wsBaseUrl/ws/analyser-audio/$langue';

  // --- Serveur Django (Backend Principal) ---
  static const String djangoServerHost = '10.0.2.2:8000';
  static const String djangoBaseUrl = 'http://$djangoServerHost/api';

  // Routes Authentification
  static const String sendOtpEndpoint = '$djangoBaseUrl/auth/otp/send/';
  static const String verifyOtpEndpoint = '$djangoBaseUrl/auth/otp/verify/';
  static const String registerEndpoint = '$djangoBaseUrl/auth/registration/';
  static const String loginEndpoint = '$djangoBaseUrl/auth/login/';
  static const String userMeEndpoint = '$djangoBaseUrl/auth/user/me/';
  static const String refreshTokenEndpoint = '$djangoBaseUrl/auth/token/refresh/';
  static const String categoriesEndpoint = '$djangoBaseUrl/categories/';
  static const String addAdEndpoint = '$djangoBaseUrl/ads/add/';
}

