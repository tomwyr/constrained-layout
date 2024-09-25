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

    final sizesByKey = <Key, Size>{};
    final offsetsByKey = <Key, Offset>{};
    layoutByKey(Key key) => (
          size: sizesByKey[key] ?? (throw 'Item size requested before it was laid out'),
          offset: offsetsByKey[key] ?? (throw 'Item offset requested before it was positioned'),
        );

    final itemsInLayoutOrder = layoutOrder.ofItems(items);

    for (var item in itemsInLayoutOrder) {
      final key = item.child.key!;
      final itemSize = layoutChild(item.child, BoxConstraints.loose(parentSize));
      sizesByKey[key] = itemSize;
    }

    for (var item in itemsInLayoutOrder) {
      final itemKey = item.child.key!;
      final itemSize = sizesByKey[itemKey]!;

      double calcPosX() {
        switch ((item.left, item.right)) {
          case (null, null):
            return 0;

          case (null, AttachToParent()):
            return parentSize.width - itemSize.width;

          case (null, AttachTo(:var key, :var edge)):
            final target = layoutByKey(key);
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

          case (AttachToParent(), AttachTo(:var key, :var edge)):
            final target = layoutByKey(key);
            return switch (edge) {
              Edge.left => (target.offset.dx - itemSize.width) / 2,
              Edge.right => (target.offset.dx + target.size.width - itemSize.width) / 2,
              Edge.top ||
              Edge.bottom =>
                throw 'Horizontal constraint attached to vertical edge $edge',
            };

          case (AttachTo(:var key, :var edge), null):
            final target = layoutByKey(key);
            return switch (edge) {
              Edge.left => target.offset.dx,
              Edge.right => target.offset.dx + target.size.width,
              Edge.top ||
              Edge.bottom =>
                throw 'Horizontal constraint attached to vertical edge $edge',
            };

          case (AttachTo(:var key, :var edge), AttachToParent()):
            final target = layoutByKey(key);
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
              AttachTo(key: var key1, edge: var edge1),
              AttachTo(key: var key2, edge: var edge2),
            ):
            final target1 = layoutByKey(key1);
            final topY = switch (edge1) {
              Edge.left => target1.offset.dx,
              Edge.right => target1.offset.dx + target1.size.width,
              Edge.top ||
              Edge.bottom =>
                throw 'Horizontal constraint attached to vertical edge $edge1',
            };
            final target2 = layoutByKey(key2);
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

          case (null, AttachTo(:var key, :var edge)):
            final target = layoutByKey(key);
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

          case (AttachToParent(), AttachTo(:var key, :var edge)):
            final target = layoutByKey(key);
            return switch (edge) {
              Edge.top => (target.offset.dy - itemSize.height) / 2,
              Edge.bottom => (target.offset.dy + target.size.height - itemSize.height) / 2,
              Edge.left ||
              Edge.right =>
                throw 'Vertical constraint attached to horizontal edge $edge',
            };

          case (AttachTo(:var key, :var edge), null):
            final target = layoutByKey(key);
            return switch (edge) {
              Edge.top => target.offset.dy,
              Edge.bottom => target.offset.dy + target.size.height,
              Edge.left ||
              Edge.right =>
                throw 'Vertical constraint attached to horizontal edge $edge',
            };

          case (AttachTo(:var key, :var edge), AttachToParent()):
            final target = layoutByKey(key);
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
              AttachTo(key: var key1, edge: var edge1),
              AttachTo(key: var key2, edge: var edge2),
            ):
            final target1 = layoutByKey(key1);
            final topY = switch (edge1) {
              Edge.top => target1.offset.dy,
              Edge.bottom => target1.offset.dy + target1.size.height,
              Edge.left ||
              Edge.right =>
                throw 'Vertical constraint attached to horizontal edge $edge1',
            };
            final target2 = layoutByKey(key2);
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
      offsetsByKey[itemKey] = offset;
      positionChild(item.child, offset);
    }
  }

  @override
  bool shouldRelayout(ConstrainedLayoutDelegate oldDelegate) {
    return oldDelegate.items != items;
  }

  void validateItems() {
    final keysInUse = <Key>{};
    for (var (index, item) in items.indexed) {
      final key = item.child.key;
      if (key == null) {
        throw 'Key is missing for item at position $index';
      }
      if (!keysInUse.add(key)) {
        throw 'Key $key is already in use';
      }
    }
  }
}
