import 'package:flutter/rendering.dart';

sealed class Constraint {}

class AttachToParent extends Constraint {}

class AttachTo<IdType> extends Constraint {
  AttachTo({
    required this.id,
    required this.edge,
  });

  final IdType id;
  final Edge edge;
}

enum Edge {
  top,
  bottom,
  left,
  right;

  Alignment toAlignment() {
    return switch (this) {
      Edge.top => Alignment.topCenter,
      Edge.bottom => Alignment.bottomCenter,
      Edge.left => Alignment.centerLeft,
      Edge.right => Alignment.centerRight,
    };
  }
}
