import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'ai_voice_sheet_model.dart';

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
    return Container(
      margin: const EdgeInsets.all(16), // Floating effect at the very bottom
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Animated Mic Button (Compact)
            _CompactVoiceButton(
              isRecording: viewModel.isRecording,
              isProcessing: viewModel.isProcessing,
              onTap: viewModel.toggleRecording,
            ),
            const SizedBox(width: 16),
            
            // Text Content
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.isProcessing 
                        ? "Analyse..." 
                        : viewModel.isRecording 
                            ? "Je vous écoute..." 
                            : "Dites une commande",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kcPrimaryColor,
                    ),
                  ),
                  if (viewModel.agentResponse != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        viewModel.agentResponse!,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            
            // Close Button
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.grey),
              onPressed: () => completer(SheetResponse(confirmed: true)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  AiVoiceSheetModel viewModelBuilder(BuildContext context) => AiVoiceSheetModel();
}

class _CompactVoiceButton extends StatefulWidget {
  final bool isRecording;
  final bool isProcessing;
  final VoidCallback onTap;

  const _CompactVoiceButton({
    required this.isRecording,
    required this.isProcessing,
    required this.onTap,
  });

  @override
  State<_CompactVoiceButton> createState() => _CompactVoiceButtonState();
}

class _CompactVoiceButtonState extends State<_CompactVoiceButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = widget.isRecording ? 1.0 + (_pulseController.value * 0.1) : 1.0;
          
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.isRecording
                      ? [const Color(0xFFFF4B4B), const Color(0xFFFF2121)]
                      : widget.isProcessing
                          ? [Colors.blue.shade400, Colors.blue.shade700]
                          : [kcPrimaryColor, kcPrimaryColor.withOpacity(0.8)],
                ),
                boxShadow: widget.isRecording ? [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ] : [],
              ),
              child: widget.isProcessing
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Icon(
                      widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
          );
        },
      ),
    );
  }
}
