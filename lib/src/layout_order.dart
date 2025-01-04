import 'constraint.dart';
import 'widget.dart';

class LayoutOrder {
  const LayoutOrder();

  List<ConstrainedItem<IdType>> ofItems<IdType>(
    List<ConstrainedItem<IdType>> items,
  ) {
    final itemsInLayoutOrder = <ConstrainedItem<IdType>>[];
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

            case LinkTo(:var id):
              final targetUnresolvedEdges =
                  unresolvedEdges[itemsById[id]] ?? {};
              return targetUnresolvedEdges.isEmpty;
          }
        });

        if (edges.isEmpty) {
          itemsInLayoutOrder.add(item);
          unresolvedEdges.remove(item);
          resolvedThisRun++;
        }
      }

      if (resolvedThisRun == 0) {
        throw UnresolvedLayoutError(unresolvedEdges);
      }
    }

    return itemsInLayoutOrder;
  }
}

class UnresolvedLayoutError extends Error {
  UnresolvedLayoutError(this.unresolvedEdges);

  final Map<ConstrainedItem, Set<Edge>> unresolvedEdges;

  @override
  String toString() {
    return 'Unresolved edges $unresolvedEdges';
  }
}
