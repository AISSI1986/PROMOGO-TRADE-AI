import 'dart:math';
import 'package:flutter/material.dart';

enum AfricanPatternType { zigzag, triangles, diamonds, dots }

class AfricanPatternPainter extends CustomPainter {
  final Color color;
  final AfricanPatternType type;
  final double opacity;

  AfricanPatternPainter({
    required this.color,
    required this.type,
    this.opacity = 0.1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    switch (type) {
      case AfricanPatternType.zigzag:
        _drawZigzag(canvas, size, paint);
        break;
      case AfricanPatternType.triangles:
        _drawTriangles(canvas, size, paint);
        break;
      case AfricanPatternType.diamonds:
        _drawDiamonds(canvas, size, paint);
        break;
      case AfricanPatternType.dots:
        _drawDots(canvas, size, paint);
        break;
    }
  }

  void _drawZigzag(Canvas canvas, Size size, Paint paint) {
    const spacing = 40.0;
    const waveHeight = 15.0;
    for (double y = -waveHeight; y < size.height + waveHeight; y += spacing) {
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 20) {
        path.lineTo(x + 10, y + waveHeight);
        path.lineTo(x + 20, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawTriangles(Canvas canvas, Size size, Paint paint) {
    const side = 30.0;
    for (double y = 0; y < size.height; y += side * 1.5) {
      for (double x = 0; x < size.width; x += side * 1.5) {
        final path = Path();
        path.moveTo(x, y + side);
        path.lineTo(x + side / 2, y);
        path.lineTo(x + side, y + side);
        path.close();
        canvas.drawPath(path, paint);
        
        // Add a smaller inverted triangle inside for detail
        final innerPath = Path();
        innerPath.moveTo(x + side / 4, y + side / 2);
        innerPath.lineTo(x + side * 3 / 4, y + side / 2);
        innerPath.lineTo(x + side / 2, y + side);
        innerPath.close();
        canvas.drawPath(innerPath, paint);
      }
    }
  }

  void _drawDiamonds(Canvas canvas, Size size, Paint paint) {
    const side = 40.0;
    for (double y = 0; y < size.height; y += side) {
      for (double x = (y % (side * 2) == 0 ? 0 : side); x < size.width; x += side * 2) {
        final path = Path();
        path.moveTo(x, y + side / 2);
        path.lineTo(x + side / 2, y);
        path.lineTo(x + side, y + side / 2);
        path.lineTo(x + side / 2, y + side);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawDots(Canvas canvas, Size size, Paint paint) {
    final dotPaint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    const spacing = 50.0;
    for (double y = 20; y < size.height; y += spacing) {
      for (double x = 20; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
        
        // Draw cross lines around the dot
        canvas.drawLine(Offset(x - 10, y), Offset(x + 10, y), paint);
        canvas.drawLine(Offset(x, y - 10), Offset(x, y + 10), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
