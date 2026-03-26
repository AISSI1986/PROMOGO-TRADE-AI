import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/services/settings_service.dart';
import 'package:country_picker/country_picker.dart';
import 'package:currency_picker/currency_picker.dart';

class SettingsSheet extends StatelessWidget {
  final Function(SheetResponse)? completer;
  final SheetRequest request;

  const SettingsSheet({
    Key? key,
    this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<_SettingsSheetViewModel>.reactive(
      viewModelBuilder: () => _SettingsSheetViewModel(),
      builder: (context, viewModel, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'reglages.title'.tr(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
                  ),
                  IconButton(
                    onPressed: () => completer?.call(SheetResponse(confirmed: true)),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 20, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              verticalSpaceMedium,
              _SettingSection(
                title: 'reglages.language'.tr(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _LanguageOption(
                        label: 'Français',
                        isSelected: context.locale.languageCode == 'fr',
                        onTap: () => viewModel.changeLanguage(context, 'fr'),
                      ),
                      horizontalSpaceSmall,
                      _LanguageOption(
                        label: 'English',
                        isSelected: context.locale.languageCode == 'en',
                        onTap: () => viewModel.changeLanguage(context, 'en'),
                      ),
                      horizontalSpaceSmall,
                      _LanguageOption(
                        label: 'العربية',
                        isSelected: context.locale.languageCode == 'ar',
                        onTap: () => viewModel.changeLanguage(context, 'ar'),
                      ),
                    ],
                  ),
                ),
              ),
              verticalSpaceMedium,
              _SettingSection(
                title: 'reglages.delivery'.tr(),
                child: InkWell(
                  onTap: () => viewModel.selectCountry(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.public, color: kcPrimaryColor, size: 20),
                        horizontalSpaceSmall,
                        Text(
                          viewModel.selectedCountry,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const Icon(Icons.search, color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              verticalSpaceMedium,
              _SettingSection(
                title: 'reglages.currency'.tr(),
                child: InkWell(
                  onTap: () => viewModel.selectCurrency(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on_outlined, color: kcPrimaryColor, size: 20),
                        horizontalSpaceSmall,
                        Text(
                          viewModel.selectedCurrency,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const Icon(Icons.search, color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              verticalSpaceLarge,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _SettingSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        verticalSpaceSmall,
        child,
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kcPrimaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected ? [BoxShadow(color: kcPrimaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SettingsSheetViewModel extends BaseViewModel {
  final _settingsService = locator<SettingsService>();

  String get selectedCountry => _settingsService.selectedCountry;
  String get selectedCurrency => _settingsService.selectedCurrency;

  void changeLanguage(BuildContext context, String code) {
    context.setLocale(Locale(code));
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

  void setCurrency(String currency) {
    _settingsService.setSelectedCurrency(currency);
    notifyListeners();
  }
}
