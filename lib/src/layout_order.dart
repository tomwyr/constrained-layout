import 'constraint.dart';
import 'widget.dart';

class ConstrainedLayoutOrder {
  const ConstrainedLayoutOrder();

  List<ConstrainedItem> ofItems(List<ConstrainedItem> items) {
    final itemsInLayoutOrder = <ConstrainedItem>[];
    final itemsByKey = {
      for (var item in items) item.child.key: item,
    };
    final unresolvedEdges = {
      for (var item in items) item: {...Edge.values},
    };

    while (unresolvedEdges.isNotEmpty) {
      var resolvedThisRun = 0;
      final unresolvedItems = unresolvedEdges.keys.toList();

      for (var item in unresolvedItems) {
        final edges = unresolvedEdges[item] ?? {};

        edges.removeWhere((edge) {
          switch (item.constraintAt(edge)) {
            case null || AttachToParent():
              return true;

            case AttachTo(:var key, :var edge):
              final targetUnresolvedEdges = unresolvedEdges[itemsByKey[key]] ?? {};
              return !targetUnresolvedEdges.contains(edge);
          }
        });

        if (edges.isEmpty) {
          itemsInLayoutOrder.add(item);
          unresolvedEdges.remove(item);
          resolvedThisRun++;
        }
      }

      if (resolvedThisRun == 0) {
        throw 'Unresolved edges $unresolvedEdges';
      }
    }

    return itemsInLayoutOrder;
  }
}
