import 'dart:math' as math;
import 'package:flutter/material.dart';

class LotusPainter extends CustomPainter {
  final double scale;
  final double glow;

  const LotusPainter({required this.scale, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 * scale;

    _drawGlow(canvas, c, r);
    _drawOuterRing(canvas, c, r);
    _drawPetals(canvas, c, r * 0.80, 8, 0.0, 0.36, 0.80);
    _drawPetals(canvas, c, r * 0.52, 6, math.pi / 6, 0.30, 0.70);
    _drawCenter(canvas, c, r * 0.20);
  }

  void _drawGlow(Canvas canvas, Offset c, double r) {
    for (final entry in [(1.25, 0.06), (1.05, 0.12), (0.85, 0.18)]) {
      canvas.drawCircle(
        c,
        r * entry.$1,
        Paint()
          ..color = Color.fromRGBO(124, 111, 255, entry.$2 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36),
      );
    }
  }

  void _drawOuterRing(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(
      c, r,
      Paint()
        ..color = Color.fromRGBO(255, 255, 255, 0.10 * glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawCircle(
      c, r * 1.06,
      Paint()
        ..color = Color.fromRGBO(255, 255, 255, 0.04 * glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  void _drawPetals(Canvas canvas, Offset c, double r, int count,
      double offset, double wRatio, double hRatio) {
    for (int i = 0; i < count; i++) {
      final angle = offset + (i * 2 * math.pi / count) - math.pi / 2;
      _petal(canvas, c, r, angle, wRatio, hRatio);
    }
  }

  void _petal(Canvas canvas, Offset c, double r, double angle,
      double wR, double hR) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);

    final w = r * wR;
    final h = r * hR;
    const tip = 0.08;

    final path = Path()
      ..moveTo(0, r * tip)
      ..cubicTo(-w, r * tip * 0.4, -w * 0.75, -h * 0.65, 0, -h)
      ..cubicTo(w * 0.75, -h * 0.65, w, r * tip * 0.4, 0, r * tip)
      ..close();

    final rect =
        Rect.fromCenter(center: Offset(0, -h / 2), width: w * 2, height: h);

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color.fromRGBO(155, 143, 255, 0.14 + 0.22 * glow),
            Color.fromRGBO(196, 190, 255, 0.30 + 0.28 * glow),
            Color.fromRGBO(255, 255, 255, 0.08 + 0.14 * glow),
          ],
        ).createShader(rect)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Color.fromRGBO(255, 255, 255, 0.10 + 0.08 * glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    canvas.restore();
  }

  void _drawCenter(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(
      c, r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.fromRGBO(255, 255, 255, 0.95),
            Color.fromRGBO(180, 172, 255, 0.55),
            Color.fromRGBO(124, 111, 255, 0.20),
            Color.fromRGBO(124, 111, 255, 0.00),
          ],
          stops: const [0.0, 0.25, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    canvas.drawCircle(
      c, r * 0.55,
      Paint()
        ..color = Color.fromRGBO(255, 255, 255, 0.35 * glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(LotusPainter old) =>
      old.scale != scale || old.glow != glow;
}
