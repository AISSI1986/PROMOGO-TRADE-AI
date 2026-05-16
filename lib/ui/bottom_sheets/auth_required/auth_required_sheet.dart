import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:easy_localization/easy_localization.dart';

class AuthRequiredSheet extends StatelessWidget {
  final Function(SheetResponse)? completer;
  final SheetRequest request;
  const AuthRequiredSheet({Key? key, required this.completer, required this.request})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: kcCardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: kcTabIndicatorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_person_rounded,
              color: kcTabIndicatorColor,
              size: 32,
            ),
          ),
          verticalSpaceMedium,
          Text(
            request.title ?? 'auth_modal.title'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: kcPrimaryColor,
              fontFamily: 'Outfit',
            ),
          ),
          verticalSpaceSmall,
          Text(
            request.description ?? 'auth_modal.message'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: kcMediumGrey,
              height: 1.5,
            ),
          ),
          verticalSpaceLarge,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => completer!(SheetResponse(confirmed: false)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: kcVeryLightGrey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    request.secondaryButtonTitle ?? 'auth_modal.btn_cancel'.tr(),
                    style: const TextStyle(
                      color: kcMediumGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              horizontalSpaceSmall,
              Expanded(
                child: ElevatedButton(
                  onPressed: () => completer!(SheetResponse(confirmed: true)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    request.mainButtonTitle ?? 'auth_modal.btn_login'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          verticalSpaceMedium,
        ],
      ),
    );
  }
}
