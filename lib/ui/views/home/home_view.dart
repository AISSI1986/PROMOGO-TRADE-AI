import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/views/mode_ia/mode_ia_view.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:promogoai/ui/views/home/widgets/ia_button.dart';
import 'package:promogoai/ui/views/moi/moi_view.dart';
import 'package:promogoai/ui/views/vendre/vendre_view.dart';
import 'widgets/produits_component.dart';
import 'widgets/factories_component.dart';
import 'widgets/ai_voice_bar.dart';
import 'home_viewmodel.dart';
import 'package:promogoai/models/chat_room.dart';
import 'package:intl/intl.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    // Initialisation ou re-traduction si la langue change
    if (!viewModel.isBusy) {
      final String currentLocale = context.locale.languageCode;
      if (!viewModel.isInitialized) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.init(currentLocale);
        });
      } else if (viewModel.currentLanguageCode != currentLocale) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.autoTranslateAll(currentLocale);
        });
      }
    }

    return Scaffold(
      backgroundColor: kcBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(viewModel),
      body: Stack(
        children: [
          _buildMainBody(context, viewModel),
          if (viewModel.currentIndex == 0 && MediaQuery.of(context).viewInsets.bottom == 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _CustomBottomNavBar(viewModel: viewModel),
            ),
          
          // Barre IA Persistante (non-modale) avec détection de clic en dehors
          if (viewModel.showAiVoiceBar) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () => viewModel.setShowAiVoiceBar(false),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: getBottomNavHeight(context) + 10,
              child: AiVoiceBar(
                onResult: (data) => viewModel.handleAiResult(data),
                onCancel: () => viewModel.setShowAiVoiceBar(false),
              ),
            ),
          ],
        ],
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(HomeViewModel viewModel) {
    if (viewModel.currentIndex == 0 || viewModel.currentIndex == 3) return null;

    String title = '';
    if (viewModel.currentIndex == 1) {
      title = 'home.nav_message'.tr().toUpperCase();
    } else if (viewModel.currentIndex == 2) {
      title = 'post_ad.title'.tr().toUpperCase();
    }

    return AppBar(
      backgroundColor: kcPrimaryColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => viewModel.setIndex(0),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: kcTabIndicatorColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: kcTabIndicatorColor,
          fontWeight: FontWeight.w900,
          fontSize: 14,
          letterSpacing: 2.0,
          fontFamily: 'Outfit',
        ),
      ),
    );
  }

  Widget _buildMainBody(BuildContext context, HomeViewModel viewModel) {
    switch (viewModel.currentIndex) {
      case 0:
        return SafeArea(
          bottom: false,
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
        return _buildMessagesTab(context, viewModel);
      case 2:
        return VendreView();
      case 3:
        return MoiView(onBack: () => viewModel.setIndex(0));
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
        return ModeIaView(homeViewModel: viewModel);
      case 1:
        return const ProduitsComponent();
      case 2:
        return const FactoriesComponent();
      default:
        return Center(child: Text('global.in_development'.tr(), style: const TextStyle(color: kcMediumGrey)));
    }
  }

  Widget _buildMessagesTab(BuildContext context, HomeViewModel viewModel) {
    if (!viewModel.isLogged) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: kcBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: kcTabIndicatorColor,
              size: 80,
            ),
            const SizedBox(height: 40),
            Text(
              'message.empty_title'.tr().toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kcPrimaryColor,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'message.login_required'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: kcMediumGrey,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => viewModel.setIndex(3), // Va sur l'onglet "Moi" pour se connecter
              style: ElevatedButton.styleFrom(
                backgroundColor: kcPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'moi.connect'.tr().toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.loadingChats) {
      return const Center(
        child: CircularProgressIndicator(color: kcPrimaryColor),
      );
    }

    if (viewModel.chatRooms.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => viewModel.loadChatRooms(),
        color: kcPrimaryColor,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: kcTabIndicatorColor,
                      size: 80,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'message.empty_title'.tr().toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: kcPrimaryColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'message.empty_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kcMediumGrey,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadChatRooms(),
      color: kcPrimaryColor,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: viewModel.chatRooms.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final room = viewModel.chatRooms[index];
          final otherUserName = viewModel.currentUserId == room.buyerId
              ? room.sellerFullName
              : room.buyerFullName;
          
          final hasUnread = room.unreadCount > 0;
          final timeStr = room.lastMessageTime != null 
              ? DateFormat('HH:mm').format(room.lastMessageTime!.toLocal())
              : '';

          return InkWell(
            onTap: () => viewModel.navigateToChat(room),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: kcPrimaryColor.withOpacity(0.08),
                    child: Text(
                      otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: kcPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  horizontalSpaceMedium,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                otherUserName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: kcPrimaryColor,
                                  fontSize: 15,
                                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              timeStr,
                              style: TextStyle(
                                color: hasUnread ? kcSecondaryGold : Colors.grey,
                                fontSize: 11,
                                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                room.lastMessageContent ?? 'chat.no_messages'.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: hasUnread ? kcPrimaryColorDark : kcMediumGrey,
                                  fontSize: 13,
                                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (hasUnread) ...[
                              horizontalSpaceSmall,
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: kcSecondaryGold,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${room.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ] else if (room.adTitle != null) ...[
                              horizontalSpaceSmall,
                              const Icon(
                                Icons.shopping_bag_outlined,
                                size: 14,
                                color: kcTabIndicatorColor,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}

class _CustomBottomNavBar extends StatelessWidget {
  final HomeViewModel viewModel;

  const _CustomBottomNavBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double totalHeight = getBottomNavHeight(context);
    const double barHeight = 85.0;
    const double notchDepth = 40.0;
    final bool showDome = viewModel.currentIndex == 0 && viewModel.currentTopTab == 1;
    
    // The top padding above the white bar to accommodate the protruding 3D eye/button
    // totalHeight est déjà calculé responsivement via getBottomNavHeight.

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
            painter: _DomePainter(
              barHeight: barHeight,
              domeHeight: notchDepth,
              bottomPadding: bottomPadding,
              showDome: showDome,
            ),
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
                if (showDome) SizedBox(width: centralButtonSize * 1.2), // Espacement pour le gros dôme
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
          if (showDome)
            Positioned(
              // Centrage parfait ! Le milieu de l'Oeil est à Y=41.5. 
              // En descendant l'icône de 4 pixels (top: -18 au lieu de -22), 
              // le milieu de l'icône tombe exactement au centre de la géométrie de l'Oeil !
              top: -18, 
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
  final bool showDome;

  _DomePainter({
    required this.barHeight,
    required this.domeHeight,
    required this.bottomPadding,
    required this.showDome,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double barTop = size.height - (barHeight + bottomPadding); // 40.0

    if (!showDome) {
      // Dessine une barre de navigation plate standard
      final Path rectPath = Path()
        ..moveTo(0, barTop)
        ..lineTo(size.width, barTop)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      final Paint barPaint = Paint()..color = Colors.white;
      canvas.drawShadow(rectPath, Colors.black.withOpacity(0.06), 10.0, true);
      canvas.drawPath(rectPath, barPaint);
      return;
    }

    final double cx = size.width / 2;
    // VISIBILITÉ ACCRUE (Radius 52 pour un dôme affirmé)
    final double startX = cx - 68; 
    final double endX = cx + 68;
    const double peakY = -10.0;
    const double bottomY = 94.0;

    // ==========================================
    // LAYER 1 : LA BARRE BLANCHE MÈRE (Silhouette Oeil)
    // ==========================================
    final Path socketPath = Path();
    socketPath.moveTo(0, barTop);
    socketPath.lineTo(startX, barTop);

    // Arc supérieur affirmé
    socketPath.cubicTo(startX + 15, barTop - 12, cx - 35, peakY, cx, peakY);
    socketPath.cubicTo(cx + 35, peakY, endX - 15, barTop - 12, endX, barTop);

    socketPath.lineTo(size.width, barTop);
    socketPath.lineTo(size.width, size.height);
    socketPath.lineTo(0, size.height);
    socketPath.close();

    // Peinture de la silhouette Mère
    final Paint barPaint = Paint()..color = Colors.white;
    canvas.drawShadow(socketPath, Colors.black.withOpacity(0.06), 10.0, true);
    canvas.drawPath(socketPath, barPaint);

    // ==========================================
    // LAYER 1.5 : LE BASSIN GRIS (Fond de l'oeil)
    // ==========================================
    final Path socketFillPath = Path();
    socketFillPath.moveTo(startX, barTop);
    
    // Arc inférieur affirmé
    socketFillPath.cubicTo(startX + 15, barTop + 12, cx - 35, bottomY, cx, bottomY);
    socketFillPath.cubicTo(cx + 35, bottomY, endX - 15, barTop + 12, endX, barTop);
    socketFillPath.close();

    final Paint socketFillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFEBEBEB),
          Color(0xFFCDCDCD),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, 42), radius: 52))
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(socketFillPath, socketFillPaint);

    // ==========================================
    // LAYER 2 : L'OEIL (Liseré amande impactant)
    // ==========================================
    final Path eyePath = Path();
    eyePath.moveTo(startX, barTop);

    // Contour amande généreux
    eyePath.cubicTo(startX + 15, barTop - 12, cx - 35, peakY, cx, peakY);
    eyePath.cubicTo(cx + 35, peakY, endX - 15, barTop - 12, endX, barTop);
    eyePath.cubicTo(endX - 15, barTop + 12, cx + 35, bottomY, cx, bottomY);
    eyePath.cubicTo(cx - 35, bottomY, startX + 15, barTop + 12, startX, barTop);
    eyePath.close();

    final Rect eyeBounds = Rect.fromCircle(center: Offset(cx, 42), radius: 52); 
    final Paint eyePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          Color(0xFFFAFAFA),
          Color(0xFFE5E5E5),
        ],
        stops: [0.0, 0.4, 1.0],
      ).createShader(eyeBounds)
      ..style = PaintingStyle.fill;

    canvas.drawShadow(eyePath, Colors.black.withOpacity(0.08), 8.0, true);
    canvas.drawPath(eyePath, eyePaint);
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
          Stack(
            children: [
              if (viewModel.showPromotion) const SizedBox(width: double.infinity, height: 130, child: BannerCarousel()),

              Container(
                margin: EdgeInsets.only(top: viewModel.showPromotion ? 100 : 0),
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
              child: TextField(
                onChanged: (value) => viewModel.performTextSearch(value),
                style: const TextStyle(color: kcDarkGreyColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'home.search_hint'.tr(),
                  hintStyle: const TextStyle(color: kcMediumGrey, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => viewModel.onVoiceIAClicked(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                color: Colors.transparent, // Permet d'étendre la zone de clic propre
                child: const Icon(Icons.mic_none, color: kcMediumGrey, size: 20),
              ),
            ),
            const SizedBox(width: 4),
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
            color: isSelected ? const Color(0xFFFF2D55).withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFFF2D55).withOpacity(isSelected ? 0.3 : 0.15),
              width: 1.0,
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
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isSelected ? Colors.black : const Color(0xFFFF2D55),
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

    final double radius = guest.width / 2.0;
    final double centerX = guest.center.dx;
    
    final double hillHeight = radius * 0.75;
    final double hillWidth = radius * 1.25;

    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(centerX - hillWidth, host.top)
      ..cubicTo(
        centerX - hillWidth * 0.6, host.top, 
        centerX - radius * 1.0, host.top - hillHeight,
        centerX, host.top - hillHeight,
      )
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

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({Key? key}) : super(key: key);

  @override
  _BannerCarouselState createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  
  // Liste des images de bannière (ban1.jpg, ban2.jpg)
  final List<String> _images = [
    'assets/images/ban1.jpg',
    'assets/images/ban2.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // Défilement automatique toutes les 4 secondes
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Préchargement immédiat des images en mémoire GPU dès le démarrage
    for (var img in _images) {
      precacheImage(AssetImage(img), context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: _images.length,
      itemBuilder: (context, index) {
        return Image.asset(
          _images[index],
          fit: BoxFit.fill, // Force l'étirement maximum
          width: double.infinity,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return child;
            }
            // Shimmer ultra premium en attendant le décodage de l'image
            return Shimmer.fromColors(
              baseColor: const Color(0xFF1E293B),
              highlightColor: const Color(0xFF334155),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: kcPrimaryColor,
              child: const Center(
                child: Text(
                  'Bannière introuvable',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
