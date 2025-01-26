import 'dart:ui';

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
