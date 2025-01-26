import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

import '../../types.dart';
import '../../utils/extensions.dart';
import 'drag_model.dart';
import 'hover_tracker.dart';
import 'items_model.dart';

class ItemResolver {
  ItemResolver({
    required this.dragModel,
    required this.itemsModel,
    required this.hoverTracker,
  });

  final DragModel dragModel;
  final ItemsModel itemsModel;
  final HoverTracker hoverTracker;

  LinkNode<int>? get _dragOrigin => dragModel.dragData?.origin;
  LinkNode<int>? get _dragTarget => dragModel.dragTarget;

  Iterable<ConstrainedItem<int>> getActiveHandleItems() {
    if (_dragOrigin != null) {
      return itemsModel.items;
    }
    return itemsModel.items.where((item) => hoverTracker.isHovered(item.id));
  }

  Iterable<ConstrainedItem<int>> getActiveLinkItems({
    required bool showAllLinks,
  }) {
    return itemsModel.items.where((item) {
      if (_dragTarget != null && _dragOrigin!.itemId == item.id) {
        return false;
      }

      return showAllLinks ||
          _dragOrigin?.itemId == item.id ||
          hoverTracker.isHovered(item.id);
    }).sortedBy((item1, item2) {
      return hoverTracker.isHovered(item1.id) ? 1 : -1;
    });
  }

  (LinkNode<int> origin, LinkNode<int> target)? getLinkPreviewData() {
    final (origin, target) = (_dragOrigin, _dragTarget);
    if (origin != null &&
        target != null &&
        itemsModel.canLink(origin, target)) {
      return (origin, target);
    }
    return null;
  }

  ConstrainedItem<int> getLinkPreviewItem(
    LinkNode<int> origin,
    LinkNode<int> target,
  ) {
    final constraint = switch (target.itemId) {
      null => LinkToParent(),
      var targetId => LinkTo(id: targetId, edge: target.edge),
    };

    final originItem = itemsModel.findItem(origin);
    final item = ConstrainedItem(
      id: itemsModel.previewItemId,
      child: Container(),
    );

    return item
        .withConstraintsOf(originItem)
        .constrainedAlong(constraint, origin.edge);
  }
}
