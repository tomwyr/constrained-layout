import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/foundation.dart';

class HoverTracker extends ChangeNotifier {
  final Map<int, Set<Edge>> _edges = {};
  final Set<int> _items = {};

  var _hoveredItems = <int>[];
  List<int> get hoveredItems => _hoveredItems;

  void setItemHovered(int itemId, bool hovered) {
    final itemsChanged = hovered ? _items.add(itemId) : _items.remove(itemId);
    if (itemsChanged) {
      _hoveredItems = _items.toList();
      notifyListeners();
    }
  }

  void setEdgeHovered(int itemId, Edge edge, bool hovered) {
    hovered ? _edgesOf(itemId).add(edge) : _edgesOf(itemId).remove(edge);
    notifyListeners();
  }

  bool isHovered(int itemId) {
    return _items.contains(itemId) || _edgesOf(itemId).isNotEmpty;
  }

  Set<Edge> _edgesOf(int itemId) {
    return _edges.putIfAbsent(itemId, () => {});
  }
}
