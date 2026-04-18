import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bouton IA avec Effets de Fumée Bleue et Particules (Fidèle à la vidéo).
/// Suppression complète du balayage blanc (shimmer).
class IaButton extends StatefulWidget {
  final VoidCallback onTap;
  const IaButton({Key? key, required this.onTap}) : super(key: key);

  @override
  State<IaButton> createState() => _IaButtonState();
}

class _IaButtonState extends State<IaButton> with TickerProviderStateMixin {
  late final AnimationController _mainController;
  ui.Image? _logoImage;
  bool _isLoading = true;
  final List<_SmokeParticle> _smokeParticles = List.generate(12, (_) => _SmokeParticle()); // Réduit de 20 à 12

  @override
  void initState() {
    super.initState();
    _loadAsset();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  Future<void> _loadAsset() async {
    try {
      final data = await rootBundle.load('assets/images/logo bouton IA.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frameInfo = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _logoImage = frameInfo.image;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement IA Logo: $e");
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _logoImage == null) {
      return const SizedBox.expand();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: RepaintBoundary(
        child: SizedBox.expand(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _IAEffectsPainter(
                    image: _logoImage!,
                    progress: _mainController.value,
                    particles: _smokeParticles,
                  ),
                );
              },
            ),
        ),
      ),
    );
  }
}

class _SmokeParticle {
  late double x, y, size, alpha, speed, angle;
  _SmokeParticle() {
    _reset();
  }
  void _reset() {
    x = 0.5;
    y = 0.5;
    size = 3.0 + math.Random().nextDouble() * 10.0;
    alpha = 0.05 + math.Random().nextDouble() * 0.2;
    speed = 0.002 + math.Random().nextDouble() * 0.005;
    angle = math.Random().nextDouble() * math.pi * 2;
  }
  void update() {
    x += math.cos(angle) * speed;
    y += math.sin(angle) * speed;
    alpha *= 0.98;
    size *= 1.01;
    if (alpha < 0.01) _reset();
  }
}

class _IAEffectsPainter extends CustomPainter {
  final ui.Image image;
  final double progress;
  final List<_SmokeParticle> particles;

  _IAEffectsPainter({
    required this.image,
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ui.Offset center = Offset(size.width / 2, size.height / 2);
    // Le halo externe est maintenant géré par le BoxShadow du parent.
    // L'intérieur dessine juste l'énergie bleue et le logo.

    // Énergie de fumée bleue interne
    for (var p in particles) {
      p.update();
      final smokePaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(p.x * size.width, p.y * size.height),
          p.size,
          [
            const Color(0xFF00E5FF).withOpacity(p.alpha),
            const Color(0xFF00E5FF).withOpacity(0.0),
          ],
        )
        ..blendMode = BlendMode.screen;
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, smokePaint);
    }

    // Restauration de la forme originale : pas de zoom, pas de décalage
    final double zoom = 1.0; 
    final ui.Offset centralPoint = Offset(size.width / 2, size.height / 2);
    final Rect destRect = Rect.fromCenter(
      center: centralPoint,
      width: size.width,
      height: size.height,
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      destRect,
      Paint(),
    );

    // Le "Tracer" Cyan - Cercle de lumière COLLÉ AU BORD NATUREL
    // On l'ajuste pour qu'il suive le bord de l'image 1.0
    final tracerPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    // On décale le cercle de 5px vers la droite pour parfaire le centrage visuel
    final ui.Offset circleCenter = Offset(centralPoint.dx + 5, centralPoint.dy);

    // Le rayon est ajusté pour coller au bord brillant sans couper l'image
    canvas.drawCircle(circleCenter, (size.width / 2) * 0.60, tracerPaint);

    // Petite lueur sur le trait
    canvas.drawCircle(
      circleCenter, 
      (size.width / 2) * 0.60, 
      Paint()
        ..color = Colors.cyanAccent.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );

    // Éclat "Blim" électrique sur le Logo (Optionnel, on le garde léger)
    final double pulse = (math.sin(progress * math.pi * 4) + 1) / 2;
    // Suppression du pulsePaint externe qui faisait "doublon"
    // L'icône se suffit maintenant à elle-même avec son halo cyan parent.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
