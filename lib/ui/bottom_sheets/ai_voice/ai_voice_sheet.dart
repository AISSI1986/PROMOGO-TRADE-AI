import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'ai_voice_sheet_model.dart';
import 'dart:math';

class AiVoiceSheet extends StackedView<AiVoiceSheetModel> {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const AiVoiceSheet({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  void onViewModelReady(AiVoiceSheetModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.startListening();
  }

  @override
  Widget builder(
    BuildContext context,
    AiVoiceSheetModel viewModel,
    Widget? child,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: kcPrimaryColor, // Couleur de fond aux couleurs de la marque
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: kcPrimaryColor.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bouton +
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white70, size: 28),
                onPressed: () {
                  viewModel.cancelRecording(completer);
                },
              ),
              
              // Visualiseur ou Texte
              Expanded(
                child: viewModel.isProcessing
                    ? const Text(
                        "Analyse en cours...",
                        style: TextStyle(color: kcAIHighlight, fontSize: 14),
                        textAlign: TextAlign.center,
                      )
                    : viewModel.agentResponse != null && !viewModel.isRecording
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              viewModel.agentResponse!,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : AudioVisualizer(
                            amplitude: viewModel.currentAmplitude,
                            isRecording: viewModel.isRecording,
                          ),
              ),
              
              // Bouton Stop (Carré) - Affiché UNIQUEMENT si on enregistre
              if (viewModel.isRecording)
                GestureDetector(
                  onTap: () => viewModel.cancelRecording(completer),
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1.5),
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),

              // Bouton Principal (Send ou Mic)
              GestureDetector(
                onTap: () {
                  if (viewModel.isProcessing) return;
                  viewModel.toggleRecording(completer);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  margin: EdgeInsets.only(left: viewModel.isRecording ? 0 : 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: viewModel.isProcessing 
                        ? kcPrimaryColorDark
                        : viewModel.isRecording 
                            ? kcTabIndicatorColor // Doré pour l'action principale
                            : kcPrimaryColorDark, // Fond plus sombre pour le micro
                  ),
                  child: Center(
                    child: Icon(
                      viewModel.isRecording ? Icons.send_rounded : Icons.mic_rounded,
                      color: viewModel.isRecording ? kcPrimaryColor : Colors.white, // Contraste ajusté
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  AiVoiceSheetModel viewModelBuilder(BuildContext context) => AiVoiceSheetModel();
}

class AudioVisualizer extends StatefulWidget {
  final double amplitude;
  final bool isRecording;

  const AudioVisualizer({
    Key? key,
    required this.amplitude,
    required this.isRecording,
  }) : super(key: key);

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int numberOfDots = 11;
  final List<double> _heights = List.filled(11, 6.0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() {
        setState(() {
           _updateHeights();
        });
      });
    _controller.repeat(reverse: true);
  }

  void _updateHeights() {
    if (!widget.isRecording) {
      for (int i = 0; i < numberOfDots; i++) {
        _heights[i] = 6.0;
      }
      return;
    }

    // Convertir l'amplitude (dB) en une valeur entre 0.0 et 1.0
    // -40 dB est souvent le bruit de fond, 0 dB est très fort
    double normalized = (widget.amplitude + 40) / 40; 
    normalized = normalized.clamp(0.0, 1.0);

    final random = Random();
    
    // Générer des hauteurs
    for (int i = 0; i < numberOfDots; i++) {
      // Les points au centre s'étirent plus que ceux sur les bords
      double positionFactor = 1.0 - (i - numberOfDots / 2).abs() / (numberOfDots / 2);
      
      // Hauteur minimale (6.0)
      double targetHeight = 6.0;
      
      if (normalized > 0.05) {
         // Variation liée au volume (normalized) + aléatoire pour l'effet d'onde
         targetHeight += (24.0 * normalized * positionFactor * (0.4 + random.nextDouble() * 0.6));
      } else {
         // Léger frémissement pour montrer que c'est "vivant" même dans le silence
         targetHeight += random.nextDouble() * 2.0 * positionFactor;
      }
      
      // Lissage de la transition
      _heights[i] = _heights[i] + (targetHeight - _heights[i]) * 0.6;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(numberOfDots, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 6,
            height: _heights[index],
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
