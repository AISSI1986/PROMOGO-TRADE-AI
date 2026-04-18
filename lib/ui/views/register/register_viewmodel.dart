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
  String nationality = 'Ghana';

  String nationalityCode = 'gh';
  String gender = 'Homme'; // Homme / Femme
  String profession = '';
  String phoneNumber = '';
  String phoneCountryCode = '233';
  String phoneIsoCode = 'gh';
  String password = '';
  String confirmPassword = '';

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  Future<void> nextStep() async {
    // Étape 0 : Numéro de téléphone -> OTP
    if (_currentStep == 0) {
      final response = await _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.otp,
      );

      if (response?.confirmed == true) {
        final verified = await _navigationService.navigateToOtpView(
          phoneNumber: '$phoneCountryCode$phoneNumber',
        );

        if (verified == true) {
          _proceedToNext();
        }
      }
      return;
    }

    // Autres étapes (Info personnelles, Mot de passe)
    _proceedToNext();
  }

  void _proceedToNext() {
    if (_currentStep < 1) {
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
