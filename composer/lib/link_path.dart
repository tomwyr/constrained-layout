import 'package:flutter/material.dart';

class LinkPath extends StatelessWidget {
  const LinkPath({
    super.key,
    required this.active,
    required this.from,
    required this.to,
  });

  final bool active;
  final Offset from;
  final Offset to;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TargetPathPainter(
        active: active,
        from: from,
        to: to,
      ),
    );
  }
}

class TargetPathPainter extends CustomPainter {
  TargetPathPainter({
    required this.active,
    required this.from,
    required this.to,
  });

  final bool active;
  final Offset from;
  final Offset to;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = active ? 1.5 : 1
      ..color = active ? Colors.black : Colors.grey;
    canvas.drawLine(from, to, paint);
  }

  @override
  bool shouldRepaint(TargetPathPainter oldDelegate) {
    return oldDelegate.from != from || oldDelegate.to != to;
  }
}
