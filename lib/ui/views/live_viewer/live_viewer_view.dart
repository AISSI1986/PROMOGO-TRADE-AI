import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';
import 'package:stacked_services/stacked_services.dart';
import '../../../../app/app.locator.dart';
import 'dart:math';
import 'package:promogoai/ui/common/app_colors.dart';
import 'live_viewer_viewmodel.dart';

class LiveViewerView extends StackedView<LiveViewerViewModel> {
  const LiveViewerView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LiveViewerViewModel viewModel,
    Widget? child,
  ) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: viewModel.dummyVideoUrls.length,
              onPageChanged: viewModel.onPageChanged,
              itemBuilder: (context, index) {
                return _buildSingleLivePage(context, viewModel, index, isKeyboardOpen);
              },
            ),
    );
  }

  Widget _buildSingleLivePage(BuildContext context, LiveViewerViewModel viewModel, int index, bool isKeyboardOpen) {
    final controller = viewModel.controllers[index];
    final isInitialized = controller != null && controller.value.isInitialized;

    return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Couche Vidéo - Plein écran 9:16
                if (isInitialized)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller!.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  )
                else
                  Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: kcSecondaryGold),
                    ),
                  ),

                // 2. Overlay Noir Transparent pour lisibilité (ET Zone de TAP)
                GestureDetector(
                  onTap: viewModel.addLike, // Tapoter n'importe où sur l'écran pour liker
                  behavior: HitTestBehavior.opaque, // Capte les événements tactiles sur tout l'overlay
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Couche UI Interactive
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Profil et Compteur de spectateurs
                        if (!isKeyboardOpen)
                          _buildHeader(viewModel, context, index),
                        
                        const Spacer(),

                        // Bottom Section: Chat et Actions
                        Flexible(
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 260),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Partie Gauche : Chat
                                Expanded(
                                  child: _buildChat(viewModel),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Partie Droite : Actions Verticales
                                if (!isKeyboardOpen)
                                  _buildSideActionBar(viewModel),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Input pour envoyer un message + Contact Seller
                        _buildBottomSection(context, isKeyboardOpen),
                      ],
                    ),
                  ),
                ),

                // 4. Couche Animation des Coeurs
                ...viewModel.floatingHearts.map((id) => _FloatingHeart(key: ValueKey(id))),
              ],
    );
  }

  Widget _buildHeader(LiveViewerViewModel viewModel, BuildContext context, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seller Info (Top Left)
        Container(
          padding: const EdgeInsets.all(4).copyWith(right: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: kcSecondaryGold, // Gold border
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage('assets/images/logo_app.png'), 
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent, // Live badge color from mockup
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    viewModel.broadcasterNames[index], // Affiche le nom spécifique à cet index
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Viewer Count & Close
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('${viewModel.viewerCount}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                final navService = locator<NavigationService>();
                navService.back();
              },
              child: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSideActionBar(LiveViewerViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like Button & Counter
        Column(
          children: [
            const Icon(Icons.favorite, color: kcSecondaryGold, size: 36), // Gold Heart
            const SizedBox(height: 4),
            Text('${viewModel.heartCounter}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 24),
        // Share Button
        const Icon(Icons.reply_rounded, color: Colors.white, size: 36), // Share
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildChat(LiveViewerViewModel viewModel) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black, Colors.black],
            stops: [0.0, 0.15, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ListView.builder(
          reverse: true, // Auto-scroll vers le bas
          padding: const EdgeInsets.only(bottom: 8),
          itemCount: viewModel.chatMessages.length,
          itemBuilder: (context, index) {
            // Reverse list to show newest at bottom
            final msg = viewModel.chatMessages[viewModel.chatMessages.length - 1 - index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13),
                      children: [
                        TextSpan(
                          text: '${msg['user']}: ',
                          style: const TextStyle(color: kcSecondaryGold, fontWeight: FontWeight.w800), // Gold
                        ),
                        TextSpan(
                          text: msg['message']!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
    );
  }

  Widget _buildBottomSection(BuildContext context, bool isKeyboardOpen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chat Input Row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'I will comment...',
                    hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.send_rounded, color: kcSecondaryGold, size: 28), // Gold Send Icon
          ],
        ),
        if (!isKeyboardOpen) ...[
          const SizedBox(height: 16),
          // Seller Action Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: kcPrimaryColorDark, // The darkest Navy Blue explicitly
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kcSecondaryGold, width: 1.5), // Gold Border
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_outline, color: kcSecondaryGold, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'CONTACT THE SELLER',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 4),
      ],
    );
  }

  @override
  LiveViewerViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LiveViewerViewModel();

  @override
  void onViewModelReady(LiveViewerViewModel viewModel) {
    viewModel.initViewer();
  }
}

// Widget pour animer les coeurs flottants
class _FloatingHeart extends StatefulWidget {
  const _FloatingHeart({Key? key}) : super(key: key);

  @override
  _FloatingHeartState createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;
  late double _randomXOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    
    // Position aléatoire sur l'axe X pour que chaque coeur flotte différemment
    _randomXOffset = (Random().nextDouble() - 0.5) * 50;

    _positionAnimation = Tween<double>(begin: 0, end: -300).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInQuint));

    _controller.forward();
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
        return Positioned(
          bottom: 100 - _positionAnimation.value,
          right: 30 + _randomXOffset + (_positionAnimation.value * 0.1), // Oscillation
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: const Icon(Icons.favorite, color: Colors.redAccent, size: 35),
          ),
        );
      },
    );
  }
}
