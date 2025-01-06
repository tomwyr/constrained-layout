import 'dart:math';

import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/widgets.dart';

extension IterableExtensions<E> on Iterable<E> {
  List<E> sortedBy([int Function(E a, E b)? compare]) {
    return toList()..sort(compare);
  }
}

extension MapExtensions<K, V> on Map<K, V> {
  Iterable<(K key, V value)> get records sync* {
    for (var entry in entries) {
      yield (entry.key, entry.value);
    }
  }
}

extension OffsetExtensions on Offset {
  Offset shiftedBy(double distance, {required Offset towards}) {
    final angle = (towards - this).direction;
    return Offset(
      dx + distance * cos(angle),
      dy + distance * sin(angle),
    );
  }
}

extension CanvasExtensions on Canvas {
  void drawDashedPath(
    Path path,
    double dashLength,
    double dashShift,
    Paint paint,
  ) {
    for (var metric in path.computeMetrics()) {
      if (dashShift >= 0.5 && dashShift < 1) {
        final firstDash = metric.extractPath(0, dashLength * dashShift);
        drawPath(firstDash, paint);
      }
      var totalLength = dashShift * 2 * dashLength;
      while (totalLength < metric.length) {
        final nextDash =
            metric.extractPath(totalLength, totalLength + dashLength);
        drawPath(nextDash, paint);
        totalLength += 2 * dashLength;
      }
    }
  }

  void drawTriangle(
    Offset offset,
    double base,
    double height,
    double direction,
    Paint paint,
  ) {
    final points = [
      offset + Offset.fromDirection(direction + pi / 2, base / 2),
      offset + Offset.fromDirection(direction - pi / 2, base / 2),
      offset + Offset.fromDirection(direction, height),
    ];
    final path = Path()..addPolygon(points, true);
    drawPath(path, paint);
  }
}

extension ConstrainedItemExtensions<IdType> on ConstrainedItem<IdType> {
  Map<Edge, Constraint?> get constraints {
    return {
      Edge.top: top,
      Edge.bottom: bottom,
      Edge.left: left,
      Edge.right: right,
    };
  }
}

extension GlobalKeyExtensions on GlobalKey {
  Offset get origin {
    return requireRenderBox().localToGlobal(Offset.zero);
  }

  Offset centerOfEdge(Edge edge) {
    final box = requireRenderBox();
    final Size(:width, :height) = box.size;
    final localCenter = switch (edge) {
      Edge.top => Offset(width / 2, 0),
      Edge.bottom => Offset(width / 2, height),
      Edge.left => Offset(0, height / 2),
      Edge.right => Offset(width, height / 2),
    };
    return box.localToGlobal(localCenter);
  }

  RenderBox requireRenderBox() {
    return currentContext?.findRenderObject() as RenderBox;
  }
}
