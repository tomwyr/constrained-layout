import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/widgets.dart';

class ItemsFactory {
  static const _child = SizedBox.shrink();

  final _previewItemId = -1;
  var _itemIdCounter = 0;

  ConstrainedItem<int> createEmptyPreviewItem() {
    return ConstrainedItem(
      id: _previewItemId,
      child: _child,
    );
  }

  ConstrainedItem<int> createEmptyItem({bool linkToParent = false}) {
    final constraint = linkToParent ? LinkToParent() : null;
    return ConstrainedItem.all(
      id: _itemIdCounter++,
      constraint: constraint,
      child: _child,
    );
  }
}
