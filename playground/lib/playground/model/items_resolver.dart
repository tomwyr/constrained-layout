import 'package:constrained_layout/constrained_layout.dart';

import '../../types.dart';
import '../../utils/extensions.dart';
import 'drag_state.dart';
import 'hover_tracker.dart';
import 'items_actions.dart';
import 'items_history.dart';

class ItemsResolver {
  ItemsResolver({
    required this.dragState,
    required this.itemsHistory,
    required this.itemsActions,
    required this.hoverTracker,
  });

  final DragState dragState;
  final ItemsHistory itemsHistory;
  final ItemsActions itemsActions;
  final HoverTracker hoverTracker;

  LinkNode<int>? get _dragOrigin => dragState.dragData?.origin;
  LinkNode<int>? get _dragTarget => dragState.dragTarget;
  List<ConstrainedItem<int>> get _items => itemsHistory.items;

  Iterable<ConstrainedItem<int>> getActiveHandleItems() {
    if (_dragOrigin != null) {
      return _items;
    }
    return _items.where((item) => hoverTracker.isHovered(item.id));
  }

  Iterable<ConstrainedItem<int>> getActiveLinkItems({
    required bool showAllLinks,
  }) {
    return _items.where((item) {
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

  ConstrainedItem<int>? getLinkPreviewItem() {
    final (origin, target) = (_dragOrigin, _dragTarget);
    if (origin == null ||
        target == null ||
        !itemsActions.canLink(origin, target)) {
      return null;
    }

    return itemsActions.linkPreviewItem(origin, target);
  }
}
