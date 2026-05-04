import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:promogoai/ui/common/api_constants.dart';

class AuthService {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserData = 'user_data';

  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _userData;

  String? get accessToken => _accessToken;
  Map<String, dynamic>? get userData => _userData;

  /// Initialise le service en récupérant les tokens stockés
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_keyAccessToken);
    _refreshToken = prefs.getString(_keyRefreshToken);
    
    print("🔑 [AuthService] Initialisation...");
    print("🔑 [AuthService] Access Token: ${_accessToken != null ? 'Présent' : 'ABSENT'}");

    final userJson = prefs.getString(_keyUserData);
    if (userJson != null) {
      _userData = jsonDecode(userJson);
      print("👤 [AuthService] User Data chargé pour: ${_userData?['username']}");
    }
  }

  /// Sauvegarde les tokens et les infos utilisateur après login/register
  Future<void> saveAuthData({
    required String access,
    required String refresh,
    required Map<String, dynamic> user,
  }) async {
    print("💾 [AuthService] Sauvegarde des jetons...");
    _accessToken = access;
    _refreshToken = refresh;
    _userData = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, access);
    await prefs.setString(_keyRefreshToken, refresh);
    await prefs.setString(_keyUserData, jsonEncode(user));
  }

  /// Vérifie si l'utilisateur est actuellement connecté
  bool get isLogged => _accessToken != null;

  /// Rafraîchit le token d'accès en utilisant le refresh token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.refreshTokenEndpoint),
        body: {'refresh': _refreshToken},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access'];
        
        _accessToken = newAccess;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyAccessToken, newAccess);
        print("🔄 [AuthService] Token rafraîchi avec succès");
        return true;
      } else {
        print("🔄 [AuthService] Échec du rafraîchissement (Status: ${response.statusCode})");
        
        try {
          final data = jsonDecode(response.body);
          if (response.body.contains('user_blocked')) {
             print("🛡️ [AuthService] COMPTE BLOQUÉ détecté par le Backend.");
          }
        } catch (_) {}

        await logout();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    print("🚪 [AuthService] Déconnexion...");
    _accessToken = null;
    _refreshToken = null;
    _userData = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserData);
  }

  /// Récupère le profil complet de l'utilisateur depuis le Backend
  Future<bool> fetchUserProfile() async {
    if (_accessToken == null) {
      print("👤 [AuthService] Impossible de charger le profil: Access Token manquant");
      return false;
    }

    try {
      print("👤 [AuthService] Récupération du profil sur ${ApiConstants.userMeEndpoint}...");
      String tokenPreview = _accessToken != null && _accessToken!.length > 10 
          ? "${_accessToken!.substring(0, 10)}..." 
          : _accessToken ?? "NULL";
      print("👤 [AuthService] Token utilisé (début): $tokenPreview");
      
      final response = await http.get(
        Uri.parse(ApiConstants.userMeEndpoint),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _userData = jsonDecode(utf8.decode(response.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUserData, jsonEncode(_userData));
        print("👤 [AuthService] Profil récupéré: ${_userData?['first_name']} (${_userData?['username']})");
        return true;
      } else if (response.statusCode == 401) {
        print("👤 [AuthService] Session expirée (401). Tentative de rafraîchissement...");
        
        // Tentative de rafraîchissement automatique
        bool refreshed = await refreshAccessToken();
        
        if (refreshed) {
          print("🔄 [AuthService] Token rafraîchi, nouvelle tentative de récupération du profil...");
          // On retente l'appel avec le nouveau token
          return await fetchUserProfile(); 
        } else {
          print("❌ [AuthService] Impossible de rafraîchir la session. Déconnexion forcée.");
          await logout();
          return false;
        }
      } else {
        print("👤 [AuthService] Erreur lors de la récupération du profil (Status: ${response.statusCode})");
        print("👤 [AuthService] Réponse: ${response.body}");
        return false;
      }
    } catch (e) {
      print("👤 [AuthService] Erreur réseau: $e");
      return false;
    }
  }
}
