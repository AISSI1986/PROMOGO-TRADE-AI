import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/app/app.locator.dart';

class NotificationService {
  final _authService = locator<AuthService>();

  /// Initialise Firebase Cloud Messaging et enregistre le Token
  Future<void> init() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // 1. Demander les permissions
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('🔔 [NotificationService] Permission accordée: ${settings.authorizationStatus}');

      // 2. Récupérer le token FCM
      final token = await messaging.getToken();
      if (token != null) {
        print('🔔 [NotificationService] FCM Token récupéré: $token');
        await registerTokenOnBackend(token);
      }

      // Écouter les rafraîchissements de token
      messaging.onTokenRefresh.listen((newToken) {
        print('🔔 [NotificationService] FCM Token rafraîchi: $newToken');
        registerTokenOnBackend(newToken);
      });
    } catch (e) {
      print('⚠️ [NotificationService] Erreur initialisation FCM: $e');
    }
  }

  /// Envoyer le Token FCM au backend
  Future<void> registerTokenOnBackend(String fcmToken) async {
    final accessToken = _authService.accessToken;
    if (accessToken == null) {
      print('⚠️ [NotificationService] Jeton FCM non enregistré: utilisateur non connecté');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.djangoBaseUrl}/users/fcm-token/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('✅ [NotificationService] FCM Token enregistré avec succès sur le backend.');
      } else {
        print('❌ [NotificationService] Échec enregistrement FCM Token: ${response.statusCode} | ${response.body}');
      }
    } catch (e) {
      print('⚠️ [NotificationService] Exception lors de l\'enregistrement du FCM Token: $e');
    }
  }
}
