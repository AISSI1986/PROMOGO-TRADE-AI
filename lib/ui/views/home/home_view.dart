import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/views/mode_ia/mode_ia_view.dart';
import 'package:promogoai/ui/views/home/widgets/ia_button.dart';


import 'package:promogoai/ui/views/moi/moi_view.dart';
import 'package:promogoai/ui/views/vendre/vendre_view.dart';
import 'widgets/produits_component.dart';
import 'widgets/voice_recording_sheet.dart';

import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  void onViewModelReady(HomeViewModel viewModel) {
    super.onViewModelReady(viewModel);
    // Listen for showVoiceSheet changes to show the bottom sheet
    viewModel.addListener(() {
      if (viewModel.showVoiceSheet) {
        _showVoiceBottomSheet(viewModel);
        viewModel.closeVoiceSheet(); // Reset the flag
      }
    });
  }

  void _showVoiceBottomSheet(HomeViewModel viewModel) {
    // We need to use a global key or the navigation service to get the context
  }

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    // Show voice bottom sheet when triggered
    if (viewModel.showVoiceSheet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => VoiceRecordingSheet(
            isRecording: viewModel.isRecording,
            onToggleRecording: viewModel.toggleRecording,
            onClose: () {
              viewModel.closeVoiceSheet();
              Navigator.of(context).pop();
            },
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: kcBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(viewModel),
      body: Stack(
        children: [
          _buildMainBody(viewModel),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _CustomBottomNavBar(viewModel: viewModel),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(HomeViewModel viewModel) {
    if (viewModel.currentIndex == 0 || viewModel.currentIndex == 3) return null;

    String title = '';
    switch (viewModel.currentIndex) {
      case 1:
        title = 'home.nav_message'.tr();
        break;
      case 2:
        title = 'home.nav_vendre'.tr();
        break;
    }

    bool isVendre = viewModel.currentIndex == 2;

    return AppBar(
      backgroundColor: isVendre ? kcPrimaryColor : Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => viewModel.setIndex(0),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: kcTabIndicatorColor,
          size: 20,
        ),
      ),
      title: Text(
        isVendre ? 'post_ad.title'.tr() : title,
        style: TextStyle(
          color: isVendre ? kcTabIndicatorColor : kcPrimaryColor,
          fontWeight: isVendre ? FontWeight.w900 : FontWeight.bold,
          fontSize: isVendre ? 16 : 18,
          letterSpacing: isVendre ? 2.0 : 0.0,
        ),
      ),
      bottom: isVendre ? null : PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: kcLightGrey.withOpacity(0.2),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildMainBody(HomeViewModel viewModel) {
    switch (viewModel.currentIndex) {
      case 0:
        return SafeArea(
          child: Column(
            children: [
              HomeHeader(viewModel: viewModel),
              Expanded(
                child: _buildBodyContent(viewModel),
              ),
            ],
          ),
        );
      case 1:
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: kcBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: kcTabIndicatorColor,
                size: 80,
              ),
              const SizedBox(height: 48),
              Text(
                'message.empty_title'.tr().toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: kcPrimaryColor,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 2,
                color: kcTabIndicatorColor,
              ),
              const SizedBox(height: 24),
              Text(
                'message.empty_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7F8C8D),
                  height: 1.8,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 80), // Visual balancing
            ],
          ),
        );
      case 2:
        return const VendreView();
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
  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}

class _CustomBottomNavBar extends StatelessWidget {
  final HomeViewModel viewModel;

  const _CustomBottomNavBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom; // Récupère la marge système du bas (gesture bar)
    const double barHeight = 60.0; 
    // Le creux s'arrête pile sur la ligne des icônes (60/2 = 30px de profondeur max)
    const double notchDepth = 55.0; 
    final double totalHeight = barHeight + 40 + bottomPadding; // On ajoute la marge au total

    const double centralButtonSize = 120.0; // Format XL Patron stable à 120px

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Le CustomPainter dessinant le background en forme de dôme fluide
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, totalHeight),
            painter: _DomePainter(barHeight: barHeight, domeHeight: notchDepth, bottomPadding: bottomPadding),
          ),

          // 2. Les icônes latérales
          Positioned(
            bottom: bottomPadding, // On surélève les icônes pour éviter la barre système
            left: 0,
            right: 0,
            height: barHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => viewModel.setIndex(0),
                    child: _NavBarItem(imagePath: 'assets/images/logo.png', label: 'home.nav_home'.tr(), isSelected: viewModel.currentIndex == 0),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => viewModel.setIndex(1),
                    child: _NavBarItem(icon: Icons.chat_bubble_outline_rounded, label: 'home.nav_message'.tr(), isSelected: viewModel.currentIndex == 1),
                  ),
                ),
                SizedBox(width: centralButtonSize * 1.2), // Espacement pour le gros dôme
                Expanded(
                  child: GestureDetector(
                    onTap: () => viewModel.setIndex(2),
                    child: _NavBarItem(icon: Icons.local_offer_outlined, label: 'home.nav_vendre'.tr(), isSelected: viewModel.currentIndex == 2),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => viewModel.setIndex(3),
                    child: _NavBarItem(icon: Icons.person_outline, label: 'home.nav_moi'.tr(), isSelected: viewModel.currentIndex == 3),
                  ),
                ),
              ],
            ),
          ),

          // L'ancienne "Layer" a été supprimée pour la remplacer par un fond monolithique parfait



          Positioned(
            top: -25, 
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: centralButtonSize,
                height: centralButtonSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: ClipOval(
                  // Nudge optical : Le logo "P" est asymétrique. On le décale manuellement de 4 pixels vers la gauche.
                  child: Transform.translate(
                    offset: const Offset(-4.0, 0),
                    child: IaButton(onTap: viewModel.onVoiceIAClicked),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DomePainter extends CustomPainter {
  final double barHeight;
  final double domeHeight;
  final double bottomPadding;

  _DomePainter({required this.barHeight, required this.domeHeight, required this.bottomPadding});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final double barTop = size.height - (barHeight + bottomPadding); // 40.0
    
    final double cx = size.width / 2;
    
    // Le bouton central est à y=35 (centre) et a un rayon de 60px.
    // Il descend donc jusqu'à y=95. Notre creux doit descendre un peu plus bas (ex: 102).
    
    path.moveTo(0, barTop);
    
    // Ligne droite jusqu'aux bords du bouton
    path.lineTo(cx - 75, barTop);

    // 1. Descente douce (l'épaule plongeante)
    path.cubicTo(
      cx - 65, barTop, 
      cx - 65, barTop + 15,
      cx - 60, barTop + 25,
    );

    // 2. Le creux profond qui enlace parfaitement la forme du bouton (le U du bas)
    path.cubicTo(
      cx - 45, 102, 
      cx + 45, 102, 
      cx + 60, barTop + 25,
    );

    // 3. Remontée douce (l'épaule sortante)
    path.cubicTo(
      cx + 65, barTop + 15, 
      cx + 65, barTop, 
      cx + 75, barTop,
    );

    path.lineTo(size.width, barTop);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Ombre nette et qualitative
    canvas.drawShadow(path, Colors.black.withOpacity(0.08), 12.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class HomeHeader extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeHeader({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kcBackgroundColor,
      child: Column(
        children: [
          if (viewModel.showPromotion)
            Container(
              width: double.infinity,
              height: 100, // Augmenté de 60 à 100 pour donner plus d'espace
              color: kcPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text(
                    'April',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28, // Légèrement augmenté aussi pour l'équilibre
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bénéficiez jusqu\'à 20 % de réduction',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Légèrement augmenté
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white, size: 24),
                ],
              ),
            ),
          Stack(
            children: [
              if (viewModel.showPromotion) Container(height: 110, color: kcPrimaryColor), // Augmenté pour correspondre à la nouvelle hauteur


              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kcBackgroundColor,
                  borderRadius: viewModel.showPromotion
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildTab(title: 'home.tab_mode_ia'.tr(), index: 0),
                          const SizedBox(width: 15),
                          _buildTab(title: 'home.tab_inter'.tr(), index: 3, isLiveBadge: true),
                          const SizedBox(width: 15),
                          _buildTab(title: 'home.tab_produits'.tr(), index: 1),
                          const SizedBox(width: 15),
                          _buildTab(title: 'home.tab_usine'.tr(), index: 2),
                        ],
                      ),
                    ),
                    if (viewModel.currentTopTab != 0) _buildSearchBar(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
      child: Container(
        height: 52, // Augmenté de 44 à 52 pour une barre de recherche plus généreuse

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kcTabIndicatorColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Icon(Icons.camera_alt_outlined, color: kcMediumGrey, size: 20),
            ),
            Expanded(
              child: Text(
                'home.search_hint'.tr(),
                style: const TextStyle(color: kcMediumGrey, fontSize: 14),
              ),
            ),
            const Icon(Icons.mic_none, color: kcMediumGrey, size: 20),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.all(2),
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kcPrimaryColor.withOpacity(0.7), kcPrimaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({required String title, required int index, bool isLiveBadge = false}) {
    final bool isSelected = viewModel.currentTopTab == index;

    if (isLiveBadge) {
      return GestureDetector(
        onTap: () => viewModel.navigateToLiveViewer(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF2D55) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFFFF2D55),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.live_tv_rounded,
                color: isSelected ? Colors.white : const Color(0xFFFF2D55),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : const Color(0xFFFF2D55),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => viewModel.setTopTab(index),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? Colors.black87 : kcMediumGrey,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 3,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kcTabIndicatorColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final bool isSelected;

  const _NavBarItem({
    this.icon, 
    this.imagePath, 
    required this.label, 
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center, // Centrage automatique sans padding manuel
        children: [
          if (imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Opacity(
                opacity: isSelected ? 1.0 : 0.4,
                child: Image.asset(
                  imagePath!,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else if (icon != null)
            Icon(
              icon,
              color: isSelected ? kcPrimaryColor : kcMediumGrey,
              size: 26,
            ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9, // Réduit pour plus de finesse
              color: isSelected ? kcPrimaryColor : kcMediumGrey,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class SmoothHillNotch extends NotchedShape {
  const SmoothHillNotch();

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null) return Path()..addRect(host);

    // Paramètres de la colline pour épouser le bouton de 90px
    // Paramètres de la colline ajustés pour épouser l'icône de près
    final double radius = guest.width / 2.0;
    final double centerX = guest.center.dx;
    
    // On réduit la hauteur et la largeur pour supprimer le "grand espace"
    final double hillHeight = radius * 0.75; // Hauteur réduite (suivre l'icône)
    final double hillWidth = radius * 1.25; // Largeur resserrée

    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(centerX - hillWidth, host.top)
      // Courbe montante fluide (plus serrée)
      ..cubicTo(
        centerX - hillWidth * 0.6, host.top, 
        centerX - radius * 1.0, host.top - hillHeight,
        centerX, host.top - hillHeight,
      )
      // Courbe descendante fluide (plus serrée)
      ..cubicTo(
        centerX + radius * 1.0, host.top - hillHeight,
        centerX + hillWidth * 0.6, host.top,
        centerX + hillWidth, host.top,
      )
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}

