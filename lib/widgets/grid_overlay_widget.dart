import 'package:flutter/material.dart';

class GridOverlayWidget extends StatelessWidget {
  final int divisions;
  final Color gridColor;

  const GridOverlayWidget({
    super.key,
    this.divisions = 3,
    this.gridColor = const Color(0x9900CEC9),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridPainter(divisions: divisions, gridColor: gridColor),
    );
  }
}

class _GridPainter extends CustomPainter {
  final int divisions;
  final Color gridColor;

  _GridPainter({required this.divisions, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    final double stepX = size.width / divisions;
    for (int i = 1; i < divisions; i++) {
      final double x = stepX * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final double stepY = size.height / divisions;
    for (int i = 1; i < divisions; i++) {
      final double y = stepY * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.divisions != divisions || oldDelegate.gridColor != gridColor;
  }
}
