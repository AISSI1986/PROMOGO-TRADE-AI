import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/services/currency_service.dart';

class ReglagesViewModel extends BaseViewModel {
  final _currencyService = locator<CurrencyService>();

  String getSelectedCurrency(BuildContext context) => _currencyService.currentCurrency(context);

  final List<Map<String, String>> availableCurrencies = [
    {'code': 'GHS', 'name': 'Cedi Ghanéen (GHS)'},
    {'code': 'XOF', 'name': 'Franc CFA UEMOA (XOF)'},
    {'code': 'XAF', 'name': 'Franc CFA CEMAC (XAF)'},
    {'code': 'USD', 'name': 'Dollar Américain (USD)'},
    {'code': 'EUR', 'name': 'Euro (EUR)'},
    {'code': 'NGN', 'name': 'Naira Nigérian (NGN)'},
    {'code': 'AED', 'name': 'Dirham Émirats (AED)'},
    {'code': 'SAR', 'name': 'Riyal Saoudien (SAR)'},
    {'code': 'GBP', 'name': 'Livre Sterling (GBP)'},
    {'code': 'CAD', 'name': 'Dollar Canadien (CAD)'},
    {'code': 'ZAR', 'name': 'Rand Sud-Africain (ZAR)'},
  ];

  Future<void> changeCurrency(String currencyCode) async {
    await _currencyService.setCurrency(currencyCode);
    notifyListeners();
  }

  void changeLanguage(BuildContext context, String langCode) {
    context.setLocale(Locale(langCode));
    notifyListeners();
  }
}

