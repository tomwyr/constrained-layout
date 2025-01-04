import 'package:flutter/widgets.dart';

import 'constraint.dart';
import 'layout_delegate.dart';

/// A layout widget that arranges its children based on constraints defined
/// for each child within [ConstrainedItem]. This widget utilizes a custom
/// layout delegate to position each child according to the constraints
/// declared for it.
///
/// [IdType] is a generic type representing the unique identifier type for
/// each [ConstrainedItem].
///
/// This widget allows creating flexible layouts by specifying positional
/// relationships between the child widgets, using the [Constraint] to define
/// edge-based positioning.
///
/// Example usage:
/// ```dart
/// ConstrainedLayout(
///   items: [
///     ConstrainedItem(
///       id: 'item1',
///       top: LinkToParent(),
///       child: YourWidget(),
///     ),
///     ConstrainedItem(
///       id: 'item2',
///       top: LinkTo(id: 'item1', edge: Edge.bottom),
///       child: AnotherWidget(),
///     ),
///   ],
/// );
/// ```
class ConstrainedLayout<IdType extends Object> extends StatelessWidget {
  const ConstrainedLayout({
    super.key,
    required this.items,
  });

  /// A list of [ConstrainedItem]s that define the child widgets and their
  /// associated layout constraints. Each [ConstrainedItem] is expected to have
  /// a unique identifier used to reference it in constraints of other items.
  final List<ConstrainedItem<IdType>> items;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: ConstrainedLayoutDelegate(items: items),
      children: [
        for (var item in items) LayoutId(id: item.id, child: item.child),
      ],
    );
  }
}

/// Represents a single item in the [ConstrainedLayout], including its unique
/// [id], layout constraints, and the widget [child] that will be positioned.
///
/// Example:
/// ```dart
/// ConstrainedItem(
///   id: 'item1',
///   top: LinkToParent(),
///   bottom: LinkTo(id: 'item2', edge: Edge.top),
///   child: YourWidget(),
/// );
/// ```
class ConstrainedItem<IdType> {
  ConstrainedItem({
    required this.id,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.child,
  });

  /// Unique identifier for the item, used to define positional constraints
  /// relative to other items.
  final IdType id;

  /// Constraint for the top edge of the item.
  final Constraint? top;

  /// Constraint for the bottom edge of the item.
  final Constraint? bottom;

  /// Constraint for the left edge of the item.
  final Constraint? left;

  /// Constraint for the right edge of the item.
  final Constraint? right;

  /// The child widget that will be displayed and positioned according to
  /// the declared constraints.
  final Widget child;

  /// Returns the constraint associated with a given [Edge].
  Constraint? constraintAlong(Edge edge) {
    return switch (edge) {
      Edge.top => top,
      Edge.bottom => bottom,
      Edge.left => left,
      Edge.right => right,
    };
  }

  /// Returns a new instance of [ConstrainedItem] with a modified constraint
  /// for a specific [Edge], while keeping the other constraints unchanged.
  ConstrainedItem<IdType> constrainedAlong(Constraint? constraint, Edge edge) {
    return ConstrainedItem(
      id: id,
      top: edge == Edge.top ? constraint : top,
      bottom: edge == Edge.bottom ? constraint : bottom,
      left: edge == Edge.left ? constraint : left,
      right: edge == Edge.right ? constraint : right,
      child: child,
    );
  }

  /// Returns a new instance of [ConstrainedItem] where the constraints are
  /// copied from another [ConstrainedItem], while keeping the other constraints
  /// unchanged.
  ConstrainedItem<IdType> withConstraintsOf(ConstrainedItem<IdType> item) {
    return ConstrainedItem(
      id: id,
      top: item.top,
      bottom: item.bottom,
      left: item.left,
      right: item.right,
      child: child,
    );
  }

  /// Returns a new instance of [ConstrainedItem] with the same [id] and layout
  /// constraints, but with a different [child] widget.
  ConstrainedItem<IdType> swapChild(Widget child) {
    return ConstrainedItem(
      id: id,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }

  @override
  String toString() {
    return 'ConstrainedItem(id: $id)';
  }
}
