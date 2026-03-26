import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class OtpSheet extends StatelessWidget {
  final Function(SheetResponse)? completer;
  final SheetRequest request;

  const OtpSheet({
    Key? key,
    this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<_OtpSheetViewModel>.reactive(
      viewModelBuilder: () => _OtpSheetViewModel(),
      builder: (context, viewModel, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MethodOption(
              title: 'Recevoir le code par WhatsApp',
              subtitle: 'Le code sera envoyé via WhatsApp',
              iconPath: 'assets/images/whatsapp_logo.png', // I'll use an icon for now
              icon: Icons.chat,
              color: const Color(0xFF25D366),
              isSelected: viewModel.selectedMethod == 'whatsapp',
              onTap: () => viewModel.setMethod('whatsapp'),
            ),
            verticalSpaceMedium,
            _MethodOption(
              title: 'Recevoir le code par SMS',
              subtitle: 'Le code sera envoyé par message texte',
              icon: Icons.sms,
              color: const Color(0xFF8D6E63),
              isSelected: viewModel.selectedMethod == 'sms',
              onTap: () => viewModel.setMethod('sms'),
            ),
            verticalSpaceLarge,
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => completer?.call(SheetResponse(confirmed: true, data: viewModel.selectedMethod)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00ACC1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Continuer', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final String? iconPath;

  const _MethodOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF00ACC1) : Colors.grey[200]!, width: 2),
          color: isSelected ? const Color(0xFF00ACC1).withOpacity(0.05) : Colors.grey[50],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            horizontalSpaceMedium,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF00ACC1))
            else
              Icon(Icons.radio_button_off, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}

class _OtpSheetViewModel extends BaseViewModel {
  String _selectedMethod = 'whatsapp';
  String get selectedMethod => _selectedMethod;

  void setMethod(String method) {
    _selectedMethod = method;
    notifyListeners();
  }
}
