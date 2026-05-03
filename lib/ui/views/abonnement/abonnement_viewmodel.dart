import 'package:stacked/stacked.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/models/subscription_plan.dart';
import 'package:promogoai/services/subscription_service.dart';

class AbonnementViewModel extends BaseViewModel {
  final _subscriptionService = locator<SubscriptionService>();

  List<SubscriptionPlan> get plans => _subscriptionService.cachedPlans ?? [];

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  Future<void> init() async {
    if (plans.isEmpty) {
      await fetchPlans();
    }
  }

  Future<void> fetchPlans() async {
    _isFetching = true;
    notifyListeners();
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
