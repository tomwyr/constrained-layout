import 'package:constrained_layout/constrained_layout.dart';

import '../../types.dart';
import 'items_factory.dart';
import 'items_history.dart';

class ItemsActions {
  ItemsActions({
    required this.itemsHistory,
    required this.itemsFactory,
  });

  final ItemsHistory itemsHistory;
  final ItemsFactory itemsFactory;

  List<ConstrainedItem<int>> get _items => itemsHistory.items;

  void addEmptyItem({bool linkToParent = false}) {
    final item = itemsFactory.createEmptyItem(linkToParent: linkToParent);
    itemsHistory.addItem(item);
  }

  void linkItemAndReplace(LinkNode<int> origin, LinkNode<int> target) {
    final item = linkItem(origin, target);
    itemsHistory.replaceItem(item);
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
      for (var item in _items)
        item.id == origin.itemId ? linkItem(origin, target) : item
    ]);
  }

  ConstrainedItem<int> linkItem(LinkNode<int> origin, LinkNode<int> target) {
    final item = _findItem(origin);
    final constraint = _getConstraintTo(target);
    return item.constrainedAlong(constraint, origin.edge);
  }

  ConstrainedItem<int> linkPreviewItem(
    LinkNode<int> origin,
    LinkNode<int> target,
  ) {
    final item = itemsFactory
        .createEmptyPreviewItem()
        .withConstraintsOf(_findItem(origin));
    final constraint = _getConstraintTo(target);
    return item.constrainedAlong(constraint, origin.edge);
  }

  ConstrainedItem<int> _findItem(LinkNode<int> node) {
    return _items.firstWhere((item) => item.id == node.itemId);
  }

  Constraint _getConstraintTo(LinkNode<int> target) {
    return switch (target) {
      LinkNode(:var itemId?, :var edge) => LinkTo(id: itemId, edge: edge),
      LinkNode(itemId: null) => LinkToParent(),
    };
  }
}
