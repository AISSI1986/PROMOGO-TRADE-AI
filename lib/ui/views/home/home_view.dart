import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/views/mode_ia/mode_ia_view.dart';
import 'package:promogoai/ui/views/home/widgets/gemini_ai_button.dart';
import 'package:promogoai/ui/views/home/widgets/animated_bottom_bar.dart';
import 'package:promogoai/ui/views/moi/moi_view.dart';
import 'widgets/produits_component.dart';

import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      body: SafeArea(
        child: _buildMainBody(viewModel),
      ),
      floatingActionButton: GeminiAiButton(
        onPressed: viewModel.onVoiceIAClicked,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(viewModel),
    );
  }

  Widget _buildMainBody(HomeViewModel viewModel) {
    switch (viewModel.currentIndex) {
      case 0:
        return Column(
          children: [
            HomeHeader(viewModel: viewModel),
            Expanded(
              child: _buildBodyContent(viewModel),
            ),
          ],
        );
      case 3:
        return const MoiView();
      default:
        return Center(
          child: Text(
            'global.in_development'.tr(),
            style: const TextStyle(color: kcMediumGrey),
          ),
        );
    }
  }

  Widget _buildBodyContent(HomeViewModel viewModel) {
    switch (viewModel.currentTopTab) {
      case 0:
        return const ModeIaView();
      case 1:
        return const ProduitsComponent();
      default:
        return Center(child: Text('global.in_development'.tr(), style: const TextStyle(color: kcMediumGrey)));
    }
  }

  Widget _buildBottomNav(HomeViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: kcPrimaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const FuturisticNotch(),
        notchMargin: 0.0,
        color: Colors.white,
        elevation: 0,
        child: AnimatedBottomBar(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => viewModel.setIndex(0),
                  child: _NavBarItem(icon: Icons.home, label: 'home.nav_home'.tr(), isSelected: viewModel.currentIndex == 0),
                ),
                GestureDetector(
                  onTap: () => viewModel.setIndex(1),
                  child: _NavBarItem(icon: Icons.message_outlined, label: 'home.nav_message'.tr(), isSelected: viewModel.currentIndex == 1),
                ),
                const SizedBox(width: 40), // Space for floating button
                GestureDetector(
                  onTap: () => viewModel.setIndex(2),
                  child: _NavBarItem(icon: Icons.shopping_cart_outlined, label: 'home.nav_panier'.tr(), isSelected: viewModel.currentIndex == 2),
                ),
                GestureDetector(
                  onTap: () => viewModel.setIndex(3),
                  child: _NavBarItem(icon: Icons.person_outline, label: 'home.nav_moi'.tr(), isSelected: viewModel.currentIndex == 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}

class HomeHeader extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeHeader({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (viewModel.showPromotion)
          Container(
            width: double.infinity,
            height: 80,
            color: kcPrimaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'March',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bénéficiez de jusqu\'à 20 % de réduction',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white, size: 20),
              ],
            ),
          ),
        Stack(
          children: [
            if (viewModel.showPromotion)
              Container(height: 50, color: kcPrimaryColor),
            Container(
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                color: kcBackgroundColor,
                borderRadius: viewModel.showPromotion
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      )
                    : null,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    _buildTab(title: 'home.tab_mode_ia'.tr(), index: 0),
                    _buildTab(title: 'home.tab_produits'.tr(), index: 1),
                    _buildTab(title: 'home.tab_usine'.tr(), index: 2),
                    _buildTab(title: 'home.tab_inter'.tr(), index: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTab({required String title, required int index}) {
    final bool isSelected = viewModel.currentTopTab == index;
    return GestureDetector(
      onTap: () => viewModel.setTopTab(index),
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                color: isSelected ? Colors.black87 : kcMediumGrey,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 3,
                width: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF64B5F6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _NavBarItem({required this.icon, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isSelected ? kcPrimaryColor : kcMediumGrey),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? kcPrimaryColor : kcMediumGrey,
          ),
        )
      ],
    );
  }
}

class FuturisticNotch extends NotchedShape {
  const FuturisticNotch();

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null) return Path()..addRect(host);
    final double centerX = guest.center.dx;
    const double radius = 30.0;
    const double hillHeight = 30.0; // Mounts over the top of the button

    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(centerX - 50, host.top)
      ..cubicTo(centerX - 40, host.top, centerX - 35, host.top - hillHeight, centerX, host.top - hillHeight)
      ..cubicTo(centerX + 35, host.top - hillHeight, centerX + 40, host.top, centerX + 50, host.top)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}

class FuturisticBottomBarPainter extends CustomPainter {
  final double animationValue;
  FuturisticBottomBarPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Suppression du trait (ligne lumineuse) à la demande de l'utilisateur
  }

  @override
  bool shouldRepaint(covariant FuturisticBottomBarPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
