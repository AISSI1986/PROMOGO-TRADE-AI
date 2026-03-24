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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    verticalSpaceSmall,
                    // History and Essai Gratuit
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.history, color: kcMediumGrey),
                            onPressed: () {},
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
                    ),
                    
                    const Spacer(flex: 2),
                    
                    // Main text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'mode_ia.main_text'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                    ),
                    
                    const Spacer(flex: 3),
                    
                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
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
                    ),
                    
                    verticalSpaceLarge,
                    
                    // Bottom Input
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: kcPrimaryColor.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: kcPrimaryColor.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'mode_ia.input_hint'.tr(),
                              border: InputBorder.none,
                            ),
                            maxLines: 2,
                            minLines: 1,
                          ),
                          verticalSpaceSmall,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.camera_alt_outlined, color: kcMediumGrey),
                                onPressed: () {},
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: kcBackgroundColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.mic_none, color: kcDarkGreyColor),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
