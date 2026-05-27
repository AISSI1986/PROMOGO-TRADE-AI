import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/services/local_storage_service.dart';
import 'package:promogoai/app/app.locator.dart';

class CurrencyService {
  static const String _ratesCacheKey = 'cached_exchange_rates.json';
  static const String _selectedCurrencyKey = 'user_selected_currency.txt';
  
  final _localStorageService = locator<LocalStorageService>();
  Map<String, dynamic>? _rates;
  String? _selectedCurrency;

  Map<String, dynamic>? get rates => _rates;

  Future<void> init() async {
    await loadCachedRates();
    await _loadSelectedCurrency();
    fetchRates(); // Récupération en arrière-plan sans bloquer l'UI
  }

  Future<void> _loadSelectedCurrency() async {
    try {
      final cur = await _localStorageService.getData(_selectedCurrencyKey);
      if (cur != null && cur.isNotEmpty) {
        _selectedCurrency = cur;
        print("📦 [CurrencyService] Devise utilisateur chargée : $_selectedCurrency");
      }
    } catch (e) {
      print("❌ [CurrencyService] Erreur chargement devise: $e");
    }
  }

  Future<void> setCurrency(String currencyCode) async {
    _selectedCurrency = currencyCode;
    await _localStorageService.saveData(_selectedCurrencyKey, currencyCode);
    print("✅ [CurrencyService] Nouvelle devise enregistrée : $currencyCode");
  }

  String currentCurrency(BuildContext context) {
    if (_selectedCurrency != null) {
      return _selectedCurrency!;
    }
    // Comportement par défaut selon la langue si l'utilisateur n'a rien forcé
    final lang = context.locale.languageCode;
    return lang == 'fr' ? 'XOF' : 'GHS';
  }

  Future<void> fetchRates() async {
    try {
      print("📡 [CurrencyService] Récupération des taux de change en direct...");
      final response = await http.get(Uri.parse('https://open.er-api.com/v6/latest/GHS')).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['rates'] != null) {
          _rates = data['rates'];
          await _localStorageService.saveJson(_ratesCacheKey, _rates);
          print("✅ [CurrencyService] Taux de change mis à jour avec succès.");
        }
      }
    } catch (e) {
      print('⚠️ [CurrencyService] Mode hors-ligne ou erreur API: $e. Utilisation du cache local.');
    }
  }

  Future<void> loadCachedRates() async {
    try {
      final cached = await _localStorageService.getJson(_ratesCacheKey);
      if (cached != null && cached is Map<String, dynamic>) {
        _rates = cached;
        print("📦 [CurrencyService] Taux de change chargés depuis le cache local.");
      }
    } catch (e) {
      print("❌ [CurrencyService] Erreur chargement cache: $e");
    }
  }

  double convertGhsTo(double amountInGhs, String targetCurrency) {
    if (amountInGhs <= 0) return 0.0;
    if (targetCurrency == 'GHS') return amountInGhs;
    
    double rate = 45.0; // Taux de repli par défaut pour XOF (F CFA) en mode hors-ligne sans cache
    if (targetCurrency == 'USD') rate = 0.071;
    if (targetCurrency == 'EUR') rate = 0.065;
    if (targetCurrency == 'NGN') rate = 110.0;
    if (targetCurrency == 'AED') rate = 0.26;
    if (targetCurrency == 'SAR') rate = 0.27;
    if (targetCurrency == 'GBP') rate = 0.055;
    if (targetCurrency == 'CAD') rate = 0.098;
    if (targetCurrency == 'ZAR') rate = 1.30;

    if (_rates != null && _rates![targetCurrency] != null) {
      rate = (_rates![targetCurrency] as num).toDouble();
    }

    return amountInGhs * rate;
  }

  String formatPrice(double priceInGhs, BuildContext context) {
    if (priceInGhs <= 0) return "0 GHS";

    final target = currentCurrency(context);

    if (target == 'GHS') {
      return "${priceInGhs.toInt()} GHS";
    } else if (target == 'XOF' || target == 'XAF') {
      final xofAmount = convertGhsTo(priceInGhs, target);
      // Arrondi commercial élégant au centime près (ex: 9000 F CFA au lieu de 8974 F CFA)
      final rounded = (xofAmount / 100).round() * 100;
      return "${rounded > 0 ? rounded : xofAmount.round()} F CFA";
    } else {
      final amount = convertGhsTo(priceInGhs, target);
      // Arrondi pour les autres devises (ex: 15 USD ou 15.5 USD)
      return "${amount.toStringAsFixed(1).replaceFirst('.0', '')} $target";
    }
  }
}
