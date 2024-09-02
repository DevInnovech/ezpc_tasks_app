import 'package:flutter/material.dart';

class DetailsCustomShape extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.1066667, size.height * 0.09783585);
    path_0.cubicTo(size.width * 0.04775627, size.height * 0.09783585, 0,
        size.height * 0.2667849, 0, size.height * 0.4751943);
    path_0.lineTo(0, size.height * 0.9940660);
    path_0.lineTo(size.width, size.height * 0.9940660);
    path_0.lineTo(size.width, size.height * 0.4751943);
    path_0.cubicTo(
        size.width,
        size.height * 0.2667849,
        size.width * 0.9522427,
        size.height * 0.09783585,
        size.width * 0.8933333,
        size.height * 0.09783585);
    path_0.lineTo(size.width * 0.6726027, size.height * 0.09783585);
    path_0.cubicTo(
        size.width * 0.6491920,
        size.height * 0.09783585,
        size.width * 0.6258827,
        size.height * 0.08692915,
        size.width * 0.6032773,
        size.height * 0.06539755);
    path_0.lineTo(size.width * 0.5686720, size.height * 0.03243802);
    path_0.cubicTo(
        size.width * 0.5228347,
        size.height * -0.01122160,
        size.width * 0.4745307,
        size.height * -0.01080170,
        size.width * 0.4287547,
        size.height * 0.03365453);
    path_0.lineTo(size.width * 0.3973200, size.height * 0.06418094);
    path_0.cubicTo(
        size.width * 0.3743227,
        size.height * 0.08651642,
        size.width * 0.3505787,
        size.height * 0.09783585,
        size.width * 0.3267307,
        size.height * 0.09783585);
    path_0.lineTo(size.width * 0.1066667, size.height * 0.09783585);
    path_0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Colors.white.withOpacity(1.0);
    canvas.drawPath(path_0, paint0Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
