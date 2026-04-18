import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';

import 'language_viewmodel.dart';

class LanguageView extends StackedView<LanguageViewModel> {
  const LanguageView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LanguageViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kcPrimaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalSpaceLarge,
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: kcPrimaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.settings_suggest_rounded,
                              size: 50,
                              color: kcPrimaryColor,
                            ),
                          ),
                        ),
                        verticalSpaceMedium,
                        Center(
                          child: Text(
                            'language_selection.title'.tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: kcPrimaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        verticalSpaceSmall,
                        Center(
                          child: Text(
                            'language_selection.subtitle'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ),
                        verticalSpaceLarge,
                        
                        // Language Selection
                        Text(
                          'reglages.language'.tr(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kcPrimaryColor),
                        ),
                        verticalSpaceSmall,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _LanguageOption(
                                label: 'Français',
                                isSelected: viewModel.getSelectedLanguage(context) == 'fr',
                                onTap: () => viewModel.selectLanguage('fr'),
                              ),
                            ),
                            horizontalSpaceSmall,
                            Expanded(
                              child: _LanguageOption(
                                label: 'English',
                                isSelected: viewModel.getSelectedLanguage(context) == 'en',
                                onTap: () => viewModel.selectLanguage('en'),
                              ),
                            ),
                            horizontalSpaceSmall,
                            Expanded(
                              child: _LanguageOption(
                                label: 'العربية',
                                isSelected: viewModel.getSelectedLanguage(context) == 'ar',
                                onTap: () => viewModel.selectLanguage('ar'),
                              ),
                            ),
                          ],
                        ),
                        verticalSpaceMedium,

                        // Country Selection
                        Text(
                          'reglages.delivery'.tr(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kcPrimaryColor),
                        ),
                        verticalSpaceSmall,
                        InkWell(
                          onTap: () => viewModel.selectCountry(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.public, color: kcPrimaryColor, size: 24),
                                horizontalSpaceMedium,
                                Expanded(
                                  child: Text(
                                    viewModel.selectedCountry,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                              ],
                            ),
                          ),
                        ),
                        verticalSpaceMedium,

                        // Currency Selection
                        Text(
                          'reglages.currency'.tr(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kcPrimaryColor),
                        ),
                        verticalSpaceSmall,
                        InkWell(
                          onTap: () => viewModel.selectCurrency(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.monetization_on_outlined, color: kcPrimaryColor, size: 24),
                                horizontalSpaceMedium,
                                Expanded(
                                  child: Text(
                                    viewModel.selectedCurrency,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                              ],
                            ),
                          ),
                        ),
                        verticalSpaceLarge,
                      ],
                    ),
                  ),
                ),
                
                // Fixed Bottom Button
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: () => viewModel.onConfirm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                      shadowColor: kcPrimaryColor.withOpacity(0.4),
                    ),
                    child: Text(
                      'language_selection.btn_confirm'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                verticalSpaceMedium,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  LanguageViewModel viewModelBuilder(BuildContext context) => LanguageViewModel();
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
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? kcPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? kcPrimaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: kcPrimaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

