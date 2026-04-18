import 'package:stacked/stacked.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:promogoai/services/settings_service.dart';
import 'package:country_picker/country_picker.dart';
import 'package:currency_picker/currency_picker.dart';

class LanguageViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _settingsService = locator<SettingsService>();

  String? _selectedLanguage;
  
  String getSelectedLanguage(BuildContext context) {
    return _selectedLanguage ?? context.locale.languageCode;
  }

  String get selectedCountry => _settingsService.selectedCountry;
  String get selectedCurrency => _settingsService.selectedCurrency;

  void selectLanguage(String langCode) {
    _selectedLanguage = langCode;
    notifyListeners();
  }

  void selectCountry(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        inputDecoration: InputDecoration(
          hintText: 'Rechercher un pays...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      onSelect: (Country country) {
        _settingsService.setSelectedCountry(country.name);
        notifyListeners();
      },
    );
  }

  void selectCurrency(BuildContext context) {
    showCurrencyPicker(
      context: context,
      onSelect: (Currency currency) {
        _settingsService.setSelectedCurrency('${currency.name} (${currency.code})');
        notifyListeners();
      },
    );
  }

  void onConfirm(BuildContext context) async {
    final langToUse = getSelectedLanguage(context);
    
    if (langToUse == 'fr') {
      await context.setLocale(const Locale('fr'));
    } else if (langToUse == 'en') {
      await context.setLocale(const Locale('en'));
    } else if (langToUse == 'ar') {
      await context.setLocale(const Locale('ar'));
    }
    
    _navigationService.replaceWithOnboardingView();
  }
}
