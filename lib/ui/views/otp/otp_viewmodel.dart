import 'dart:async';
import 'dart:convert';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:http/http.dart' as http;
import 'package:promogoai/ui/common/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  static const String _keyOtpTime = 'pending_otp_time';

  String phoneNumber = '';
  List<String> otpDigits = List.filled(6, ''); 

  int _timerSeconds = 600; 
  Timer? _timer;
  
  int get timerSeconds => _timerSeconds;

  String get formattedTime {
    int minutes = _timerSeconds ~/ 60;
    int seconds = _timerSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> init(String phone) async {
    String cleanPhone = phone.replaceAll('+', '');
    phoneNumber = '+$cleanPhone';
    
    // Calculer le temps restant réel
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_keyOtpTime);
    
    int initialSeconds = 600;
    if (timestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = (now - timestamp) ~/ 1000;
      initialSeconds = 600 - elapsed;
      if (initialSeconds < 0) initialSeconds = 0;
    }

    startTimer(initialSeconds: initialSeconds);
  }

  void startTimer({int initialSeconds = 600}) {
    _timerSeconds = initialSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        notifyListeners();
      }
    });
  }

  void updateDigit(int index, String value) {
    if (value.length > 1) {
      // Gestion du Coller (Paste)
      handlePaste(value);
      return;
    }
    otpDigits[index] = value;
    notifyListeners();
  }

  void handlePaste(String value) {
    String cleanCode = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCode.length >= 6) {
      for (int i = 0; i < 6; i++) {
        otpDigits[i] = cleanCode[i];
      }
      notifyListeners();
      verifyCode(); 
    }
  }

  Future<void> resendCode() async {
    setBusy(true);
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.sendOtpEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'call_number': phoneNumber}),
      );
      setBusy(false);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mettre à jour le timestamp persistant
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_keyOtpTime, DateTime.now().millisecondsSinceEpoch);
        
        startTimer();
        _snackbarService.showSnackbar(
          message: "Code renvoyé avec succès.",
          duration: const Duration(seconds: 6),
        );
      } else {
        _snackbarService.showSnackbar(
          message: "Erreur lors du renvoi du code.",
          duration: const Duration(seconds: 6),
        );
      }
    } catch (e) {
      setBusy(false);
      _snackbarService.showSnackbar(
        message: "Erreur de connexion.",
        duration: const Duration(seconds: 6),
      );
    }
  }

  Future<void> verifyCode() async {
    String otp = otpDigits.join('');
    if (otp.length < 6) return; 
    
    setBusy(true);
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyOtpEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'call_number': phoneNumber, 
          'otp_code': otp 
        }),
      );

      setBusy(false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _timer?.cancel();
        _navigationService.back(result: true); 
      } else {
        _snackbarService.showSnackbar(
          message: "Code OTP invalide.",
          duration: const Duration(seconds: 6),
        );
      }
    } catch (e) {
      setBusy(false);
      _snackbarService.showSnackbar(
        message: "Erreur de connexion.",
        duration: const Duration(seconds: 6),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void goBack() {
    _timer?.cancel();
    _navigationService.back(result: false);
  }
}
