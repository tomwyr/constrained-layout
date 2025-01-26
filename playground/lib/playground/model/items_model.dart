import 'package:constrained_layout/constrained_layout.dart';

import '../../types.dart';
import 'items_history.dart';

class ItemsModel {
  ItemsModel({required this.itemsHistory});

  final ItemsHistory itemsHistory;

  final previewItemId = -1;
  var _itemIdCounter = 0;

  List<ConstrainedItem<int>> get items => itemsHistory.activeItmes;

  int getNextItemId() {
    return _itemIdCounter++;
  }

  ConstrainedItem<int> findItem(LinkNode<int> node) {
    return items.firstWhere((item) => item.id == node.itemId);
  }

  void linkItemAndReplace(LinkNode<int> origin, LinkNode<int> target) {
    if (!canLink(origin, target)) {
      return;
    }
    itemsHistory.replaceItem(linkItem(origin, target));
  }

  bool canLink(LinkNode<int>? origin, LinkNode<int> target) {
    if (origin == null) {
      return true;
    } else if (origin.itemId == target.itemId) {
      return origin.edge == target.edge;
    } else if (origin.edge.axis != target.edge.axis) {
      return false;
    }

    return const LayoutOrder().canResolve([
      for (var item in items)
        item.id == origin.itemId ? linkItem(origin, target) : item
    ]);
  }

  ConstrainedItem<int> linkItem(LinkNode<int> origin, LinkNode<int> target) {
    final constraint = switch (target) {
      LinkNode(:var itemId?, :var edge) => LinkTo(id: itemId, edge: edge),
      LinkNode(itemId: null) => LinkToParent(),
    };

    return findItem(origin).constrainedAlong(constraint, origin.edge);
  }
}
