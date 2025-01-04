import 'package:flutter/widgets.dart';

import 'constraint.dart';
import 'layout_order.dart';
import 'widget.dart';

class ConstrainedLayoutDelegate extends MultiChildLayoutDelegate {
  ConstrainedLayoutDelegate({
    super.relayout,
    required this.items,
    this.layoutOrder = const LayoutOrder(),
  }) {
    validateItems();
  }

  final List<ConstrainedItem> items;
  final LayoutOrder layoutOrder;

  @override
  void performLayout(Size size) {
    final parentSize = size;

    final sizesById = <Object, Size>{};
    final offsetsById = <Object, Offset>{};
    layoutById(Object id) => (
          size: sizesById[id] ?? (throw InvalidSizeAccessError(id)),
          offset: offsetsById[id] ?? (throw InvalidOffsetAccessError(id)),
        );

    final itemsInLayoutOrder = layoutOrder.ofItems(items);

    for (var item in itemsInLayoutOrder) {
      final itemSize = layoutChild(item.id, BoxConstraints.loose(parentSize));
      sizesById[item.id] = itemSize;
    }

    for (var item in itemsInLayoutOrder) {
      final itemSize = sizesById[item.id]!;

      double calcPosX() {
        const axis = Axis.horizontal;

        switch ((item.left, item.right)) {
          case (null, null):
            return 0;

          case (null, LinkToParent()):
            return parentSize.width - itemSize.width;

          case (null, LinkTo(:var id, :var edge)):
            final target = layoutById(id);
            return switch (edge) {
              Edge.left => target.offset.dx - itemSize.width,
              Edge.right =>
                target.offset.dx + target.size.width - itemSize.width,
              Edge.top || Edge.bottom => throw InvalidLinkAxisError(axis, edge),
            };

          case (LinkToParent(), null):
            return 0;

          case (LinkToParent(), LinkToParent()):
            return (parentSize.width - itemSize.width) / 2;

          case (LinkToParent(), LinkTo(:var id, :var edge)):
            final target = layoutById(id);
            return switch (edge) {
              Edge.left => (target.offset.dx - itemSize.width) / 2,
              Edge.right =>
                (target.offset.dx + target.size.width - itemSize.width) / 2,
              Edge.top || Edge.bottom => throw InvalidLinkAxisError(axis, edge),
            };

          case (LinkTo(:var id, :var edge), null):
            final target = layoutById(id);
            return switch (edge) {
              Edge.left => target.offset.dx,
              Edge.right => target.offset.dx + target.size.width,
              Edge.top || Edge.bottom => throw InvalidLinkAxisError(axis, edge),
            };

          case (LinkTo(:var id, :var edge), LinkToParent()):
            final target = layoutById(id);
            return switch (edge) {
              Edge.left => target.offset.dx +
                  (parentSize.width -
                          target.offset.dx -
                          target.size.width -
                          itemSize.width) /
                      2,
              Edge.right => target.offset.dx +
                  target.size.width +
                  (parentSize.width -
                          target.offset.dx -
                          target.size.width -
                          itemSize.width) /
                      2,
              Edge.top || Edge.bottom => throw InvalidLinkAxisError(axis, edge),
            };

          case (
              LinkTo(id: var id1, edge: var edge1),
              LinkTo(id: var id2, edge: var edge2),
            ):
            final target1 = layoutById(id1);
            final topY = switch (edge1) {
              Edge.left => target1.offset.dx,
              Edge.right => target1.offset.dx + target1.size.width,
              Edge.top ||
              Edge.bottom =>
                throw InvalidLinkAxisError(axis, edge1),
            };
            final target2 = layoutById(id2);
            final bottomY = switch (edge2) {
              Edge.left => target2.offset.dx,
              Edge.right => target2.offset.dx + target2.size.width,
              Edge.top ||
              Edge.bottom =>
                throw InvalidLinkAxisError(axis, edge2),
            };
            return topY + (bottomY - topY - itemSize.width) / 2;
        }
      }

      double calcPosY() {
        const axis = Axis.vertical;

        switch ((item.top, item.bottom)) {
          case (null, null):
            return 0;

          case (null, LinkToParent()):
            return parentSize.height - itemSize.height;

          case (null, LinkTo(:var id, :var edge)):
            final target = layoutById(id);
            return switch (edge) {
              Edge.top => target.offset.dy - itemSize.height,
              Edge.bottom =>
                target.offset.dy + target.size.height - itemSize.height,
              Edge.left || Edge.right => throw InvalidLinkAxisError(axis, edge),
            };

          case (LinkToParent(), null):
            return 0;

          case (LinkToParent(), LinkToParent()):
            return (parentSize.height - itemSize.height) / 2;

          case (LinkToParent(), LinkTo(:var id, :var edge)):
            final target = layoutById(id);
            return switch (edge) {
              Edge.top => (target.offset.dy - itemSize.height) / 2,
              Edge.bottom =>
                (target.offset.dy + target.size.height - itemSize.height) / 2,
              Edge.left || Edge.right => throw InvalidLinkAxisError(axis, edge),
            };

          case (LinkTo(:var id, :var edge), null):
            final target = layoutById(id);
            return switch (edge) {
              Edge.top => target.offset.dy,
              Edge.bottom => target.offset.dy + target.size.height,
              Edge.left || Edge.right => throw InvalidLinkAxisError(axis, edge),
            };

          case (LinkTo(:var id, :var edge), LinkToParent()):
            final target = layoutById(id);
            return switch (edge) {
              Edge.top => target.offset.dy +
                  (parentSize.height - target.offset.dy - itemSize.height) / 2,
              Edge.bottom => target.offset.dy +
                  target.size.height +
                  (parentSize.height -
                          target.offset.dy -
                          target.size.height -
                          itemSize.height) /
                      2,
              Edge.left || Edge.right => throw InvalidLinkAxisError(axis, edge),
            };

          case (
              LinkTo(id: var id1, edge: var edge1),
              LinkTo(id: var id2, edge: var edge2),
            ):
            final target1 = layoutById(id1);
            final topY = switch (edge1) {
              Edge.top => target1.offset.dy,
              Edge.bottom => target1.offset.dy + target1.size.height,
              Edge.left ||
              Edge.right =>
                throw InvalidLinkAxisError(axis, edge1),
            };
            final target2 = layoutById(id2);
            final bottomY = switch (edge2) {
              Edge.top => target2.offset.dy,
              Edge.bottom => target2.offset.dy + target2.size.height,
              Edge.left ||
              Edge.right =>
                throw InvalidLinkAxisError(axis, edge2),
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
        throw ItemDuplicateError(item);
      }
    }
  }
}

class ItemDuplicateError extends Error {
  ItemDuplicateError(this.item);

  final ConstrainedItem item;

  @override
  String toString() {
    return 'Id ${item.id} is already used by another item';
  }
}

class InvalidLinkAxisError extends Error {
  final Axis axis;
  final Edge edge;

  InvalidLinkAxisError(this.axis, this.edge);

  @override
  String toString() {
    final expectedAxis = switch (axis) {
      Axis.horizontal => 'Horizontal',
      Axis.vertical => 'Verticla',
    };
    final oppositeAxis = switch (axis) {
      Axis.horizontal => 'vertical',
      Axis.vertical => 'horizontal',
    };

    return '$expectedAxis constraint linked to $oppositeAxis edge $edge';
  }
}

class InvalidSizeAccessError extends Error {
  InvalidSizeAccessError(this.itemId);

  final Object itemId;

  @override
  String toString() {
    return 'Attempted to access the size of item "$itemId" before it was laid out';
  }
}

class InvalidOffsetAccessError extends Error {
  InvalidOffsetAccessError(this.itemId);

  final Object itemId;

  @override
  String toString() {
    return 'Attempted to access the offset of item "$itemId" before it was laid out';
  }
}
