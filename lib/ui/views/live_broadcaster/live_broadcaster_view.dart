import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:haishin_kit/haishin_kit.dart';
import 'dart:ui';
import 'live_broadcaster_viewmodel.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../../app/app.locator.dart';

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
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator(color: kcPrimaryColor))
          : Stack(
              fit: StackFit.expand,
              children: [
                // 1. Caméra (HaishinKit) - Plein écran 9:16
                if (viewModel.isCameraInitialized && viewModel.rtmpStream != null)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: VideoStreamView(viewModel.rtmpStream!),
                    ),
                  )
                else
                  const Center(child: Text("Initialisation de la caméra...", style: TextStyle(color: Colors.white))),

                // 2. Overlay Noir Transparent 
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),

                // 3. UI Live Broadcaster
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(viewModel, context),
                        
                        const Spacer(),
                        
                        // Outils Vendeur
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              children: [
                                _buildToolButton(Icons.flip_camera_ios, "Tourner", viewModel.switchCamera),
                                const SizedBox(height: 16),
                                _buildToolButton(Icons.shopping_bag, "Gérer", () {}),
                                const SizedBox(height: 16),
                                _buildToolButton(Icons.settings, "Paramètres", () {}),
                              ],
                            )
                          ],
                        ),
                        
                        const Spacer(),

                        // Bouton Lancer/Arrêter Live
                        Center(
                          child: InkWell(
                            onTap: viewModel.toggleLiveStream,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: viewModel.isStreaming ? Colors.red : Colors.white,
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 6),
                              ),
                              child: Center(
                                child: Icon(
                                  viewModel.isStreaming ? Icons.stop_rounded : Icons.fiber_manual_record,
                                  color: viewModel.isStreaming ? Colors.white : Colors.red,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(LiveBroadcasterViewModel viewModel, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Indicateur LIVE
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
             color: viewModel.isStreaming ? Colors.red : Colors.grey.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.cast, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                viewModel.isStreaming ? "EN DIRECT" : "PRÉPARATION", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
        ),
        
        // Quitter
        InkWell(
          onTap: () {
            final navService = locator<NavigationService>();
            navService.back();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  LiveBroadcasterViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LiveBroadcasterViewModel();

  @override
  void onViewModelReady(LiveBroadcasterViewModel viewModel) {
    viewModel.initBroadcaster();
  }
}
