import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/bottom_sheets/ai_voice/ai_voice_sheet_model.dart';
import 'package:promogoai/ui/bottom_sheets/ai_voice/ai_voice_sheet.dart'; // Pour AudioVisualizer
import 'package:stacked_services/stacked_services.dart';

class AiVoiceBar extends StackedView<AiVoiceSheetModel> {
  final Function(Map<String, dynamic>) onResult;
  final VoidCallback onCancel;

  const AiVoiceBar({
    Key? key,
    required this.onResult,
    required this.onCancel,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: kcPrimaryColor,
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


          // Bouton Fermer (anciennement +)
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 24),
            onPressed: onCancel,
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
          
          // Bouton Principal (Send ou Mic)
          GestureDetector(
            onTap: () {
              if (viewModel.isProcessing) return;
              
              // On adapte toggleRecording pour qu'il nous donne le résultat
              viewModel.toggleRecording((response) {
                if (response.confirmed && response.data != null) {
                  onResult(response.data as Map<String, dynamic>);
                }
              });
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: viewModel.isProcessing 
                    ? kcPrimaryColorDark
                    : viewModel.isRecording 
                        ? kcTabIndicatorColor 
                        : kcPrimaryColorDark,
              ),
              child: Center(
                child: Icon(
                  viewModel.isRecording ? Icons.send_rounded : Icons.mic_rounded,
                  color: viewModel.isRecording ? kcPrimaryColor : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  AiVoiceSheetModel viewModelBuilder(BuildContext context) => AiVoiceSheetModel();
}
