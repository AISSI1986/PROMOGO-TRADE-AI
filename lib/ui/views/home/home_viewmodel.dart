import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  int _currentTopTab = 1; // 1 = Produits
  int get currentTopTab => _currentTopTab;

  int _currentPromoIndex = 0;
  int get currentPromoIndex => _currentPromoIndex;

  bool _showPromotion = true;
  bool get showPromotion => _showPromotion;

  void togglePromotion(bool value) {
    _showPromotion = value;
    notifyListeners();
  }

  final PageController promoPageController = PageController(initialPage: 0);
  Timer? _promoTimer;
  final int _promoCount = 4; // Supporting up to 6 dynamically, here 4 items

  HomeViewModel() {
    _startPromoTimer();
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    promoPageController.dispose();
    super.dispose();
  }

  void _startPromoTimer() {
    _promoTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (promoPageController.hasClients) {
        int nextPage = _currentPromoIndex + 1;
        if (nextPage >= _promoCount) {
          nextPage = 0;
          promoPageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          promoPageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void onPromoPageChanged(int index) {
    _currentPromoIndex = index;
    notifyListeners();
  }

  void setTopTab(int index) {
    _currentTopTab = index;
    notifyListeners();
  }

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void onVoiceIAClicked() {
    print("Voice IA clicked!");
  }
}
