import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:promogoai/ui/common/api_constants.dart';

class AuthService {
  static const String _keyAccessToken = 'secure_access_token';
  static const String _keyRefreshToken = 'secure_refresh_token';
  static const String _keyUserData = 'secure_user_data';

  final _secureStorage = const FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _userData;

  String? get accessToken => _accessToken;
  Map<String, dynamic>? get userData => _userData;

  /// Initialise le service en récupérant les tokens stockés de manière sécurisée
  Future<void> init() async {
    _accessToken = await _secureStorage.read(key: _keyAccessToken);
    _refreshToken = await _secureStorage.read(key: _keyRefreshToken);
    
    print("🛡️ [AuthService] Initialisation sécurisée...");
    print("🛡️ [AuthService] Access Token: ${_accessToken != null ? 'Présent (Chiffré)' : 'ABSENT'}");

    final userJson = await _secureStorage.read(key: _keyUserData);
    if (userJson != null) {
      _userData = jsonDecode(userJson);
      print("👤 [AuthService] User Data sécurisé chargé pour: ${_userData?['username']}");
    }
  }

  /// Sauvegarde les tokens et les infos utilisateur dans le stockage sécurisé
  Future<void> saveAuthData({
    required String access,
    required String refresh,
    required Map<String, dynamic> user,
  }) async {
    print("💾 [AuthService] Sauvegarde sécurisée des jetons...");
    _accessToken = access;
    _refreshToken = refresh;
    _userData = user;

    await _secureStorage.write(key: _keyAccessToken, value: access);
    await _secureStorage.write(key: _keyRefreshToken, value: refresh);
    await _secureStorage.write(key: _keyUserData, value: jsonEncode(user));
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
        await _secureStorage.write(key: _keyAccessToken, value: newAccess);
        print("🔄 [AuthService] Token rafraîchi avec succès (Stockage sécurisé mis à jour)");
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

  /// Déconnexion et nettoyage du stockage sécurisé
  Future<void> logout() async {
    print("🚪 [AuthService] Déconnexion et nettoyage sécurisé...");
    _accessToken = null;
    _refreshToken = null;
    _userData = null;

    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyRefreshToken);
    await _secureStorage.delete(key: _keyUserData);
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
        await _secureStorage.write(key: _keyUserData, value: jsonEncode(_userData));
        print("👤 [AuthService] Profil récupéré et sécurisé: ${_userData?['first_name']} (${_userData?['username']})");
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
