import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

import 'recorded_path.dart';

class LinkPathRecorder {
  RecordedPath create({
    required Offset fromOffset,
    required Offset toOffset,
    required Edge fromEdge,
    required Edge? toEdge,
    required bool toParent,
    double spacer = 14.0,
  }) {
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
}
