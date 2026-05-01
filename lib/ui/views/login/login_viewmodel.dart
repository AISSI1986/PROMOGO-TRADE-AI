import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:promogoai/services/auth_service.dart';
import 'package:promogoai/ui/common/api_constants.dart';

class LoginViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();
  final _snackbarService = locator<SnackbarService>();

  String _phoneNumber = '';
  String get phoneNumber => _phoneNumber;
  set phoneNumber(String val) {
    _phoneNumber = val;
    _phoneError = null;
    notifyListeners();
  }

  String phoneCountryCode = '233'; // Par défaut: Ghana
  String phoneIsoCode = 'gh';

  String _password = '';
  String get password => _password;
  set password(String val) {
    _password = val;
    _passwordError = null;
    notifyListeners();
  }

  String? _phoneError;
  String? get phoneError => _phoneError;

  String? _passwordError;
  String? get passwordError => _passwordError;

  bool get canLogin => phoneNumber.isNotEmpty && password.isNotEmpty;

  Future<void> login() async {
    _phoneError = null;
    _passwordError = null;

    if (phoneNumber.isEmpty) {
      _phoneError = "Le numéro de téléphone est requis";
      notifyListeners();
      return;
    }

    if (password.isEmpty) {
      _passwordError = "Le mot de passe est requis";
      notifyListeners();
      return;
    }

    setBusy(true);
    try {
      String cleanCountryCode = phoneCountryCode.replaceAll('+', '');
      String fullPhone = '+$cleanCountryCode$phoneNumber';

      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'call_number': fullPhone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Sauvegarde des jetons (on met un user vide pour l'instant car fetchUserProfile va le remplir)
        await _authService.saveAuthData(
          access: data['access'],
          refresh: data['refresh'],
          user: {},
        );

        // Récupération immédiate du profil utilisateur
        await _authService.fetchUserProfile();

        _navigationService.clearStackAndShow(Routes.homeView);
      } else {
        String errorMsg = "Identifiants incorrects. Veuillez réessayer.";
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
             errorMsg = errorData['non_field_errors']?.join(', ') ?? errorData['detail'] ?? errorMsg;
          }
        } catch (_) {}
        
        _snackbarService.showSnackbar(
          message: errorMsg,
          duration: const Duration(seconds: 6),
        );
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: "Erreur réseau. Vérifiez votre connexion.",
        duration: const Duration(seconds: 6),
      );
    } finally {
      setBusy(false);
    }
  }

  void goBack() {
    _navigationService.back();
  }

  void navigateToRegister() {
    _navigationService.navigateToRegisterView();
  }

  void navigateToForgotPassword() {
    // TODO: Implémenter la navigation vers la récupération de mot de passe
  }
}
