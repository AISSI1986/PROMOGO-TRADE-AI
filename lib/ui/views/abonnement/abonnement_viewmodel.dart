import 'package:stacked/stacked.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/models/subscription_plan.dart';
import 'package:flutter/widgets.dart';
import 'package:promogoai/services/subscription_service.dart';
import 'package:promogoai/services/currency_service.dart';

class AbonnementViewModel extends BaseViewModel {
  final _subscriptionService = locator<SubscriptionService>();
  final _currencyService = locator<CurrencyService>();

  List<SubscriptionPlan> get plans => _subscriptionService.cachedPlans ?? [];

  String formatPrice(double price, BuildContext context) => _currencyService.formatPrice(price, context);

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  Future<void> init() async {
    // 1. Charger d'abord le cache persistant
    await _subscriptionService.loadCachedPlans();
    if (plans.isNotEmpty) {
      notifyListeners();
    }
    
    // 2. Tenter de rafraîchir les plans depuis le réseau
    await fetchPlans();
  }

  Future<void> fetchPlans() async {
    // On n'affiche le loader central que si on n'a rien à montrer
    if (plans.isEmpty) {
      _isFetching = true;
      notifyListeners();
    }
    
    try {
      await _subscriptionService.fetchPlans();
    } catch (e) {
      print('Error fetching plans: $e');
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }
}
