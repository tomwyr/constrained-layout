import 'package:flutter/foundation.dart';

sealed class Constraint {}

class AttachToParent extends Constraint {}

class AttachTo extends Constraint {
  AttachTo({
    required this.key,
    required this.edge,
  });

  final Key key;
  final Edge edge;
}

enum Edge {
  top,
  bottom,
  left,
  right,
}
