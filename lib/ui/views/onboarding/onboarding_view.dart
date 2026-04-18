import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';

import 'onboarding_viewmodel.dart';

class OnboardingView extends StackedView<OnboardingViewModel> {
  const OnboardingView({super.key});

  @override
  Widget builder(
    BuildContext context,
    OnboardingViewModel viewModel,
    Widget? child,
  ) {
    final bool isSmallScreen = screenWidth(context) < 360;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Carrousel des pages
            Expanded(
              child: PageView(
                controller: viewModel.pageController,
                onPageChanged: viewModel.setIndex,
                children: [
                  _OnboardingPage(
                    image: 'assets/images/onboarding_commerce.jpeg',
                    title: 'onboarding.title_commerce'.tr(),
                    description: 'onboarding.desc_commerce'.tr(),
                    index: 0,
                    currentIndex: viewModel.currentIndex,
                  ),
                  _OnboardingPage(
                    image: 'assets/images/onboarding_ai.jpeg',
                    title: 'onboarding.title_ai'.tr(),
                    description: 'onboarding.desc_ai'.tr(),
                    index: 1,
                    currentIndex: viewModel.currentIndex,
                  ),
                  _OnboardingPage(
                    image: 'assets/images/onboarding_market.jpeg',
                    title: 'onboarding.title_trading'.tr(),
                    description: 'onboarding.desc_trading'.tr(),
                    index: 2,
                    currentIndex: viewModel.currentIndex,
                  ),
                ],
              ),
            ),

            // 2. Contrôles de navigation adaptatifs
            Container(
              padding: EdgeInsets.fromLTRB(24, 0, 24, isSmallScreen ? 12 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  // Indicateurs de pages (Or / Marine)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => _PageIndicator(isSelected: viewModel.currentIndex == index),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 28),
                  
                  // Bouton d'action principal : Inscription (Style Or Premium)
                  _PrimaryButton(
                    title: 'onboarding.btn_create_account'.tr(),
                    onTap: viewModel.navigateToRegister,
                  ),
                  const SizedBox(height: 12),
                  
                  // Bouton d'action secondaire : Connexion
                  _SecondaryButton(
                    title: 'onboarding.btn_login'.tr(),
                    onTap: viewModel.navigateToLogin,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _GuestButton(
                    title: 'onboarding.btn_guest'.tr(),
                    onTap: viewModel.navigateToHome,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  OnboardingViewModel viewModelBuilder(BuildContext context) => OnboardingViewModel();

  @override
  void onViewModelReady(OnboardingViewModel viewModel) {
    viewModel.init();
    super.onViewModelReady(viewModel);
  }
}

/// Composant propre: Représente le contenu d'une page (Image séparée du texte)
class _OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final int index;
  final int currentIndex;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.index,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = screenWidth(context) < 360;
    final bool isActive = index == currentIndex;

    return Column(
      children: [
        // Zone Supérieure : L'image s'adapte à la largeur (fitWidth)
        Expanded(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white, Colors.transparent],
                stops: [0.0, 0.8, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Image.asset(
                image,
                width: double.infinity,
                fit: BoxFit.fitWidth, // CORRECTIF : On ne coupe plus les côtés
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFF8F9FA),
                  child: Center(
                    child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.black26),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Zone Inférieure : Textes sécurisés contre l'overflow
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 24 : 32, 
            10, 
            isSmallScreen ? 24 : 32, 
            isSmallScreen ? 12 : 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Le contenu textuel peut scroller si l'écran est trop petit
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
              // Titre avec animation de slide
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0.0, end: isActive ? 1.0 : 0.0),
                curve: Curves.easeOutCubic, // Plus sûr, pas de dépassement
                builder: (context, value, child) {
                  final double safeOpacity = value.clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - safeOpacity)),
                    child: Opacity(
                      opacity: safeOpacity,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kcPrimaryColor, // Marine pour le titre
                    fontSize: isSmallScreen ? 22 : 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Description avec animation de fondu retardée
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0.0, end: isActive ? 1.0 : 0.0),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  );
                },
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: isSmallScreen ? 14 : 16,
                    height: 1.5, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Composant UI Spécifique : Bouton Principal
class _PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: kcSuccessColor, // Retour au Vert d'origine
        boxShadow: [
          BoxShadow(
            color: kcSuccessColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

/// Composant UI Spécifique : Bouton Secondaire
class _SecondaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kcSuccessColor.withOpacity(0.5), width: 1.5),
      ),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: kcSuccessColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Composant UI Spécifique : Bouton Invité Hautement Remarquable
class _GuestButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _GuestButton({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: kcPrimaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kcPrimaryColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.ads_click_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Composant UI Spécifique : Pagination (Points)
class _PageIndicator extends StatelessWidget {
  final bool isSelected;
  const _PageIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isSelected ? 30 : 8,
      decoration: BoxDecoration(
        color: isSelected ? kcSuccessColor : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(3),
        boxShadow: isSelected ? [
          BoxShadow(
            color: kcSuccessColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ] : null,
      ),
    );
  }
}
