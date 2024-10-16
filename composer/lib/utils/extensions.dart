import 'dart:math';
import 'dart:ui';

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
  void drawTriangle(Offset offset, double base, double height, double direction, Paint paint) {
    final points = [
      offset + Offset.fromDirection(direction + pi / 2, base / 2),
      offset + Offset.fromDirection(direction - pi / 2, base / 2),
      offset + Offset.fromDirection(direction, height),
    ];
    final path = Path()..addPolygon(points, true);
    drawPath(path, paint);
  }
}
