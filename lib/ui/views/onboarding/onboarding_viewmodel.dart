import 'dart:async';
import 'package:stacked/stacked.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/material.dart';
import 'package:promogoai/app/app.bottomsheets.dart';

class OnboardingViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final pageController = PageController();
  Timer? _timer;
  
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  OnboardingViewModel() {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (_currentIndex < 2) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> showSettings() async {
    _timer?.cancel();
    await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.settings,
    );
    _startTimer();
  }

  void onNextPage() {
    _startTimer(); // Restart the 7-second timer on interaction
    if (_currentIndex < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      navigateToHome();
    }
  }

  void skip() {
    _timer?.cancel();
    navigateToHome();
  }

  void navigateToHome() {
    _navigationService.replaceWithHomeView();
  }

  @override
  void dispose() {
    _timer?.cancel();
    pageController.dispose();
    super.dispose();
  }
}
