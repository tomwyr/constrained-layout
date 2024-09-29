import 'package:flutter/widgets.dart';

import 'constraint.dart';
import 'layout_order.dart';
import 'widget.dart';

class ConstrainedLayoutDelegate extends MultiChildLayoutDelegate {
  ConstrainedLayoutDelegate({
    super.relayout,
    required this.items,
    this.layoutOrder = const ConstrainedLayoutOrder(),
  }) {
    validateItems();
  }

  final List<ConstrainedItem> items;
  final ConstrainedLayoutOrder layoutOrder;

  @override
  void performLayout(Size size) {
    final parentSize = size;

    final sizesById = <Object, Size>{};
    final offsetsById = <Object, Offset>{};
    layoutById(Object id) => (
          size: sizesById[id] ?? (throw 'Item size requested before it was laid out'),
          offset: offsetsById[id] ?? (throw 'Item offset requested before it was positioned'),
        );

    final itemsInLayoutOrder = layoutOrder.ofItems(items);

    for (var item in itemsInLayoutOrder) {
      final itemSize = layoutChild(item.id, BoxConstraints.loose(parentSize));
      sizesById[item.id] = itemSize;
    }

    for (var item in itemsInLayoutOrder) {
      final itemSize = sizesById[item.id]!;

      double calcPosX() {
        switch ((item.left, item.right)) {
          case (null, null):
            return 0;

          case (null, AttachToParent()):
            return parentSize.width - itemSize.width;

          case (null, AttachTo(:var id, :var edge)):
            final target = layoutById(id);
            return switch (edge) {
              Edge.left => target.offset.dx - itemSize.width,
              Edge.right => target.offset.dx + target.size.width - itemSize.width,
              Edge.top ||
              Edge.bottom =>
                throw 'Horizontal constraint attached to vertical edge $edge',
            };

          case (AttachToParent(), null):
            return 0;

          case (AttachToParent(), AttachToParent()):
            return (parentSize.width - itemSize.width) / 2;

          case (AttachToParent(), AttachTo(:var id, :var edge)):
            final target = layoutById(id);
            return switch (edge) {
              Edge.left => (target.offset.dx - itemSize.width) / 2,
              Edge.right => (target.offset.dx + target.size.width - itemSize.width) / 2,
              Edge.top ||
              Edge.bottom =>
                throw 'Horizontal constraint attached to vertical edge $edge',
            };

          case (AttachTo(:var id, :var edge), null):
            final target = layoutById(id);
            return switch (edge) {
              Edge.left => target.offset.dx,
              Edge.right => target.offset.dx + target.size.width,
              Edge.top ||
              Edge.bottom =>
                throw 'Horizontal constraint attached to vertical edge $edge',
            };

          case (AttachTo(:var id, :var edge), AttachToParent()):
            final target = layoutById(id);
            return switch (edge) {
              Edge.left => target.offset.dx +
                  (parentSize.width - target.offset.dx - target.size.width - itemSize.width) / 2,
              Edge.right => target.offset.dx +
                  target.size.width +
                  (parentSize.width - target.offset.dx - target.size.width - itemSize.width) / 2,
              Edge.top ||
              Edge.bottom =>
                throw 'Horizontal constraint attached to vertical edge $edge',
            };

          case (
              AttachTo(id: var id1, edge: var edge1),
              AttachTo(id: var id2, edge: var edge2),
            ):
            final target1 = layoutById(id1);
            final topY = switch (edge1) {
              Edge.left => target1.offset.dx,
              Edge.right => target1.offset.dx + target1.size.width,
              Edge.top ||
              Edge.bottom =>
                throw 'Horizontal constraint attached to vertical edge $edge1',
            };
            final target2 = layoutById(id2);
            final bottomY = switch (edge2) {
              Edge.left => target2.offset.dx,
              Edge.right => target2.offset.dx + target2.size.width,
              Edge.top ||
              Edge.bottom =>
                throw 'Horizontal constraint attached to vertical edge $edge2',
            };
            return topY + (bottomY - topY - itemSize.width) / 2;
        }
      }

      double calcPosY() {
        switch ((item.top, item.bottom)) {
          case (null, null):
            return 0;

          case (null, AttachToParent()):
            return parentSize.height - itemSize.height;

          case (null, AttachTo(:var id, :var edge)):
            final target = layoutById(id);
            return switch (edge) {
              Edge.top => target.offset.dy - itemSize.height,
              Edge.bottom => target.offset.dy + target.size.height - itemSize.height,
              Edge.left ||
              Edge.right =>
                throw 'Vertical constraint attached to horizontal edge $edge',
            };

          case (AttachToParent(), null):
            return 0;

          case (AttachToParent(), AttachToParent()):
            return (parentSize.height - itemSize.height) / 2;

          case (AttachToParent(), AttachTo(:var id, :var edge)):
            final target = layoutById(id);
            return switch (edge) {
              Edge.top => (target.offset.dy - itemSize.height) / 2,
              Edge.bottom => (target.offset.dy + target.size.height - itemSize.height) / 2,
              Edge.left ||
              Edge.right =>
                throw 'Vertical constraint attached to horizontal edge $edge',
            };

          case (AttachTo(:var id, :var edge), null):
            final target = layoutById(id);
            return switch (edge) {
              Edge.top => target.offset.dy,
              Edge.bottom => target.offset.dy + target.size.height,
              Edge.left ||
              Edge.right =>
                throw 'Vertical constraint attached to horizontal edge $edge',
            };

          case (AttachTo(:var id, :var edge), AttachToParent()):
            final target = layoutById(id);
            return switch (edge) {
              Edge.top =>
                target.offset.dy + (parentSize.height - target.offset.dy - itemSize.height) / 2,
              Edge.bottom => target.offset.dy +
                  target.size.height +
                  (parentSize.height - target.offset.dy - target.size.height - itemSize.height) / 2,
              Edge.left ||
              Edge.right =>
                throw 'Vertical constraint attached to horizontal edge $edge',
            };

          case (
              AttachTo(id: var id1, edge: var edge1),
              AttachTo(id: var id2, edge: var edge2),
            ):
            final target1 = layoutById(id1);
            final topY = switch (edge1) {
              Edge.top => target1.offset.dy,
              Edge.bottom => target1.offset.dy + target1.size.height,
              Edge.left ||
              Edge.right =>
                throw 'Vertical constraint attached to horizontal edge $edge1',
            };
            final target2 = layoutById(id2);
            final bottomY = switch (edge2) {
              Edge.top => target2.offset.dy,
              Edge.bottom => target2.offset.dy + target2.size.height,
              Edge.left ||
              Edge.right =>
                throw 'Vertical constraint attached to horizontal edge $edge2',
            };
            return topY + (bottomY - topY - itemSize.height) / 2;
        }
      }

      final offset = Offset(calcPosX(), calcPosY());
      offsetsById[item.id] = offset;
      positionChild(item.id, offset);
    }
  }

  @override
  bool shouldRelayout(ConstrainedLayoutDelegate oldDelegate) {
    return oldDelegate.items != items;
  }

  void validateItems() {
    final idsInUse = <Object>{};
    for (var item in items) {
      if (!idsInUse.add(item.id)) {
        throw 'Id ${item.id} is already in use';
      }
    }
  }
}
