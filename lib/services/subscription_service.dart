import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:promogoai/models/subscription_plan.dart';
import 'package:promogoai/models/user_subscription.dart';
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:promogoai/services/local_storage_service.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/app/app.locator.dart';

class SubscriptionService {
  static const String _plansCacheKey = 'cached_subscription_plans.json';
  static const String _activeSubCacheKey = 'cached_active_subscription.json';
  
  final _localStorageService = locator<LocalStorageService>();
  final _authService = locator<AuthService>();
  
  List<SubscriptionPlan>? _cachedPlans;
  UserSubscription? _activeSubscription;

  List<SubscriptionPlan>? get cachedPlans => _cachedPlans;
  UserSubscription? get activeSubscription => _activeSubscription;

  // Headers helpers
  Map<String, String> get _headers {
    final token = _authService.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<SubscriptionPlan>> fetchPlans() async {
    try {
      print("📡 [SubscriptionService] Récupération des plans d'abonnement...");
      final response = await http.get(Uri.parse(ApiConstants.subscriptionPlansEndpoint)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        List<dynamic> data = [];

        if (jsonData is List) {
          data = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('results')) {
          data = jsonData['results'];
        }

        _cachedPlans = data.map((json) => SubscriptionPlan.fromJson(json)).toList();
        
        // Save to cache
        await _localStorageService.saveJson(_plansCacheKey, data);
        
        return _cachedPlans!;
      } else {
        print('❌ [SubscriptionService] Erreur API : ${response.statusCode}');
        return await loadCachedPlans();
      }
    } catch (e) {
      print('❌ [SubscriptionService] Error: $e');
      return await loadCachedPlans();
    }
  }

  Future<List<SubscriptionPlan>> loadCachedPlans() async {
    try {
      print("📦 [SubscriptionService] Chargement des plans depuis le cache local...");
      final cachedData = await _localStorageService.getJson(_plansCacheKey);
      if (cachedData != null && cachedData is List) {
        _cachedPlans = cachedData.map((json) => SubscriptionPlan.fromJson(json)).toList();
        print("✅ [SubscriptionService] ${_cachedPlans?.length} plans chargés depuis le cache.");
        return _cachedPlans!;
      }
    } catch (e) {
      print("❌ [SubscriptionService] Erreur chargement cache plans: $e");
    }
    return _cachedPlans ?? [];
  }

  /// Récupère l'abonnement actif de l'utilisateur connecté
  Future<UserSubscription> fetchActiveSubscription() async {
    try {
      print("📡 [SubscriptionService] Récupération de l'abonnement actif...");
      final response = await http.get(
        Uri.parse(ApiConstants.activeSubscriptionEndpoint),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _activeSubscription = UserSubscription.fromJson(data);
        
        // Save to cache
        await _localStorageService.saveJson(_activeSubCacheKey, data);
        return _activeSubscription!;
      } else {
        print('❌ [SubscriptionService] Erreur active subscription API : ${response.statusCode}');
        return await loadCachedActiveSubscription();
      }
    } catch (e) {
      print('❌ [SubscriptionService] Exception active subscription: $e');
      return await loadCachedActiveSubscription();
    }
  }

  Future<UserSubscription> loadCachedActiveSubscription() async {
    try {
      print("📦 [SubscriptionService] Chargement de l'abonnement actif depuis le cache local...");
      final cachedData = await _localStorageService.getJson(_activeSubCacheKey);
      if (cachedData != null && cachedData is Map<String, dynamic>) {
        _activeSubscription = UserSubscription.fromJson(cachedData);
        print("✅ [SubscriptionService] Abonnement actif chargé depuis le cache.");
        return _activeSubscription!;
      }
    } catch (e) {
      print("❌ [SubscriptionService] Erreur chargement cache abonnement actif: $e");
    }
    // Fallback to a mock BASIC representation if everything else fails
    return _activeSubscription ?? UserSubscription(
      statutPaiement: 'VALIDATED',
      gateway: 'none',
      maxAds: 1,
      activeAdsCount: 0,
      isActive: false,
    );
  }

  /// Initialise un paiement pour un pack d'abonnement
  Future<Map<String, dynamic>> initializePayment(int planId, String gateway) async {
    try {
      print("📡 [SubscriptionService] Initialisation du paiement plan=$planId via $gateway...");
      final response = await http.post(
        Uri.parse(ApiConstants.initializePaymentEndpoint),
        headers: _headers,
        body: json.encode({
          'plan_id': planId,
          'gateway': gateway,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("❌ [SubscriptionService] Erreur initialisation paiement : ${response.statusCode} | ${response.body}");
        return {
          'success': false,
          'error': 'Erreur serveur (${response.statusCode})',
        };
      }
    } catch (e) {
      print("❌ [SubscriptionService] Exception initialisation paiement : $e");
      return {
        'success': false,
        'error': 'Erreur réseau : $e',
      };
    }
  }

  /// Vérifie si la transaction de paiement a réussi
  Future<Map<String, dynamic>> verifyPayment(String reference) async {
    try {
      print("📡 [SubscriptionService] Vérification du paiement ref=$reference...");
      final response = await http.post(
        Uri.parse(ApiConstants.verifyPaymentEndpoint),
        headers: _headers,
        body: json.encode({
          'reference': reference,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = json.decode(response.body);
        // Si validation réussie, on recharge l'abonnement actif en arrière-plan
        if (data['success'] == true && data['status'] == 'success') {
          await fetchActiveSubscription();
        }
        return data;
      } else {
        print("❌ [SubscriptionService] Erreur vérification paiement : ${response.statusCode} | ${response.body}");
        return {
          'success': false,
          'error': 'Erreur serveur (${response.statusCode})',
        };
      }
    } catch (e) {
      print("❌ [SubscriptionService] Exception vérification paiement : $e");
      return {
        'success': false,
        'error': 'Erreur réseau : $e',
      };
    }
  }
}
