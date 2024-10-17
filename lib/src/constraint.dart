import 'package:flutter/rendering.dart';

/// Base class representing a constraint applied to a layout edge.
///
/// Subclasses of [Constraint] define specific types of constraints.
sealed class Constraint {}

/// A constraint that links an item's edge to the corresponding edge of its
/// parent render box, aligning the item within the parent's boundary.
class LinkToParent extends Constraint {}

/// A constraint that links an item's edge to the edge of another item within
/// the same layout. The [id] refers to the other item, and the [edge] defines
/// which edge of the target item to link to.
class LinkTo<IdType> extends Constraint {
  LinkTo({
    required this.id,
    required this.edge,
  });

  /// The unique identifier of the target item to which this edge is linked.
  final IdType id;

  /// The edge of the target item to which this edge is constrained.
  final Edge edge;
}

/// Enum representing the possible edges of an item in the layout.
enum Edge {
  /// Top edge of the item.
  top,

  /// Bottom edge of the item.
  bottom,

  /// Left edge of the item.
  left,

  /// Right edge of the item.
  right;

  /// Converts the [Edge] to a corresponding [Alignment] value, useful for
  /// aligning widgets in a layout.
  Alignment toAlignment() {
    return switch (this) {
      Edge.top => Alignment.topCenter,
      Edge.bottom => Alignment.bottomCenter,
      Edge.left => Alignment.centerLeft,
      Edge.right => Alignment.centerRight,
    };
  }

  /// Returns the axis (horizontal or vertical) associated with this edge.
  Axis get axis {
    return switch (this) {
      Edge.top || Edge.bottom => Axis.vertical,
      Edge.left || Edge.right => Axis.horizontal,
    };
  }
}
