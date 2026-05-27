import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'dart:ui';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/views/live_viewer/live_viewer_view.dart';
import 'package:promogoai/ui/views/live_viewer/live_viewer_viewmodel.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
    if (viewModel.videoUrls.isEmpty) {
      return const Center(child: Text("Aucun live disponible", style: TextStyle(color: Colors.white)));
    }

    return Stack(
      children: [
        // --- 1. AESTHETIC BACKGROUND ---
        // Des formes floues lumineuses pour un fond premium
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -50,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              color: const Color(0xFF673AB7).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.black.withOpacity(0.6)),
        ),

        // --- 2. FOREGROUND CONTENT ---
        RefreshIndicator(
          color: kcSecondaryGold,
          backgroundColor: const Color(0xFF0F1A30),
          onRefresh: viewModel.refreshActiveLives,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // HERO SECTION (1er Live)
                    _buildHeroLive(context, viewModel, 0),
                    const SizedBox(height: 24),
                    
                    // TEXTE REPLAYS / AUTRES LIVES
                    if (viewModel.videoUrls.length > 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "D'autres lives pour vous",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
  
              // GRID SECTION (Reste des lives)
              if (viewModel.videoUrls.length > 1)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, gridIndex) {
                        final realIndex = gridIndex + 1; // On a déjà affiché le 0 en Hero
                        return _buildGridCard(context, viewModel, realIndex);
                      },
                      childCount: viewModel.videoUrls.length - 1,
                    ),
                  ),
                ),
                
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToLive(BuildContext context, LiveViewerViewModel viewModel, int index) {
    viewModel.currentVideoIndex = index;
    viewModel.isViewingFullScreen = true;
    // Forcer la recréation du PageController pour afficher la bonne vidéo
    // car LiveViewerViewModel garde l'ancien contrôleur en mémoire
    viewModel.pageController = PageController(initialPage: index);

    // Mettre le volume à 1.0 et jouer la vidéo sélectionnée
    final selectedController = viewModel.getPlayer(index);
    if (selectedController != null) {
      selectedController.setVolume(100.0);
      selectedController.play();
    }

    // Mettre en pause toutes les autres vidéos
    for (var i = 0; i < viewModel.videoUrls.length; i++) {
      if (i != index) {
        viewModel.getPlayer(i)?.pause();
      }
    }

    Navigator.push(
      context, 
      MaterialPageRoute<void>(builder: (context) => LiveViewerView(preloadedViewModel: viewModel))
    ).then((_) {
      viewModel.isViewingFullScreen = false;
      viewModel.refreshActiveLives();
      
      // Quand on revient sur le Hub, on remet le Hero en mode silencieux
      final heroController = viewModel.getPlayer(0);
      if (heroController != null && viewModel.isControllerInitialized(0)) {
        heroController.setVolume(0.0);
        heroController.play();
      }
      // On s'assure que les autres sont en pause
      for (var i = 1; i < viewModel.videoUrls.length; i++) {
        viewModel.getPlayer(i)?.pause();
      }
    });
  }

  Widget _buildHeroLive(BuildContext context, LiveViewerViewModel viewModel, int index) {
    final isDummy = index >= viewModel.sessions.length;
    final broadcasterName = viewModel.getBroadcasterName(index);
    final player = viewModel.getPlayer(index);
    final videoController = viewModel.getVideoController(index);
    
    // Autoplay silencieux pour le Hero
    if (viewModel.isControllerInitialized(index) && player != null) {
      player.setVolume(0.0);
      player.play();
    }

    return GestureDetector(
      onTap: () => _navigateToLive(context, viewModel, index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 400, // Grand format Hero
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF2D55).withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Vidéo en lecture silencieuse
              if (viewModel.isControllerInitialized(index) && videoController != null)
                Video(
                  controller: videoController,
                  fit: BoxFit.cover,
                  controls: NoVideoControls,
                )
              else if (viewModel.failedVideoIndices.contains(index))
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded, color: Colors.white.withOpacity(0.6), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          "En attente de connexion...",
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator(color: Color(0xFFFF2D55))),

              // Dégradé sombre pour lisibilité
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                  ),
                ),
              ),
              
              // Badge "EN DIRECT" Héroïque
              Positioned(
                top: 16,
                left: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: Color(0xFFFF2D55), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "EN DIRECT",
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Vues Héroïques
              Positioned(
                top: 16,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            "${1200 + (index * 150)} spectateurs",
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Infos du Vendeur Héroïque
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.black,
                            child: Icon(Icons.person, size: 20, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            broadcasterName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isDummy ? "Ne ratez pas notre grande promotion exclusive sur toute la boutique !!" : "Rejoignez le live en cours",
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Faux bouton pour inciter au clic
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("REJOINDRE LE LIVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildGridCard(BuildContext context, LiveViewerViewModel viewModel, int index) {
    final broadcasterName = viewModel.getBroadcasterName(index);
    final videoController = viewModel.getVideoController(index);

    return GestureDetector(
      onTap: () => _navigateToLive(context, viewModel, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black,
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Vidéo figée (Premier frame)
              if (viewModel.isControllerInitialized(index) && videoController != null)
                Video(
                  controller: videoController,
                  fit: BoxFit.cover,
                  controls: NoVideoControls,
                )
              else if (viewModel.failedVideoIndices.contains(index))
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_filled_rounded, color: Colors.white.withOpacity(0.4), size: 36),
                        const SizedBox(height: 8),
                        Text(
                          "Replay / Différé",
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator(color: Colors.white24)),

              // Assombrissement en bas
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                  ),
                ),
              ),

              // Vues
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.remove_red_eye, color: Colors.white, size: 10),
                      const SizedBox(width: 4),
                      Text(
                        "${1200 + (index * 150)}",
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // Infos vendeur
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        broadcasterName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  @override
  LiveViewerViewModel viewModelBuilder(BuildContext context) => LiveViewerViewModel();

  @override
  void onViewModelReady(LiveViewerViewModel viewModel) async {
    await viewModel.initViewer(initializeVideo: true, autoPlay: false);
  }

}
