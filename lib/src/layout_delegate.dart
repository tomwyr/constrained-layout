import 'package:flutter/widgets.dart';

import '../constrained_layout.dart';
import 'layout_order.dart';

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

    final itemsInLayoutOrder = layoutOrder.ofItems(items);

    for (var item in itemsInLayoutOrder) {
      final key = item.child.key!;
      final itemSize = layoutChild(item.child, BoxConstraints.loose(parentSize));
      sizesByKey[key] = itemSize;
    }

    for (var item in itemsInLayoutOrder) {
      final itemKey = item.child.key!;

      double calcPosX() {
        return 0.0;
      }

      double calcPosY() {
        return 0.0;
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
