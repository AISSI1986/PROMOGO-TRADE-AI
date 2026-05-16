import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'live_broadcaster_viewmodel.dart';

class LiveBroadcasterView extends StackedView<LiveBroadcasterViewModel> {
  const LiveBroadcasterView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LiveBroadcasterViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. PLACEHOLDER CAMERA (Sera remplacé par CameraPreview plus tard)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[900],
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_off_rounded, color: Colors.white24, size: 64),
                  SizedBox(height: 16),
                  Text("Aperçu caméra en attente", style: TextStyle(color: Colors.white24)),
                ],
              ),
            ),
          ),

          // 2. OVERLAY DE GRADIENT (Pour la lisibilité des textes)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // 3. INTERFACE DE DIFFUSION
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildTopBar(viewModel),
                  const Spacer(),
                  _buildLiveStatus(viewModel),
                  const SizedBox(height: 30),
                  _buildBroadcasterControls(viewModel),
                  const SizedBox(height: 40),
                  _buildMainActionButton(viewModel),
                ],
              ),
            ),
          ),

          // 4. BOUTON FERMER (En haut à droite)
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(LiveBroadcasterViewModel viewModel) {
    return Row(
      children: [
        _buildStatBadge(
          icon: Icons.timer_rounded,
          value: viewModel.formattedDuration,
          color: viewModel.isLive ? Colors.redAccent : Colors.white38,
        ),
        const SizedBox(width: 12),
        _buildStatBadge(
          icon: Icons.group_rounded,
          value: "${viewModel.viewerCount}",
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildStatBadge({required IconData icon, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildLiveStatus(LiveBroadcasterViewModel viewModel) {
    if (!viewModel.isLive) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.white, size: 10),
          SizedBox(width: 8),
          Text("EN DIRECT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildBroadcasterControls(LiveBroadcasterViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircleButton(
          icon: viewModel.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          onTap: viewModel.toggleMute,
          isActive: viewModel.isMuted,
        ),
        _buildCircleButton(
          icon: Icons.flip_camera_ios_rounded,
          onTap: viewModel.switchCamera,
        ),
        _buildCircleButton(
          icon: Icons.flash_on_rounded,
          onTap: () {},
        ),
        _buildCircleButton(
          icon: Icons.shopping_basket_rounded,
          onTap: () {},
          label: "Produits",
        ),
      ],
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap, bool isActive = false, String? label}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isActive ? Colors.redAccent : Colors.white10,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ],
    );
  }

  Widget _buildMainActionButton(LiveBroadcasterViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.toggleLive,
      child: Container(
        height: 65,
        width: double.infinity,
        decoration: BoxDecoration(
          color: viewModel.isLive ? Colors.black45 : kcPrimaryColor,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: viewModel.isLive ? Colors.redAccent : kcSecondaryGold, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          viewModel.isLive ? "ARRÊTER LE LIVE" : "LANCER LE DIRECT",
          style: TextStyle(
            color: viewModel.isLive ? Colors.redAccent : Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  LiveBroadcasterViewModel viewModelBuilder(BuildContext context) => LiveBroadcasterViewModel();
}
