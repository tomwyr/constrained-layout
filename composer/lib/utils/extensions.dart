import 'dart:math';
import 'dart:ui';

import 'package:constrained_layout/constrained_layout.dart';

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
  void drawDashedPath(Path path, double dashLength, Paint paint) {
    for (var metric in path.computeMetrics()) {
      var segments = metric.length ~/ dashLength;
      for (var i = 0; i < segments; i++) {
        if (i % 2 == 1) continue;
        final start = dashLength * i;
        final dashPath = metric.extractPath(start, start + dashLength);
        drawPath(dashPath, paint);
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
  Map<Edge, Constraint?> get constraints => {
        Edge.top: top,
        Edge.bottom: bottom,
        Edge.left: left,
        Edge.right: right,
      };
}
