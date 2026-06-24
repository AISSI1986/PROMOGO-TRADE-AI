import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:promogoai/services/auth_service.dart';

class PromogoFairViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();

  String _fullName = '';
  String _phone = '';
  String _email = '';
  String _country = 'Pays de provenance';
  String _companyName = '';
  String _standType = 'Petit'; // Default selection
  String _sector = "Secteur d'activité";
  bool _isSubmitting = false;

  String get fullName => _fullName;
  String get phone => _phone;
  String get email => _email;
  String get country => _country;
  String get companyName => _companyName;
  String get standType => _standType;
  String get sector => _sector;
  bool get isSubmitting => _isSubmitting;

  /// Available sectors for the bottom sheet selector
  List<String> get sectors => [
    'Agroalimentaire',
    'Technologie & Digital',
    'Textile & Mode',
    'Logistique & Transport',
    'Artisanat & Art',
    'Services & Conseil',
    'Santé & Bien-être',
    'Agriculture & Élevage',
    'Commerce & Distribution',
    'Finance & Assurance',
    'Éducation & Formation',
    'Autre',
  ];

  /// Auto-fill fields if the user is already logged in
  void initAutoFill() {
    final userData = _authService.userData;
    if (userData != null) {
      final firstName = (userData['first_name'] as String?) ?? '';
      final lastName = (userData['last_name'] as String?) ?? '';
      _fullName = '$firstName $lastName'.trim();
      _phone = (userData['call_number'] as String?) ?? '';
      _email = (userData['email'] as String?) ?? '';
      notifyListeners();
    }
  }

  void setFullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setCountry(String value) {
    _country = value;
    notifyListeners();
  }

  void setCompanyName(String value) {
    _companyName = value;
    notifyListeners();
  }

  void setStandType(String value) {
    _standType = value;
    notifyListeners();
  }

  void setSector(String value) {
    _sector = value;
    notifyListeners();
  }

  void goBack() {
    _navigationService.back();
  }

  /// Validates form and submits the pre-registration to the backend
  Future<Map<String, dynamic>?> preRegister() async {
    // --- Validation ---
    if (_fullName.trim().isEmpty) {
      return {'error': 'Veuillez saisir votre nom complet.'};
    }
    if (_phone.trim().isEmpty) {
      return {'error': 'Veuillez saisir votre numéro WhatsApp/Téléphone.'};
    }
    if (_email.trim().isEmpty || !_email.contains('@')) {
      return {'error': 'Veuillez saisir une adresse e-mail valide.'};
    }
    if (_country == 'Pays de provenance') {
      return {'error': 'Veuillez sélectionner votre pays de provenance.'};
    }
    if (_sector == "Secteur d'activité") {
      return {'error': "Veuillez sélectionner votre secteur d'activité."};
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final body = json.encode({
        'full_name': _fullName.trim(),
        'phone': _phone.trim(),
        'email': _email.trim(),
        'country': _country,
        'company_name': _companyName.trim(),
        'stand_type': _standType,
        'sector': _sector,
      });

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // Attach token if user is logged in
      final token = _authService.accessToken;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.djangoBaseUrl}/promogo-fair/register/'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final responseData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return {'success': true, 'data': responseData};
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        final errorMsg = errorData is Map
            ? errorData.values.first.toString()
            : 'Erreur de soumission. Veuillez réessayer.';
        return {'error': errorMsg};
      }
    } catch (e) {
      return {'error': 'Impossible de contacter le serveur. Vérifiez votre connexion internet.'};
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
