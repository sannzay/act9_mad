import 'dart:math';
import 'package:flutter/material.dart';

class SpookyBackgroundPainter extends CustomPainter {
  final double progress; 
  SpookyBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rect = Offset.zero & size;
    final gradient = RadialGradient(
      center: Alignment(-0.2, -0.6),
      radius: 1.0,
      colors: [Colors.indigo.shade900, Colors.black87],
    );
    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    final moonPaint =
        Paint()..color = Colors.yellow.shade200.withOpacity(0.95);
    final moonCenter = Offset(size.width * 0.85, size.height * 0.18);
    canvas.drawCircle(moonCenter,
        min(size.width, size.height) * 0.08, moonPaint);

    final ground = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(
          size.width * 0.2, size.height * 0.7, size.width * 0.42, size.height * 0.84)
      ..quadraticBezierTo(
          size.width * 0.6, size.height * 0.9, size.width * 0.8, size.height * 0.78)
      ..lineTo(size.width, size.height * 0.78)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(ground, Paint()..color = Colors.black.withOpacity(0.9));

    final batPaint = Paint()..color = Colors.black87;
    const batCount = 4;
    for (var i = 0; i < batCount; i++) {
      final phase = (progress + i / batCount) % 1.0;
      final x = size.width * (1.0 - phase);
      final y = size.height * (0.12 + 0.15 * sin((progress + i) * pi * 2));
      drawBat(canvas, Offset(x, y), 16 + 6 * sin((progress + i) * 3), batPaint);
    }
  }

  void drawBat(Canvas canvas, Offset p, double s, Paint paint) {
    final path = Path();
    path.moveTo(p.dx, p.dy);
    path.relativeQuadraticBezierTo(-s, -s * 0.4, -s * 1.5, 0);
    path.relativeQuadraticBezierTo(s * 0.6, s * 0.2, s * 2.0, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SpookyBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
