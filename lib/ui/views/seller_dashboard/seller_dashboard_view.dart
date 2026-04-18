import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'seller_dashboard_viewmodel.dart';

class SellerDashboardView extends StackedView<SellerDashboardViewModel> {
  const SellerDashboardView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SellerDashboardViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kcTabIndicatorColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'seller.dashboard_title'.tr(),
          style: const TextStyle(
            color: kcPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade100, height: 1.0),
        ),
      ),
      body: _buildCompactContent(viewModel),
    );
  }

  Widget _buildCompactContent(SellerDashboardViewModel viewModel) {
    final dashboardItems = [
      {
        'icon': Icons.ads_click_outlined,
        'title': 'seller.my_ads'.tr(),
        'subtitle': 'seller.ads_count'.tr(namedArgs: {'count': viewModel.publicationsCount.toString()}),
        'onTap': viewModel.navigateToMyPublications,
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'title': 'seller.wallet'.tr(),
        'subtitle': '${viewModel.walletBalance.toStringAsFixed(2)} €',
        'onTap': () {},
      },
      {
        'icon': Icons.analytics_outlined,
        'title': 'seller.performance'.tr(),
        'onTap': () {},
      },
      {
        'icon': Icons.star_outline,
        'title': 'seller.premium'.tr(),
        'onTap': () {},
      },
      {
        'icon': Icons.notifications_none_outlined,
        'title': 'seller.notifications'.tr(),
        'badge': viewModel.pendingNotifications > 0 ? viewModel.pendingNotifications.toString() : null,
        'onTap': () {},
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: dashboardItems.length,
      itemBuilder: (context, index) {
        final item = dashboardItems[index];
        return _CompactDashboardCard(item: item);
      },
    );
  }

  @override
  SellerDashboardViewModel viewModelBuilder(BuildContext context) => SellerDashboardViewModel();
}

class _CompactDashboardCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _CompactDashboardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item['onTap'] as VoidCallback,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(item['icon'] as IconData, color: kcTabIndicatorColor, size: 28),
                  if (item['badge'] != null)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          item['badge'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: kcPrimaryColor,
                ),
              ),
              if (item.containsKey('subtitle')) ...[
                const SizedBox(height: 4),
                Text(
                  item['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
