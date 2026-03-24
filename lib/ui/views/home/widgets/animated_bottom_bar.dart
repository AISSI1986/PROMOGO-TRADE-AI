import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import '../home_view.dart';

class AnimatedBottomBar extends StatefulWidget {
  final Widget child;
  const AnimatedBottomBar({Key? key, required this.child}) : super(key: key);

  @override
  _AnimatedBottomBarState createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<AnimatedBottomBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
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
        return CustomPaint(
          painter: FuturisticBottomBarPainter(animationValue: _controller.value),
          child: widget.child,
        );
      },
    );
  }
}
