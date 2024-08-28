import 'package:flutter/material.dart';

class CustomCurveShape extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(0, size.height * 0.2171147);
    path_0.cubicTo(
        0,
        size.height * 0.1218931,
        size.width * 0.04775627,
        size.height * 0.04470086,
        size.width * 0.1066667,
        size.height * 0.04470086);
    path_0.lineTo(size.width * 0.3267307, size.height * 0.04470086);
    path_0.cubicTo(
        size.width * 0.3505787,
        size.height * 0.04470086,
        size.width * 0.3743227,
        size.height * 0.03952905,
        size.width * 0.3973200,
        size.height * 0.02932405);
    path_0.lineTo(size.width * 0.4287547, size.height * 0.01537664);
    path_0.cubicTo(
        size.width * 0.4745307,
        size.height * -0.004935259,
        size.width * 0.5228347,
        size.height * -0.005127112,
        size.width * 0.5686720,
        size.height * 0.01482082);
    path_0.lineTo(size.width * 0.6032773, size.height * 0.02987991);
    path_0.cubicTo(
        size.width * 0.6258827,
        size.height * 0.03971763,
        size.width * 0.6491920,
        size.height * 0.04470086,
        size.width * 0.6726027,
        size.height * 0.04470086);
    path_0.lineTo(size.width * 0.8933333, size.height * 0.04470086);
    path_0.cubicTo(size.width * 0.9522427, size.height * 0.04470086, size.width,
        size.height * 0.1218931, size.width, size.height * 0.2171147);
    path_0.lineTo(size.width, size.height * 0.3448276);
    path_0.lineTo(size.width, size.height * 0.4541853);
    path_0.lineTo(size.width, size.height * 0.6093578);
    path_0.lineTo(size.width, size.height * 0.7370690);
    path_0.lineTo(size.width, size.height * 0.8464267);
    path_0.lineTo(size.width, size.height);
    path_0.lineTo(0, size.height);
    path_0.lineTo(0, size.height * 0.8464267);
    path_0.lineTo(0, size.height * 0.7370690);
    path_0.lineTo(0, size.height * 0.6093578);
    path_0.lineTo(0, size.height * 0.4541853);
    path_0.lineTo(0, size.height * 0.3448276);
    path_0.lineTo(0, size.height * 0.2171147);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Colors.white.withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
