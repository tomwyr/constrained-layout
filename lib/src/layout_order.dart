import 'constraint.dart';
import 'widget.dart';

class ConstrainedLayoutOrder {
  const ConstrainedLayoutOrder();

  List<ConstrainedItem> ofItems(List<ConstrainedItem> items) {
    final itemsInLayoutOrder = <ConstrainedItem>[];
    final itemsById = {
      for (var item in items) item.id: item,
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
          switch (item.constraintAlong(edge)) {
            case null || LinkToParent():
              return true;

            case LinkTo(:var id, :var edge):
              final targetUnresolvedEdges =
                  unresolvedEdges[itemsById[id]] ?? {};
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
