import 'package:flutter/material.dart';

class GridOverlayPainter extends CustomPainter {
  final int divisions; // e.g. 3, 4, 8
  final Color gridColor;
  final bool showDiagonals;

  GridOverlayPainter({
    required this.divisions,
    required this.gridColor,
    this.showDiagonals = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final borderPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.9)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw outer boundary
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    // Draw vertical lines
    final double stepX = size.width / divisions;
    for (int i = 1; i < divisions; i++) {
      final double x = stepX * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    final double stepY = size.height / divisions;
    for (int i = 1; i < divisions; i++) {
      final double y = stepY * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw diagonal guides if enabled (classic drawing proportion method)
    if (showDiagonals) {
      final diagPaint = Paint()
        ..color = gridColor.withValues(alpha: 0.4)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;

      canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), diagPaint);
      canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), diagPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GridOverlayPainter oldDelegate) {
    return oldDelegate.divisions != divisions ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.showDiagonals != showDiagonals;
  }
}
