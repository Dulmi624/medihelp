import 'package:flutter/material.dart';

class MedicalLogo extends StatelessWidget {
  const MedicalLogo({this.size = 142, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/medihelp_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

class MedicalLogoPainter extends CustomPainter {
  const MedicalLogoPainter(this.pulseColor, this.logoColor);

  final Color pulseColor;
  final Color logoColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.43;
    final outline = Paint()
      ..color = logoColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.045;
    final upperArc = Path()
      ..moveTo(center.dx - radius * .94, center.dy + radius * .18)
      ..cubicTo(
        center.dx - radius * 1.2,
        center.dy - radius * .95,
        center.dx + radius * .7,
        center.dy - radius * 1.26,
        center.dx + radius * 1.03,
        center.dy - radius * .25,
      );
    canvas.drawPath(upperArc, outline);
    final lowerArc = Path()
      ..moveTo(center.dx + radius, center.dy - radius * .15)
      ..cubicTo(
        center.dx + radius * 1.22,
        center.dy + radius * .72,
        center.dx + radius * .48,
        center.dy + radius * 1.13,
        center.dx,
        center.dy + radius * 1.12,
      )
      ..cubicTo(
        center.dx - radius * .55,
        center.dy + radius * 1.1,
        center.dx - radius * 1.12,
        center.dy + radius * .73,
        center.dx - radius * 1.05,
        center.dy + radius * .2,
      );
    canvas.drawPath(lowerArc, outline);
    final handPaint = Paint()
      ..color = logoColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * .035;
    for (final direction in [-1.0, 1.0]) {
      final hand = Path()
        ..moveTo(center.dx + direction * radius * .77, center.dy + radius * .22)
        ..cubicTo(
          center.dx + direction * radius * .58,
          center.dy + radius * .62,
          center.dx + direction * radius * .23,
          center.dy + radius * .65,
          center.dx,
          center.dy + radius * 1.1,
        );
      canvas.drawPath(hand, handPaint);
    }
    final crossPaint = Paint()..color = logoColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: radius * 1.06,
          height: radius * .7,
        ),
        Radius.circular(radius * .1),
      ),
      crossPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: radius * .7,
          height: radius * 1.35,
        ),
        Radius.circular(radius * .1),
      ),
      crossPaint,
    );
    final pulse = Path()
      ..moveTo(center.dx - radius * .51, center.dy - radius * .03)
      ..lineTo(center.dx - radius * .25, center.dy - radius * .03)
      ..lineTo(center.dx - radius * .13, center.dy - radius * .16)
      ..lineTo(center.dx - radius * .04, center.dy + radius * .2)
      ..lineTo(center.dx + radius * .09, center.dy - radius * .28)
      ..lineTo(center.dx + radius * .18, center.dy + radius * .05)
      ..lineTo(center.dx + radius * .51, center.dy + radius * .05);
    final pulsePaint = Paint()
      ..color = pulseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(pulse, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant MedicalLogoPainter oldDelegate) =>
      pulseColor != oldDelegate.pulseColor ||
      logoColor != oldDelegate.logoColor;
}
