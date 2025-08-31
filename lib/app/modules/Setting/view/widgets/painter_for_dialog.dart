// Islamic pattern painter for header decoration
import 'package:flutter/material.dart';

class IslamicHeaderPainter extends CustomPainter {
  final Color color;

  IslamicHeaderPainter({this.color = Colors.black12});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create a repeating pattern of Islamic arches
    final patternWidth = size.width / 5;

    for (int i = 0; i < 5; i++) {
      double startX = i * patternWidth;
      double endX = (i + 1) * patternWidth;
      double centerX = (startX + endX) / 2;

      path.moveTo(startX, size.height);
      path.quadraticBezierTo(centerX, size.height * 0.3, endX, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
