import 'package:flutter/material.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:stacked_services/stacked_services.dart';

enum SnackbarType { success, warning, error }

void setupSnackbarUi() {
  final snackbarService = locator<SnackbarService>();

  // Style de Succès (Vert)
  snackbarService.registerCustomSnackbarConfig(
    variant: SnackbarType.success,
    config: SnackbarConfig(
      backgroundColor: kcSuccessColor,
      textColor: Colors.white,
      borderRadius: 8,
      messageTextAlign: TextAlign.center,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(15),
    ),
  );

  // Style d'Avertissement (Jaune/Or)
  snackbarService.registerCustomSnackbarConfig(
    variant: SnackbarType.warning,
    config: SnackbarConfig(
      backgroundColor: kcAccentColor,
      textColor: Colors.white,
      borderRadius: 8,
      messageTextAlign: TextAlign.center,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(15),
    ),
  );

  // Style d'Erreur (Rouge)
  snackbarService.registerCustomSnackbarConfig(
    variant: SnackbarType.error,
    config: SnackbarConfig(
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      borderRadius: 8,
      messageTextAlign: TextAlign.center,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(15),
    ),
  );
}
