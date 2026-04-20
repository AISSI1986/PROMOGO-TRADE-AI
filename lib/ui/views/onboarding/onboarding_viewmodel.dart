import 'dart:async';
import 'package:stacked/stacked.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/material.dart';
import 'package:promogoai/services/local_storage_service.dart';

class OnboardingViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _localStorageService = locator<LocalStorageService>();
  final pageController = PageController();
  
  Timer? _autoPlayTimer;
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void init() {
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentIndex < 2) {
        pageController.animateToPage(
          _currentIndex + 1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      } else {
        // Stop autoplay on the last page
        timer.cancel();
      }
    });
  }

  void setIndex(int index) {
    _currentIndex = index;
    
    // Si l'utilisateur défile manuellement, on réinitialise le minuteur de 10 secondes
    // S'il est sur la dernière page, on arrête le défilement automatique
    if (_currentIndex < 2) {
      _startAutoPlay();
    } else {
      _autoPlayTimer?.cancel();
    }
    
    notifyListeners();
  }

  void onNextPage() {
    if (_currentIndex < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      navigateToHome();
    }
  }

  void onBackPage() {
    if (_currentIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() {
    navigateToHome();
  }

  void navigateToHome() async {
    await _localStorageService.setOnboardingComplete();
    _navigationService.replaceWithHomeView();
  }

  void navigateToLogin() async {
    await _localStorageService.setOnboardingComplete();
    _navigationService.replaceWithLoginView();
  }

  void navigateToRegister() async {
    await _localStorageService.setOnboardingComplete();
    _navigationService.replaceWithRegisterView();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    pageController.dispose();
    super.dispose();
  }
}
