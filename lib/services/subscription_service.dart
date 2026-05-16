import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:promogoai/models/subscription_plan.dart';
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:promogoai/services/local_storage_service.dart';
import 'package:promogoai/app/app.locator.dart';

class SubscriptionService {
  static const String _plansCacheKey = 'cached_subscription_plans.json';
  final _localStorageService = locator<LocalStorageService>();
  List<SubscriptionPlan>? _cachedPlans;

  List<SubscriptionPlan>? get cachedPlans => _cachedPlans;

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
}
