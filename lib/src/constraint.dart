import 'package:flutter/rendering.dart';

sealed class Constraint {}

class LinkToParent extends Constraint {}

class LinkTo<IdType> extends Constraint {
  LinkTo({
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
