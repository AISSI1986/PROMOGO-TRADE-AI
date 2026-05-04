import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'moi_viewmodel.dart';

class MoiView extends StackedView<MoiViewModel> {
  final VoidCallback? onBack;
  const MoiView({Key? key, this.onBack}) : super(key: key);

  @override
  Widget builder(BuildContext context, MoiViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: onBack != null 
          ? IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: kcTabIndicatorColor,
                size: 20,
              ),
            )
          : null,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined, color: kcTabIndicatorColor),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: kcTabIndicatorColor),
            onPressed: viewModel.navigateToSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Profil Premium
            _buildProfileHeader(context, viewModel),


            // 3. Section Caractéristiques / Outils
            _buildSectionCard(
              title: 'moi.characteristics'.tr(),
              child: _buildCharacteristicsList(viewModel),
            ),

            // 4. Section Services & Paramètres
            _buildSectionCard(
              title: 'moi.support_menu'.tr(),
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildListItem(
                    icon: Icons.support_agent_outlined,
                    title: 'moi.support_menu'.tr(),
                    onTap: viewModel.navigateToSupport,
                  ),
                  _buildListItem(
                    icon: Icons.storefront_outlined,
                    title: 'moi.become_seller'.tr(),
                    onTap: viewModel.navigateToSellerKyc,
                  ),
                  _buildListItem(
                    icon: Icons.dashboard_outlined,
                    title: 'seller.dashboard_title'.tr(),
                    onTap: viewModel.navigateToSellerDashboard,
                  ),
                ],
              ),
            ),

            // 5. Action de déconnexion (Stand-alone en bas)
            if (viewModel.isLogged)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Center(
                  child: TextButton.icon(
                    onPressed: viewModel.logout,
                    icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                    label: Text(
                      'moi.logout'.tr(),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, MoiViewModel viewModel) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 16, 20, isSmallScreen ? 24 : 35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: isSmallScreen ? 55 : 70,
            height: isSmallScreen ? 55 : 70,
            decoration: BoxDecoration(
              color: kcVeryLightGrey,
              shape: BoxShape.circle,
              border: Border.all(color: kcPrimaryColor.withOpacity(0.1), width: 2),
            ),
            child: viewModel.isLogged 
              ? Center(
                  child: Text(
                    viewModel.userInitials,
                    style: TextStyle(
                      color: kcPrimaryColor,
                      fontSize: isSmallScreen ? 20 : 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Icon(Icons.person, color: kcMediumGrey, size: isSmallScreen ? 30 : 40),
          ),
          const SizedBox(width: 12),
          
          // Texte (Bienvenue + Sous-titre)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.isLogged 
                    ? 'moi.welcome_logged'.tr(args: [viewModel.userName]) 
                    : 'moi.welcome'.tr(),
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, fontSize: 18, max: 20),
                    fontWeight: FontWeight.w900,
                    color: kcPrimaryColor,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.isLogged 
                    ? 'moi.welcome_subtitle_logged'.tr()
                    : 'moi.welcome_subtitle'.tr(),
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, fontSize: 13, max: 14), 
                    color: kcMediumGrey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),

          // Bouton Se Connecter (Seulement si NON connecté)
          if (!viewModel.isLogged)
            Flexible(
              flex: 0,
              child: ElevatedButton(
                onPressed: viewModel.onConnectOrRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'moi.connect'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    bool showArrow = false,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: kcPrimaryColor,
                  ),
                ),
                if (showArrow)
                  const Icon(Icons.chevron_right, color: kcMediumGrey, size: 20),
              ],
            ),
          ),
          Padding(
            padding: padding ?? const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: child,
          ),
        ],
      ),
    );
  }


  Widget _buildCharacteristicsList(MoiViewModel viewModel) {
    final features = [
      {'icon': Icons.bookmark_added_outlined, 'label': 'moi.saved'.tr()},
      {'icon': Icons.subscriptions_outlined, 'label': 'moi.subscription'.tr()},
      {'icon': Icons.history, 'label': 'moi.search_history'.tr()},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'moi.payment'.tr()},
    ];


    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return GestureDetector(
            onTap: () {
              if (feature['label'] == 'moi.saved'.tr()) {
                viewModel.navigateToSaved();
              } else if (feature['label'] == 'moi.subscription'.tr()) {
                viewModel.navigateToAbonnement();
              }
            },
            child: _FeatureItem(
              icon: feature['icon'] as IconData,
              label: feature['label'] as String,
              badge: feature['badge'] as String?,
            ),
          );
        },
      ),
    );
  }


  Widget _buildListItem({
    required IconData icon, 
    required String title, 
    Color? color,
    bool showArrow = true,
    VoidCallback? onTap
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? kcTabIndicatorColor, size: 22),
      title: Text(
        title, 
        style: TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.w600, 
          color: color ?? kcPrimaryColor
        )
      ),
      trailing: showArrow 
        ? const Icon(Icons.chevron_right, size: 18, color: kcMediumGrey)
        : null,
      onTap: onTap ?? () {},
    );
  }

  @override
  MoiViewModel viewModelBuilder(BuildContext context) => MoiViewModel();

  @override
  void onViewModelReady(MoiViewModel viewModel) => viewModel.init();
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
              Icon(icon, color: kcTabIndicatorColor, size: 28),
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
                  color: kcPrimaryColor,
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
