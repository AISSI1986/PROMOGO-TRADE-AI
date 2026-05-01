import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';
import 'package:promogoai/app/app.bottomsheets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/services/local_storage_service.dart';
import 'package:promogoai/ui/common/setup_snackbar_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _snackbarService = locator<SnackbarService>();
  final _localStorageService = locator<LocalStorageService>();
  final _authService = locator<AuthService>();

  // Clés pour la persistance OTP
  static const String _keyOtpPhone = 'pending_otp_phone';
  static const String _keyOtpTime = 'pending_otp_time';
  
  int _currentStep = 0;
  int get currentStep => _currentStep;

  final PageController pageController = PageController();

  // Registration Data
  String firstName = '';
  String lastName = '';
  String nationality = 'Ghana';
  String nationalityCode = 'gh';
  String gender = 'Homme'; 
  String profession = '';
  String phoneNumber = '';
  String phoneCountryCode = '233';
  String phoneIsoCode = 'gh';
  String password = '';
  String confirmPassword = '';
  String email = '';
  String adresse = '';
  bool isSeller = false;

  // Validation State
  bool hasPhoneError = false;
  String phoneErrorMessage = '';

  // Controllers pour la persistance visuelle
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final adresseController = TextEditingController();
  final professionController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  void init() {
    loadDraft();
    _checkPendingOtp();
  }

  Future<void> _checkPendingOtp() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingPhone = prefs.getString(_keyOtpPhone);
    final timestamp = prefs.getInt(_keyOtpTime);

    if (pendingPhone != null && timestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = (now - timestamp) / 1000; // secondes

      if (diff < 600) { // Moins de 10 minutes
        print("⏳ [RegisterViewModel] OTP en cours pour $pendingPhone. Redirection...");
        _navigationService.navigateToOtpView(phoneNumber: pendingPhone);
      } else {
        // Expiré, on nettoie
        await prefs.remove(_keyOtpPhone);
        await prefs.remove(_keyOtpTime);
      }
    }
  }

  // --- SAUVEGARDE / RÉCUPÉRATION DES DONNÉES ---
  static const String _draftFileName = 'registration_draft.json';

  Future<void> saveDraft() async {
    final draft = {
      'firstName': firstName,
      'lastName': lastName,
      'nationality': nationality,
      'nationalityCode': nationalityCode,
      'gender': gender,
      'profession': profession,
      'phoneNumber': phoneNumber,
      'phoneCountryCode': phoneCountryCode,
      'phoneIsoCode': phoneIsoCode,
      'email': email,
      'adresse': adresse,
      'isSeller': isSeller,
    };
    await _localStorageService.saveData(_draftFileName, jsonEncode(draft));
  }

  Future<void> loadDraft() async {
    final data = await _localStorageService.getData(_draftFileName);
    if (data != null) {
      try {
        final draft = jsonDecode(data);
        firstName = draft['firstName'] ?? '';
        lastName = draft['lastName'] ?? '';
        nationality = draft['nationality'] ?? 'Ghana';
        nationalityCode = draft['nationalityCode'] ?? 'gh';
        gender = draft['gender'] ?? 'Homme';
        profession = draft['profession'] ?? '';
        phoneNumber = draft['phoneNumber'] ?? '';
        phoneCountryCode = draft['phoneCountryCode'] ?? '233';
        phoneIsoCode = draft['phoneIsoCode'] ?? 'gh';
        email = draft['email'] ?? '';
        adresse = draft['adresse'] ?? '';
        isSeller = draft['isSeller'] ?? false;

        // Mise à jour des controllers
        firstNameController.text = firstName;
        lastNameController.text = lastName;
        emailController.text = email;
        adresseController.text = adresse;
        professionController.text = profession;
        phoneController.text = phoneNumber;
        passwordController.text = password;
        confirmPasswordController.text = confirmPassword;

        notifyListeners();
      } catch (e) {
        print("Error loading draft: $e");
      }
    }
  }

  void updateField() {
    notifyListeners();
    saveDraft();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void updateRole(bool seller) {
    isSeller = seller;
    updateField();
  }

  Future<void> nextStep() async {
    if (_currentStep == 0) {
      if (phoneNumber.trim().isEmpty) {
        hasPhoneError = true;
        phoneErrorMessage = 'Veuillez entrer un numéro de téléphone valide.';
        notifyListeners();
        return;
      }
      
      hasPhoneError = false;
      notifyListeners();

      final otpResponse = await _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.otp,
      );

      if (otpResponse?.confirmed != true) return;

      String method = otpResponse?.data ?? "sms";
      
      setBusy(true);
      try {
        String cleanCountryCode = phoneCountryCode.replaceAll('+', '');
        String fullPhone = '+$cleanCountryCode$phoneNumber';
        
        final response = await http.post(
          Uri.parse(ApiConstants.sendOtpEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'call_number': fullPhone,
            'method': method, 
          }),
        );

        setBusy(false);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // SAUVEGARDE DE L'ÉTAT OTP
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyOtpPhone, fullPhone);
          await prefs.setInt(_keyOtpTime, DateTime.now().millisecondsSinceEpoch);

          final verified = await _navigationService.navigateToOtpView(
            phoneNumber: fullPhone,
          );

          if (verified == true) {
            // Succès : on nettoie la mémoire OTP
            await prefs.remove(_keyOtpPhone);
            await prefs.remove(_keyOtpTime);
            _proceedToNext();
          }
        } else {
          _snackbarService.showCustomSnackBar(
            message: "Erreur ${response.statusCode} : Vérifiez le format du numéro.",
            variant: SnackbarType.error,
          );
        }
      } catch (e) {
        setBusy(false);
        _snackbarService.showCustomSnackBar(
          message: "Erreur de connexion au serveur.",
          variant: SnackbarType.error,
        );
      }
      return;
    }

    if (_currentStep == 1) {
      await _finalizeRegistration();
      return;
    }

    _proceedToNext();
  }

  Future<void> _finalizeRegistration() async {
    clearErrors();
    if (password != confirmPassword) {
      _snackbarService.showSnackbar(
        message: "Les mots de passe ne correspondent pas.",
        duration: const Duration(seconds: 6),
      );
      return;
    }

    setBusy(true);
    try {
      String cleanCountryCode = phoneCountryCode.replaceAll('+', '');
      String fullPhone = '+$cleanCountryCode$phoneNumber';
      
      String civiliteValue = (gender == 'Homme') ? 'M.' : 'Mme.';
      String userTypeValue = isSeller ? 'seller' : 'custumer';

      final response = await http.post(
        Uri.parse(ApiConstants.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': fullPhone, // Utilisation du tel car le backend refuse le vide
          'email': email,
          'password1': password,
          'password2': confirmPassword,
          'first_name': firstName,
          'last_name': lastName,
          'call_number': fullPhone,
          'adresse': adresse.isEmpty ? "Abidjan, Côte d'Ivoire" : adresse,
          'nationality': nationality,
          'civilite': civiliteValue,
          'profession': profession,
          'user_type': userTypeValue,
        }),
      );

      setBusy(false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Nettoyage du brouillon après succès
        await _localStorageService.clearData(_draftFileName);

        final authService = locator<AuthService>();
        await authService.saveAuthData(
          access: data['access'],
          refresh: data['refresh'],
          user: {}, // Initialement vide car Django ne le renvoie plus
        );

        // --- NOUVEAU : On récupère les vraies infos juste après ---
        await authService.fetchUserProfile();

        _navigationService.clearStackAndShow(Routes.homeView);
      } else {
        String errorMsg = "Erreur lors de l'inscription.";
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.isNotEmpty) {
            // Récupère TOUS les messages d'erreur et les joint
            List<String> allErrors = [];
            errorData.forEach((key, value) {
              if (value is List) {
                allErrors.add("$key: ${value.join(', ')}");
              } else {
                allErrors.add("$key: $value");
              }
            });
            errorMsg = allErrors.join("\n");
          }
        } catch (e) {
          errorMsg = "Erreur ${response.statusCode} : Inscription échouée.";
        }
        
        _snackbarService.showCustomSnackBar(
          message: errorMsg,
          variant: SnackbarType.error,
        );
      }
    } catch (e) {
      setBusy(false);
      _snackbarService.showCustomSnackBar(
        message: "Erreur de connexion.",
        variant: SnackbarType.error,
      );
    }
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
      updateField();
    }
  }

  void navigateToLogin() {
    _navigationService.back();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    adresseController.dispose();
    professionController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
