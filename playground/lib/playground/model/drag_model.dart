import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

import '../../types.dart';
import 'hover_tracker.dart';
import 'items_model.dart';

const previewIxtemId = -1;

class DragModel extends ChangeNotifier {
  DragModel({
    required this.itemsModel,
    required this.hoverTracker,
  });

  final ItemsModel itemsModel;
  final HoverTracker hoverTracker;

  ItemDragData? _dragData;
  ItemDragData? get dragData => _dragData;

  LinkNode<int>? _dragTarget;
  LinkNode<int>? get dragTarget => _dragTarget;

  void setDragTarget(LinkNode<int>? target) {
    final origin = _dragData?.origin;
    if (target != null &&
        origin != null &&
        !itemsModel.canLink(origin, target)) {
      return;
    }

    _dragTarget = target;
    notifyListeners();
  }

  void startDrag(ConstrainedItem<int> item, Edge edge) {
    _dragData = ItemDragData(
      origin: LinkNode(itemId: item.id, edge: edge),
      delta: Offset.zero,
    );
    notifyListeners();
  }

  void updateDrag(ConstrainedItem<int> item, Edge edge, Offset delta) {
    _dragData = ItemDragData(
      origin: LinkNode(itemId: item.id, edge: edge),
      delta: _dragData!.delta + delta,
    );
    notifyListeners();
  }

  void endDrag() {
    _dragData = null;
    notifyListeners();
  }
}
