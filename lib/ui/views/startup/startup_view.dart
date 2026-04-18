import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:promogoai/ui/common/app_colors.dart';

import 'startup_viewmodel.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StartupViewModel viewModel,
    Widget? child,
  ) {
    final size = MediaQuery.sizeOf(context);
    final logoSize = size.width * 0.75;

    return Scaffold(
      backgroundColor: kcPrimaryColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fond Dynamique Mesh Gradient
          const _AnimatedMeshBackground(),

          // 2. Contenu Médian
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo Animé
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/logo_b_bg.png',
                    width: logoSize * 0.8,
                    fit: BoxFit.contain,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
                
                SizedBox(height: size.height * 0.02),

                // Sous-titre Shimmer
                const _ShimmerSubtitle(),
              ],
            ),
          ),
          
          // Indicateur de chargement
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: size.width * 0.4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(kcTabIndicatorColor),
                    minHeight: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) => SchedulerBinding.instance
      .addPostFrameCallback((timeStamp) => viewModel.runStartupLogic());
}

class _AnimatedMeshBackground extends StatefulWidget {
  const _AnimatedMeshBackground();

  @override
  State<_AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<_AnimatedMeshBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _MeshPainter(_controller.value),
        );
      },
    );
  }
}

class _MeshPainter extends CustomPainter {
  final double progress;
  _MeshPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // Fond de base
    canvas.drawRect(Offset.zero & size, Paint()..color = kcMeshDeepBlue);

    // Lueur centrale unique et diffuse
    final center = Offset(size.width * 0.5, size.height * 0.38);
    final radialPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        size.width * 0.6,
        [
          kcMeshRoyal.withOpacity(0.12),
          kcMeshNavy.withOpacity(0.0),
        ],
        [0.2, 1.0],
      );
    
    canvas.drawRect(Offset.zero & size, Paint()..shader = radialPaint.shader);

    // Accent Gold subtil
    paint.color = kcTabIndicatorColor.withOpacity(0.015 + (0.01 * math.sin(progress * 6.28)));
    canvas.drawCircle(
      center,
      size.width * 0.4,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) => true;
}

class _ShimmerSubtitle extends StatefulWidget {
  const _ShimmerSubtitle();

  @override
  State<_ShimmerSubtitle> createState() => _ShimmerSubtitleState();
}

class _ShimmerSubtitleState extends State<_ShimmerSubtitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Opacity(
            opacity: 0.6 + (_controller.value * 0.4),
            child: Text(
              'startup.description'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: kcTabIndicatorColor.withOpacity(_controller.value * 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
