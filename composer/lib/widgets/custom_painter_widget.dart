import 'package:flutter/material.dart';

abstract class CustomPaintWidget extends StatelessWidget {
  const CustomPaintWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CustomPaintPainter(this),
    );
  }

  void paint(Canvas canvas, Size size);

  bool shouldRepaint(covariant CustomPaintWidget oldWidget);
}

class _CustomPaintPainter extends CustomPainter {
  _CustomPaintPainter(this.widget);

  final CustomPaintWidget widget;

  @override
  void paint(Canvas canvas, Size size) {
    widget.paint(canvas, size);
  }

  @override
  bool shouldRepaint(_CustomPaintPainter oldDelegate) {
    return widget.shouldRepaint(oldDelegate.widget);
  }
}
