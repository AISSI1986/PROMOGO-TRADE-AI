import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'mode_ia_viewmodel.dart';

class ModeIaView extends StackedView<ModeIaViewModel> {
  const ModeIaView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ModeIaViewModel viewModel,
    Widget? child,
  ) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double bottomNavHeight = getBottomNavHeight(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            kcPrimaryColor.withOpacity(0.08),
            kcPrimaryColor.withOpacity(0.15),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // 1. Scrollable Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: (keyboardHeight > 0 ? keyboardHeight + 100 : bottomNavHeight + 120),
              ),
              child: Column(
                children: [
                  // History and Essai Gratuit
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.history, color: kcMediumGrey),
                        onPressed: () {},
                      ),
                      horizontalSpaceTiny,
                      PopupMenuButton<String>(
                        initialValue: viewModel.selectedLanguage,
                        onSelected: viewModel.setLanguage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: kcPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.language, size: 16, color: kcPrimaryColor),
                              horizontalSpaceTiny,
                              Text(
                                viewModel.selectedLanguage.toUpperCase(),
                                style: const TextStyle(
                                  color: kcPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'fra', child: Text('🇫🇷 Français')),
                          const PopupMenuItem(value: 'eng', child: Text('🇺🇸 English')),
                          const PopupMenuItem(value: 'hau', child: Text('🇳🇬 Haoussa')),
                          const PopupMenuItem(value: 'ewe', child: Text('🇹🇬 Ewe')),
                          const PopupMenuItem(value: 'mina', child: Text('🇹🇬 Mina')),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_outlined, size: 16, color: kcMediumGrey),
                            horizontalSpaceTiny,
                            const Text('10', style: TextStyle(fontWeight: FontWeight.bold)),
                            horizontalSpaceSmall,
                            Container(width: 1, height: 16, color: kcLightGrey),
                            horizontalSpaceSmall,
                            const Icon(Icons.auto_awesome, size: 16, color: kcPrimaryColor),
                            horizontalSpaceTiny,
                            Text(
                              'mode_ia.free_trial'.tr(),
                              style: const TextStyle(
                                color: kcPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 60),
                  // Main text
                  Text(
                    'mode_ia.main_text'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Action Buttons
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ActionButton(
                            icon: Icons.whatshot,
                            iconColor: Colors.deepOrange, 
                            text: 'mode_ia.btn_verified_search'.tr(),
                          ),
                          horizontalSpaceSmall,
                          _ActionButton(
                            text: 'mode_ia.btn_analyze'.tr(),
                          ),
                        ],
                      ),
                      verticalSpaceSmall,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ActionButton(
                            icon: Icons.auto_awesome,
                            iconColor: Colors.amber,
                            text: 'mode_ia.btn_design_ai'.tr(),
                          ),
                          horizontalSpaceSmall,
                          _ActionButton(
                            text: 'mode_ia.btn_product_search'.tr(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 2. Fixed Bottom Input Bar (Floating)
          Positioned(
            left: 0,
            right: 0,
            bottom: keyboardHeight > 0 ? keyboardHeight + 10 : bottomNavHeight + 10,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32.0),
                border: Border.all(color: kcPrimaryColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'mode_ia.input_hint'.tr(),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    maxLines: 4,
                    minLines: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.camera_alt_outlined, color: kcMediumGrey, size: 22),
                        onPressed: () {},
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kcPrimaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic_none, color: kcPrimaryColor, size: 22),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  ModeIaViewModel viewModelBuilder(BuildContext context) => ModeIaViewModel();
}

class _ActionButton extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String text;

  const _ActionButton({
    this.icon,
    this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: iconColor),
            horizontalSpaceTiny,
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kcDarkGreyColor,
            ),
          ),
        ],
      ),
    );
  }
}
