import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'reglages_viewmodel.dart';

class ReglagesView extends StackedView<ReglagesViewModel> {
  const ReglagesView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, ReglagesViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('reglages.title'.tr(), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSettingItem(
            label: 'reglages.delivery'.tr(),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flag, size: 18, color: Colors.green), // Togo flag placeholder
                const SizedBox(width: 4),
                const Text('Togo (TG)', style: TextStyle(color: Colors.black54)),
                const Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
          ),
          _buildSettingItem(
            label: 'reglages.currency'.tr(),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(viewModel.getSelectedCurrency(context), style: const TextStyle(color: Colors.black54)),
                const Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
            onTap: () => _showCurrencyDialog(context, viewModel),
          ),
          _buildSettingItem(
            label: 'reglages.language'.tr(),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.locale.languageCode == 'fr' ? 'Français' : 
                  context.locale.languageCode == 'en' ? 'English' : 'العربية',
                  style: const TextStyle(color: Colors.black54),
                ),
                const Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
            onTap: () => _showLanguageDialog(context, viewModel),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('reglages.version'.tr(), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      const Text('26.8.0', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('reglages.update'.tr(), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          _buildSettingItem(label: 'reglages.legal_policies'.tr()),
        ],
      ),
    );
  }

  Widget _buildSettingItem({required String label, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
      ),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.black26),
        onTap: onTap ?? () {},
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, ReglagesViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('reglages.currency'.tr()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: viewModel.availableCurrencies.length,
            itemBuilder: (context, index) {
              final currency = viewModel.availableCurrencies[index];
              final isSelected = viewModel.getSelectedCurrency(context) == currency['code'];
              return ListTile(
                title: Text(
                  currency['name']!,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF2563EB)) : null,
                onTap: () {
                  viewModel.changeCurrency(currency['code']!);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, ReglagesViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('reglages.language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              onTap: () {
                viewModel.changeLanguage(context, 'fr');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                viewModel.changeLanguage(context, 'en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
              onTap: () {
                viewModel.changeLanguage(context, 'ar');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  ReglagesViewModel viewModelBuilder(BuildContext context) => ReglagesViewModel();
}
