import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'demande_devis_viewmodel.dart';
import '../../../models/rfq_recommendation_model.dart';

class DemandeDevisView extends StackedView<DemandeDevisViewModel> {
  const DemandeDevisView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DemandeDevisViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      body: _AnimatedEntrance(
        child: Column(
          children: [
            _buildCompactHeader(context, viewModel),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFrequentRequestsSection(context),
                    _buildHeroSection(context, viewModel),
                    _buildRecommendationsSection(
                      context,
                      title: 'rfq.recommendations_history'.tr(),
                      recommendations: viewModel.historyRecommendations,
                      delay: 600,
                    ),
                    _buildRecommendationsSection(
                      context,
                      title: 'rfq.recommendations_suggested'.tr(),
                      recommendations: viewModel.suggestedRecommendations,
                      delay: 800,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context, DemandeDevisViewModel viewModel) {
    return Container(
      width: double.infinity,
      color: kcPrimaryColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 15,
        left: 10,
        right: 20,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: viewModel.goBack,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFB0BEC5)],
              ).createShader(bounds),
              child: Text(
                'rfq.title'.tr(),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequentRequestsSection(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - 54) / 3;

    final items = [
      {
        'title': 'rfq.frequent_design'.tr(),
        'icon': Icons.draw_rounded,
        'gradient': const [Color(0xFF0F172A), Color(0xFF1E293B)],
        'delay': 200,
      },
      {
        'title': 'rfq.frequent_logo'.tr(),
        'icon': Icons.style_rounded,
        'gradient': const [Color(0xFF03112E), Color(0xFF0A1F44)],
        'delay': 350,
      },
      {
        'title': 'rfq.frequent_lot'.tr(),
        'icon': Icons.inventory_2_rounded,
        'gradient': const [Color(0xFF1A1A1A), Color(0xFF2C2C2C)],
        'delay': 500,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: -20,
            left: -20,
            child: Opacity(
              opacity: 0.05,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [kcSecondaryGold, Colors.transparent]),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _MetallicIcon(icon: Icons.diamond, size: 14, isGold: true),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'rfq.frequent_title'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: kcDarkGreyColor,
                          letterSpacing: 0.6,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: items.map((item) => _AnimatedEntrance(
                    delay: item['delay'] as int,
                    offset: const Offset(0, 20),
                    child: _buildTranscendentCard(context, item, cardWidth, isGold: true),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: kcPrimaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: kcPrimaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'rfq.learn_more'.tr(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: kcPrimaryColor,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranscendentCard(BuildContext context, Map<String, dynamic> item, double width, {bool isGold = false}) {
    return Container(
      width: width,
      height: width * 1.35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (item['gradient'] as List<Color>)[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: item['gradient'] as List<Color>,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -width * 0.4,
                left: -width * 0.4,
                child: Container(
                  width: width * 1.5,
                  height: width * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.white.withOpacity(0.12), Colors.transparent],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MetallicIcon(icon: item['icon'] as IconData, size: 36, isGold: isGold),
                    const SizedBox(height: 10),
                    Text(
                      item['title'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, DemandeDevisViewModel viewModel) {
    return Container(
      width: double.infinity,
      color: kcPrimaryColor,
      padding: const EdgeInsets.fromLTRB(30, 35, 30, 45),
      child: Column(
        children: [
          _AnimatedEntrance(
            delay: 400,
            child: Text(
              'rfq.hero_title'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          _AnimatedEntrance(
            delay: 500,
            child: Text(
              'rfq.hero_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.45),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 35),
          _AnimatedEntrance(
            delay: 600,
            child: _ShimmeringGoldButton(
              onPressed: () => viewModel.navigateToForm(context),
              text: 'rfq.form_submit'.tr(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(
    BuildContext context, {
    required String title,
    required List<RfqRecommendation> recommendations,
    int delay = 0,
  }) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFBFBFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnimatedEntrance(
            delay: delay,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 24, 15),
              child: Row(
                children: [
                  _MetallicIcon(icon: Icons.diamond, size: 14, isGold: true),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: kcDarkGreyColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width < 360 ? 0.65 : 0.72,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
              ),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final item = recommendations[index];
                return _AnimatedEntrance(
                  delay: delay + (index * 100),
                  offset: const Offset(0, 40),
                  child: _buildUltimateRecommendationCard(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltimateRecommendationCard(BuildContext context, RfqRecommendation item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFE0E5EC), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(kcPrimaryColor))),
                      ),
                      errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image_rounded, color: kcMediumGrey, size: 24)),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.verified_rounded, color: Color(0xFF4CAF50), size: 14),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [kcPrimaryColor, Color(0xFF1E3A8A)]),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                        ),
                        child: Text(
                          'rfq.get_quotes_now'.tr(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'rfq.suppliers_count'.tr(namedArgs: {'count': item.suppliersCount.toString()}),
                  style: GoogleFonts.inter(fontSize: 8.5, color: Colors.grey.shade500, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  item.productName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: kcDarkGreyColor, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  item.customizationTypes.join(', '),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 9, color: Colors.red.shade900, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  DemandeDevisViewModel viewModelBuilder(BuildContext context) => DemandeDevisViewModel();
}

// --- Bulletproof helpers ---
class _AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final int delay;
  final Offset offset;

  const _AnimatedEntrance({
    required this.child,
    this.delay = 0,
    this.offset = const Offset(0, 30),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: offset * (1.0 - value),
            child: child,
          ),
        );
      },
      child: FutureBuilder(
        future: Future.delayed(Duration(milliseconds: delay)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return child!;
          }
          return const Opacity(opacity: 0, child: SizedBox());
        },
      ),
    );
  }
}

class _MetallicIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool isGold;

  const _MetallicIcon({required this.icon, required this.size, this.isGold = true});

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = isGold
        ? [const Color(0xFFFFD700), const Color(0xFFFFFACD), const Color(0xFFDAA520), const Color(0xFFF0E68C)]
        : [const Color(0xFFE0E0E0), Colors.white, const Color(0xFF9E9E9E), const Color(0xFFBDBDBD)];

    return Stack(
      children: [
        Positioned(
          top: 1.5,
          left: 1.5,
          child: Icon(icon, size: size, color: Colors.black.withOpacity(0.35)),
        ),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Icon(icon, size: size, color: Colors.white),
        ),
      ],
    );
  }
}

class _ShimmeringGoldButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const _ShimmeringGoldButton({required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -2.5, end: 2.5),
      duration: const Duration(milliseconds: 3500),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: kcSecondaryGold.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 10)),
            ],
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: kcSecondaryGold,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment(value - 0.6, 0),
                  end: Alignment(value + 0.6, 0),
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.25),
                    Colors.transparent,
                  ],
                  stops: const [0.3, 0.5, 0.7],
                ),
              ),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
