import 'package:flutter/material.dart';
import 'dart:math' as math;

class GeminiAiButton extends StatefulWidget {
  final VoidCallback onPressed;
  const GeminiAiButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  _GeminiAiButtonState createState() => _GeminiAiButtonState();
}

class _GeminiAiButtonState extends State<GeminiAiButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
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
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4285F4).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2 * math.sin(_controller.value * 2 * math.pi).abs(),
                ),
                BoxShadow(
                  color: const Color(0xFF9B72CB).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
              ],
              gradient: SweepGradient(
                center: Alignment.center,
                startAngle: 0.0,
                endAngle: math.pi * 2,
                transform: GradientRotation(_controller.value * 2 * math.pi),
                colors: const [
                  Color(0xFF4285F4), // Blue
                  Color(0xFF9B72CB), // Purple
                  Color(0xFFD96570), // Pink/Red
                  Color(0xFFF4AF5F), // Orange/Yellow
                  Color(0xFF4285F4), // Back to Blue
                ],
              ),
            ),
            child: const Center(
              child: Text(
                'IA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
