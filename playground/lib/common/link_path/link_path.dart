import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/extensions.dart';
import '../custom_paint_widget.dart';
import 'link_path_recorder.dart';
import 'recorded_path.dart';

class LinkPath extends CustomPaintWidget {
  const LinkPath({
    super.key,
    this.animation,
    required this.type,
    required this.fromOffset,
    required this.toOffset,
    required this.fromEdge,
    required this.toEdge,
    required this.toParent,
  }) : super(repaint: animation);

  final ValueListenable<double>? animation;
  final LinkPathStyle type;
  final Offset fromOffset;
  final Offset toOffset;
  final Edge fromEdge;
  final Edge? toEdge;
  final bool toParent;

  double get time => animation?.value ?? 0;

  @override
  void paint(Canvas canvas, Size size) {
    final linkPath = LinkPathRecorder().create(
      fromOffset: fromOffset,
      toOffset: toOffset,
      fromEdge: fromEdge,
      toEdge: toEdge,
      toParent: toParent,
    );
    _drawLinkPath(canvas, linkPath);
    _drawMarker(canvas, linkPath);
  }

  void _drawLinkPath(Canvas canvas, RecordedPath linkPath) {
    final paint = Paint()
      ..strokeWidth = type.strokeWidth
      ..style = PaintingStyle.stroke
      ..color = type.color;
    canvas.drawDashedPath(linkPath.dartPath, 4, time, paint);
  }

  void _drawMarker(Canvas canvas, RecordedPath linkPath) {
    final LineSegment(:start, :end, :direction) = linkPath.segments.last;
    final (base, height) = (8.0, 8.0);
    final offset = end.shiftedBy(base, towards: start);
    final paint = Paint()..color = type.color;
    canvas.drawTriangle(offset, base, height, direction, paint);
  }

  @override
  bool shouldRepaint(LinkPath oldWidget) {
    return oldWidget.type != type ||
        oldWidget.fromOffset != fromOffset ||
        oldWidget.toOffset != toOffset ||
        oldWidget.fromEdge != fromEdge ||
        oldWidget.toEdge != toEdge ||
        oldWidget.toParent != toParent;
  }
}

enum LinkPathStyle {
  bold,
  normal,
  light;

  double get strokeWidth {
    return switch (this) {
      LinkPathStyle.bold => 1.5,
      LinkPathStyle.normal || LinkPathStyle.light => 1,
    };
  }

  Color get color {
    return switch (this) {
      LinkPathStyle.bold => Colors.black,
      LinkPathStyle.normal => Colors.grey[700]!,
      LinkPathStyle.light => Colors.grey[400]!,
    };
  }
}
