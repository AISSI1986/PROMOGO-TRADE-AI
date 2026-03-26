import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';
import 'package:promogoai/app/app.bottomsheets.dart';

class RegisterViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  
  int _currentStep = 0;
  int get currentStep => _currentStep;

  final PageController pageController = PageController();

  // Registration Data
  String firstName = '';
  String lastName = '';
  String nationality = 'Togolaise';
  String nationalityCode = 'tg';
  String gender = 'Homme'; // Homme / Femme
  String profession = '';
  String phoneNumber = '';
  String phoneCountryCode = '228';
  String phoneIsoCode = 'tg';
  String password = '';
  String confirmPassword = '';

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  Future<void> nextStep() async {
    if (_currentStep == 4) {
      // Phone step - show OTP method selection
      final response = await _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.otp,
      );

      if (response?.confirmed == true) {
        // Navigate to OtpView for verification
        final verified = await _navigationService.navigateToOtpView(
          phoneNumber: '$phoneCountryCode$phoneNumber',
        );

        if (verified == true) {
          _proceedToNext();
        }
      }
      return;
    }

    _proceedToNext();
  }

  void _proceedToNext() {
    if (_currentStep < 5) {
      _currentStep++;
      pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    } else {
      // Finalize registration
      _navigationService.clearStackAndShow(Routes.homeView);
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    } else {
      _navigationService.back();
    }
  }

  void updateGender(String? value) {
    if (value != null) {
      gender = value;
      notifyListeners();
    }
  }

  void navigateToLogin() {
    _navigationService.back();
  }
}
