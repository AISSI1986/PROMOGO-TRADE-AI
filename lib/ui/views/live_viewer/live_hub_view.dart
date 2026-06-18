import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'dart:ui';
import 'package:video_player/video_player.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/views/live_viewer/live_viewer_view.dart';
import 'package:promogoai/ui/views/live_viewer/live_viewer_viewmodel.dart';

class LiveHubView extends StackedView<LiveViewerViewModel> {
  const LiveHubView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, LiveViewerViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
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
                style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 0.5),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, LiveViewerViewModel viewModel) {
    if (viewModel.videoUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 64, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              "Aucun live en cours",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Revenez plus tard pour de nouvelles offres",
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeroLive(context, viewModel, 0)),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        if (viewModel.videoUrls.length > 1)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("LIVES EN COURS", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  Text("${viewModel.videoUrls.length - 1} AUTRES", style: const TextStyle(color: kcSecondaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        if (viewModel.videoUrls.length > 1)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, gridIndex) {
                  final realIndex = gridIndex + 1;
                  return _buildGridCard(context, viewModel, realIndex);
                },
                childCount: viewModel.videoUrls.length - 1,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  void _navigateToLive(BuildContext context, LiveViewerViewModel viewModel, int index) {
    viewModel.currentVideoIndex = index;
    viewModel.isViewingFullScreen = true;
    viewModel.pageController = PageController(initialPage: index);

    // Démarrer explicitement le live ou la vidéo
    viewModel.onPageChanged(index);

    Navigator.push(
      context, 
      MaterialPageRoute<void>(builder: (context) => LiveViewerView(preloadedViewModel: viewModel))
    ).then((_) {
      viewModel.isViewingFullScreen = false;
      
      // Nettoyage après la sortie du mode plein écran
      viewModel.videoController?.pause();
      viewModel.streamingService.leaveChannel();
      
      viewModel.refreshActiveLives();
    });
  }

  Widget _buildHeroLive(BuildContext context, LiveViewerViewModel viewModel, int index) {
    final broadcasterName = viewModel.getBroadcasterName(index);

    return GestureDetector(
      onTap: () => _navigateToLive(context, viewModel, index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 400,
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
              index == viewModel.currentVideoIndex
                  ? (index < viewModel.sessions.length
                      ? viewModel.streamingService.buildVideoView(
                          channelId: viewModel.sessions[index]['id'].toString(),
                          remoteUid: viewModel.streamingService.currentRemoteUid,
                          isBroadcaster: false,
                        )
                      : (viewModel.videoController != null && viewModel.videoController!.value.isInitialized
                          ? SizedBox.expand(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: viewModel.videoController!.value.size.width,
                                  height: viewModel.videoController!.value.size.height,
                                  child: VideoPlayer(viewModel.videoController!),
                                ),
                              ),
                            )
                           : Container(
                               decoration: const BoxDecoration(
                                 image: DecorationImage(
                                   image: AssetImage('assets/images/placeholder_live.png'),
                                   fit: BoxFit.cover,
                                 ),
                               ),
                               child: Container(
                                 color: Colors.black54,
                                 child: const Center(
                                   child: CircularProgressIndicator(color: kcSecondaryGold),
                                 ),
                               ),
                             )))
                   : Container(
                       decoration: const BoxDecoration(
                         image: DecorationImage(
                           image: AssetImage('assets/images/placeholder_live.png'),
                           fit: BoxFit.cover,
                         ),
                       ),
                       child: Container(
                         color: Colors.black54,
                         child: const Center(
                           child: CircularProgressIndicator(color: kcSecondaryGold),
                         ),
                       ),
                     ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.9)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 16, left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
                      SizedBox(width: 4),
                      Text("EN DIRECT", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 24, left: 20, right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      broadcasterName,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.remove_red_eye, color: kcSecondaryGold, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${viewModel.viewerCount} spectateurs",
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                        ),
                      ],
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
    final session = viewModel.sessions[index];

    return GestureDetector(
      onTap: () => _navigateToLive(context, viewModel, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF151923),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2A2D34), Color(0xFF151923)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const SizedBox(),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                bottom: 12, left: 12, right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      broadcasterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, color: kcSecondaryGold, size: 10),
                        const SizedBox(width: 4),
                        Text("${session['viewer_count'] ?? ((session['id']?.hashCode ?? 0).abs() % 500 + 50)}", style: const TextStyle(color: kcSecondaryGold, fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
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
  void onViewModelReady(LiveViewerViewModel viewModel) {
    viewModel.initViewer(initializeVideo: true);
  }
}
