import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';

class PremiumDialog extends StatelessWidget {
  final String title;
  final String description;
  final String buttonTitle;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const PremiumDialog({
    super.key,
    required this.title,
    required this.description,
    required this.buttonTitle,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, color: kcPrimaryColor, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  if (onCancel != null)
                    Expanded(
                      child: TextButton(
                        onPressed: onCancel,
                        child: Text(
                          "Annuler",
                          style: TextStyle(color: Colors.white.withOpacity(0.6)),
                        ),
                      ),
                    ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        buttonTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showPremiumDialog(
  BuildContext context, {
  required String title,
  required String description,
  required String buttonTitle,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => PremiumDialog(
      title: title,
      description: description,
      buttonTitle: buttonTitle,
      onConfirm: () {
        Navigator.pop(context);
        onConfirm();
      },
      onCancel: onCancel != null
          ? () {
              Navigator.pop(context);
              onCancel();
            }
          : () => Navigator.pop(context),
    ),
  );
}
