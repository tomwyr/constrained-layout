import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'utils/extensions.dart';
import 'widgets/custom_painter_widget.dart';

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
    final linkPath = getLinkPath();
    drawLinkPath(canvas, linkPath);
    drawMarker(canvas, linkPath);
  }

  void drawLinkPath(Canvas canvas, RecordedPath linkPath) {
    final paint = Paint()
      ..strokeWidth = type.strokeWidth
      ..style = PaintingStyle.stroke
      ..color = type.color;
    canvas.drawDashedPath(linkPath.dartPath, 4, time, paint);
  }

  void drawMarker(Canvas canvas, RecordedPath linkPath) {
    final LineSegment(:start, :end, :direction) = linkPath.segments.last;
    final (base, height) = (8.0, 8.0);
    final offset = end.shiftedBy(base, towards: start);
    final paint = Paint()..color = type.color;
    canvas.drawTriangle(offset, base, height, direction, paint);
  }

  RecordedPath getLinkPath() {
    const spacer = 14.0;
    final Offset(:dx, :dy) = toOffset - fromOffset;

    var path = RecordedPath()..moveTo(fromOffset.dx, fromOffset.dy);

    if (toParent) {
      switch (toEdge) {
        case Edge.top:
          path = path
            ..relativeLineTo(0, -spacer)
            ..relativeLineTo(dx, 0)
            ..relativeLineTo(0, dy + spacer);

        case Edge.bottom:
          path = path
            ..relativeLineTo(0, spacer)
            ..relativeLineTo(dx, 0)
            ..relativeLineTo(0, dy - spacer);

        case Edge.left:
          path = path
            ..relativeLineTo(-spacer, 0)
            ..relativeLineTo(0, dy)
            ..relativeLineTo(dx + spacer, 0);

        case Edge.right:
          path = path
            ..relativeLineTo(spacer, 0)
            ..relativeLineTo(0, dy)
            ..relativeLineTo(dx - spacer, 0);

        case null:
          break;
      }
    } else {
      switch ((fromEdge, toEdge)) {
        case (Edge.top, Edge.top):
          if (dy > 0) {
            path = path
              ..relativeLineTo(0, -spacer)
              ..relativeLineTo(dx, 0)
              ..relativeLineTo(0, dy + spacer);
          } else {
            path = path
              ..relativeLineTo(0, dy - spacer)
              ..relativeLineTo(dx, 0)
              ..relativeLineTo(0, spacer);
          }

        case (Edge.top, Edge.bottom):
          path = path
            ..relativeLineTo(0, -spacer)
            ..relativeLineTo(dx, 0)
            ..relativeLineTo(0, dy + spacer);

        case (Edge.bottom, Edge.bottom):
          if (dy > 0) {
            path = path
              ..relativeLineTo(0, dy + spacer)
              ..relativeLineTo(dx, 0)
              ..relativeLineTo(0, -spacer);
          } else {
            path = path
              ..relativeLineTo(0, spacer)
              ..relativeLineTo(dx, 0)
              ..relativeLineTo(0, dy - spacer);
          }

        case (Edge.bottom, Edge.top):
          path = path
            ..relativeLineTo(0, spacer)
            ..relativeLineTo(dx, 0)
            ..relativeLineTo(0, dy - spacer);

        case (Edge.left, Edge.left):
          if (dx > 0) {
            path = path
              ..relativeLineTo(-spacer, 0)
              ..relativeLineTo(0, dy)
              ..relativeLineTo(dx + spacer, 0);
          } else {
            path = path
              ..relativeLineTo(dx - spacer, 0)
              ..relativeLineTo(0, dy)
              ..relativeLineTo(spacer, 0);
          }

        case (Edge.left, Edge.right):
          path = path
            ..relativeLineTo(-spacer, 0)
            ..relativeLineTo(0, dy)
            ..relativeLineTo(dx + spacer, 0);

        case (Edge.right, Edge.right):
          if (dx > 0) {
            path = path
              ..relativeLineTo(dx + spacer, 0)
              ..relativeLineTo(0, dy)
              ..relativeLineTo(-spacer, 0);
          } else {
            path = path
              ..relativeLineTo(spacer, 0)
              ..relativeLineTo(0, dy)
              ..relativeLineTo(dx - spacer, 0);
          }

        case (Edge.right, Edge.left):
          path = path
            ..relativeLineTo(spacer, 0)
            ..relativeLineTo(0, dy)
            ..relativeLineTo(dx - spacer, 0);

        case ((_, _)):
          path = path..relativeLineTo(dx, dy);
      }
    }

    return path;
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

class RecordedPath {
  final _path = Path();
  final _segments = <LineSegment>[];

  var _position = Offset.zero;

  Path get dartPath => Path.from(_path);

  List<LineSegment> get segments => _segments.toList();

  void moveTo(double x, double y) {
    _path.moveTo(x, y);
    _position = Offset(x, y);
  }

  void relativeLineTo(double x, double y) {
    final (start, end) = (_position, _position + Offset(x, y));
    _segments.add(LineSegment(start, end));
    _path.relativeLineTo(x, y);
    _position = end;
  }
}

class LineSegment {
  LineSegment(this.start, this.end);

  final Offset start;
  final Offset end;

  double get direction => (end - start).direction;
}
