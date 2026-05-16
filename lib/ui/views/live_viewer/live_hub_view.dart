import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'dart:ui';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/views/live_viewer/live_viewer_view.dart';
import 'package:promogoai/ui/views/live_viewer/live_viewer_viewmodel.dart';

class LiveHubView extends StackedView<LiveViewerViewModel> {
  const LiveHubView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, LiveViewerViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14), // Bleu nuit très profond
      body: Stack(
        children: [
          // Arrière-plan avec des formes floues pour le design premium
          _buildBackgroundDecor(),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: viewModel.isBusy 
                    ? const Center(child: CircularProgressIndicator(color: kcSecondaryGold))
                    : _buildContent(context, viewModel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecor() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFFFF2D55).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: kcSecondaryGold.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "SURA AI LIVE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: 1.5,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
              const Text(
                "DÉCOUVREZ LES MEILLEURES OFFRES",
                style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, LiveViewerViewModel viewModel) {
    if (viewModel.sessions.isNotEmpty) {
      return _buildLiveActiveScreen(context, viewModel);
    } else {
      return _buildNoLiveScreen(context, viewModel);
    }
  }

  Widget _buildLiveActiveScreen(BuildContext context, LiveViewerViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Magnifique animation radar/antenne rouge pour indiquer un Live en cours
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFFF2D55).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFFF2D55).withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF2D55).withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: const Icon(Icons.cell_tower_rounded, color: Colors.white, size: 55),
            ),
          ],
        ),
        const SizedBox(height: 40),
        const Text(
          "DIFFUSION EN DIRECT",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            "Connexion au flux vidéo basse latence en cours...",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
          ),
        ),
        const SizedBox(height: 40),
        const CircularProgressIndicator(color: kcSecondaryGold),
      ],
    );
  }

  Widget _buildNoLiveScreen(BuildContext context, LiveViewerViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNoLiveIllustration(),
        const SizedBox(height: 40),
        const Text(
          "AUCUN DIRECT EN COURS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            "Nos vendeurs préparent leurs stocks pour vous éblouir. En attendant, profitez de nos replays !",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.6),
          ),
        ),
        const SizedBox(height: 50),
        
        _buildMainActionButton(context, viewModel, false),
      ],
    );
  }

  @override
  LiveViewerViewModel viewModelBuilder(BuildContext context) => LiveViewerViewModel();

  @override
  void onViewModelReady(LiveViewerViewModel viewModel) async {
    await viewModel.initViewer(initializeVideo: true, autoPlay: false);
    
    if (viewModel.sessions.isNotEmpty) {
      print("🚀 [LiveHub] Live actif détecté, redirection automatique en toute sécurité...");
      // Future.delayed (800ms) permet à Flutter de finir entièrement le frame de notifyListeners() 
      // avant d'exécuter la navigation, éliminant 100% des erreurs d'assertion Flutter !
      Future.delayed(const Duration(milliseconds: 800), () {
        final context = StackedService.navigatorKey?.currentContext;
        if (context != null) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => LiveViewerView(preloadedViewModel: viewModel))
          );
        }
      });
    }
  }

  Widget _buildNoLiveIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white10),
          ),
        ),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: kcSecondaryGold.withOpacity(0.05), blurRadius: 30, spreadRadius: 5),
            ],
          ),
          child: const Icon(Icons.videocam_off_rounded, color: kcSecondaryGold, size: 50),
        ),
      ],
    );
  }

  Widget _buildMainActionButton(BuildContext context, LiveViewerViewModel viewModel, bool hasActiveLives) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LiveViewerView(preloadedViewModel: viewModel)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasActiveLives 
                ? [const Color(0xFFE91E63), const Color(0xFFFF2D55)]
                : [const Color(0xFFFF2D55), const Color(0xFFFF512F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF2D55).withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasActiveLives ? Icons.bolt_rounded : Icons.play_circle_fill_rounded, 
              color: Colors.white, size: 22
            ),
            const SizedBox(width: 12),
            Text(
              hasActiveLives ? "REJOINDRE LE LIVE" : "DÉCOUVRIR LES REPLAYS",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
