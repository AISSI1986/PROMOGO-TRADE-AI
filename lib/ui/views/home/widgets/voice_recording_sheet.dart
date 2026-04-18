import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';

class VoiceRecordingSheet extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onToggleRecording;
  final VoidCallback onClose;

  const VoiceRecordingSheet({
    Key? key,
    required this.isRecording,
    required this.onToggleRecording,
    required this.onClose,
  }) : super(key: key);

  @override
  State<VoiceRecordingSheet> createState() => _VoiceRecordingSheetState();
}

class _VoiceRecordingSheetState extends State<VoiceRecordingSheet>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            widget.isRecording
                ? 'Écoute en cours...'
                : 'Appuyez pour parler',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kcPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dites le nom d\'un produit ou une commande',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),

          // Animated mic button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final scale = widget.isRecording ? _pulseAnimation.value : 1.0;
              return Transform.scale(
                scale: scale,
                child: GestureDetector(
                  onTap: widget.onToggleRecording,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: widget.isRecording
                            ? [const Color(0xFFFF4444), const Color(0xFFCC0000)]
                            : [const Color(0xFFFFD700), const Color(0xFFC6A75E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.isRecording
                              ? const Color(0xFFFF4444).withOpacity(0.4)
                              : const Color(0xFFFFD700).withOpacity(0.4),
                          blurRadius: widget.isRecording ? 20 : 12,
                          spreadRadius: widget.isRecording ? 4 : 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isRecording ? Icons.stop_rounded : Icons.mic,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Recording indicator waves
          if (widget.isRecording)
            _buildWaveIndicator(),

          const SizedBox(height: 16),

          // Close button
          TextButton(
            onPressed: widget.onClose,
            child: Text(
              'Fermer',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveIndicator() {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (index) {
          return AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final offset = (index - 3).abs() * 0.12;
              final height = 8.0 + (22.0 * (_pulseAnimation.value - 1.0 + offset).clamp(0.0, 1.0));
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 4,
                height: height,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
