import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'moi_viewmodel.dart';

class MoiView extends StackedView<MoiViewModel> {
  const MoiView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, MoiViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 150,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 10, bottom: 10),
          child: ElevatedButton(
            onPressed: viewModel.onConnectOrRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(
              'moi.connect'.tr(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: viewModel.navigateToSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSectionHeader('moi.characteristics'.tr(), showArrow: true),
            _buildCharacteristicsList(),
            const SizedBox(height: 16),
            _buildSectionHeader('moi.my_orders'.tr(), showArrow: true),
            const SizedBox(height: 16),
            _buildReferralBanner(),
            const SizedBox(height: 16),
            _buildListItem(
              icon: Icons.psychology_outlined,
              title: 'moi.sourcing_agent'.tr(),
            ),
            _buildListItem(
              icon: Icons.storefront_outlined,
              title: 'moi.become_seller'.tr(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showArrow = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          if (showArrow)
            const Icon(Icons.arrow_forward, color: Colors.black54, size: 20),
        ],
      ),
    );
  }

  Widget _buildCharacteristicsList() {
    final features = [
      {'icon': Icons.favorite_border, 'label': 'moi.favorites'.tr()},
      {'icon': Icons.history, 'label': 'moi.search_history'.tr()},
      {'icon': Icons.card_membership_outlined, 'label': 'moi.subscription'.tr(), 'badge': 'New'},
      {'icon': Icons.confirmation_number_outlined, 'label': 'moi.coupons'.tr()},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'moi.payment'.tr()},
      {'icon': Icons.receipt_long_outlined, 'label': 'moi.tax_info'.tr()},
      {'icon': Icons.layers_outlined, 'label': 'moi.membership'.tr()},
      {'icon': Icons.business_center_outlined, 'label': 'moi.start_selling'.tr()},
      {'icon': Icons.help_outline, 'label': 'moi.help_center'.tr()},
      {'icon': Icons.gavel_outlined, 'label': 'moi.legal'.tr()},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return _FeatureItem(
            icon: feature['icon'] as IconData,
            label: feature['label'] as String,
            badge: feature['badge'] as String?,
          );
        },
      ),
    );
  }

  Widget _buildReferralBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'moi.referral_title'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF795548),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'moi.referral_subtitle'.tr(),
                      style: const TextStyle(color: Color(0xFF795548), fontSize: 12),
                    ),
                    const Icon(Icons.chevron_right, size: 16, color: Color(0xFF795548)),
                  ],
                ),
              ],
            ),
          ),
          Image.network(
            'https://cdn-icons-png.flaticon.com/512/3135/3135715.png', // Placeholder for referral icon
            height: 40,
            width: 40,
            errorBuilder: (_, __, ___) => const Icon(Icons.people_outline, size: 40, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({required IconData icon, required String title}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
        onTap: () {},
      ),
    );
  }

  @override
  MoiViewModel viewModelBuilder(BuildContext context) => MoiViewModel();
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;

  const _FeatureItem({
    required this.icon,
    required this.label,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black54, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ],
          ),
          if (badge != null)
            Positioned(
              top: 15,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
