import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:promogoai/models/subscription_plan.dart';
import 'package:promogoai/ui/common/api_constants.dart';

class SubscriptionService {
  List<SubscriptionPlan>? _cachedPlans;

  List<SubscriptionPlan>? get cachedPlans => _cachedPlans;

  Future<List<SubscriptionPlan>> fetchPlans() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.subscriptionPlansEndpoint));

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        List<dynamic> data = [];

        if (jsonData is List) {
          data = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('results')) {
          data = jsonData['results'];
        }

        _cachedPlans = data.map((json) => SubscriptionPlan.fromJson(json)).toList();
        return _cachedPlans!;
      } else {
        throw Exception('Erreur lors du chargement des plans');
      }
    } catch (e) {
      print('❌ [SubscriptionService] Error: $e');
      rethrow;
    }
  }
}
