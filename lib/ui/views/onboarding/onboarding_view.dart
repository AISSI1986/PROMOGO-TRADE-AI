import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';

import 'onboarding_viewmodel.dart';

class OnboardingView extends StackedView<OnboardingViewModel> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    OnboardingViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: viewModel.pageController,
            onPageChanged: viewModel.setIndex,
            children: [
              _OnboardingPage(
                image: 'assets/images/onboarding_commerce.png',
                title: 'onboarding.title_commerce'.tr(),
                description: 'onboarding.desc_commerce'.tr(),
                gradientColors: [kcPrimaryColor.withOpacity(0.8), kcPrimaryColor],
              ),
              _OnboardingPage(
                image: 'assets/images/onboarding_ai.png',
                title: 'onboarding.title_ai'.tr(),
                description: 'onboarding.desc_ai'.tr(),
                gradientColors: [const Color(0xFF6B8DE3), const Color(0xFF3F51B5)],
              ),
              _OnboardingPage(
                image: 'assets/images/onboarding_market.png',
                title: 'onboarding.title_trading'.tr(),
                description: 'onboarding.desc_trading'.tr(),
                gradientColors: [const Color(0xFFFFA726), const Color(0xFFFB8C00)],
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              onPressed: viewModel.showSettings,
              icon: const Icon(
                Icons.language_rounded,
                color: Colors.white,
                size: 30,
                shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: viewModel.skip,
              child: Text(
                'onboarding.btn_skip'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => _PageIndicator(isSelected: viewModel.currentIndex == index),
                  ),
                ),
                verticalSpaceLarge,
                ElevatedButton(
                  onPressed: viewModel.onNextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kcPrimaryColor,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    viewModel.currentIndex == 2
                        ? 'onboarding.btn_get_started'.tr()
                        : 'onboarding.btn_next'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  OnboardingViewModel viewModelBuilder(BuildContext context) => OnboardingViewModel();
}

class _OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final List<Color> gradientColors;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              height: screenHeight(context) * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          verticalSpaceLarge,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
              ),
            ),
          ),
          verticalSpaceMedium,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          verticalSpaceLarge,
          verticalSpaceLarge, // Push content up for buttons
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isSelected;
  const _PageIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
