import 'package:flutter/widgets.dart';

import 'constraint.dart';
import 'layout_delegate.dart';

class ConstrainedLayout<IdType> extends StatelessWidget {
  const ConstrainedLayout({
    super.key,
    required this.items,
  });

  final List<ConstrainedItem<IdType>> items;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: ConstrainedLayoutDelegate(items: items),
      children: [
        for (var item in items) LayoutId(id: item.child, child: item.child),
      ],
    );
  }
}

class ConstrainedItem<IdType> {
  ConstrainedItem({
    required this.id,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.child,
  });

  final IdType id;
  final Constraint? top;
  final Constraint? bottom;
  final Constraint? left;
  final Constraint? right;
  final Widget child;

  Constraint? constraintAt(Edge edge) {
    return switch (edge) {
      Edge.top => top,
      Edge.bottom => bottom,
      Edge.left => left,
      Edge.right => right,
    };
  }
}
