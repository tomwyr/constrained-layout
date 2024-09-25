sealed class Constraint {}

class AttachToParent extends Constraint {}

class AttachTo extends Constraint {
  AttachTo({
    required this.id,
    required this.edge,
  });

  final Object id;
  final Edge edge;
}

enum Edge {
  top,
  bottom,
  left,
  right,
}
