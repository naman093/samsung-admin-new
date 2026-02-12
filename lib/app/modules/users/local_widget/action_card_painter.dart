import 'package:flutter/material.dart';

class ActionCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );

    // Draw Inset Shadow
    // box-shadow: 1.18px -1.18px 1.18px 0px #00000040 inset;
    canvas.save();
    canvas.clipRRect(rrect);

    final Paint shadowPaint = Paint()
      ..color = const Color(0x40000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.18);

    final Path path = Path()
      ..addRect(Rect.fromLTWH(-50, -50, size.width + 100, size.height + 100))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    // Shift: 1.18px horizontal, -1.18px vertical
    canvas.translate(1.18, -1.18);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}