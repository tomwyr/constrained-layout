import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/foundation.dart';

class ItemsHistory extends ChangeNotifier {
  final List<List<ConstrainedItem<int>>> _items = [[]];

  var _activeIndex = 0;

  List<ConstrainedItem<int>> get activeItmes => _items[_activeIndex];

  bool get canUndo => _activeIndex > 0;
  bool get canRedo => _activeIndex < _items.length - 1;

  void addItem(ConstrainedItem<int> item) {
    _trimItemsToActive();
    _items.add([
      if (_items.isNotEmpty) ..._items.last,
      item,
    ]);
    _activeIndex++;
    notifyListeners();
  }

  void replaceItem(ConstrainedItem<int> item) {
    _trimItemsToActive();
    _items.add([
      for (var nextItem in _items.last)
        if (nextItem.id != item.id) nextItem else item,
    ]);
    _activeIndex++;
    notifyListeners();
  }

  void removeItem(int itemId) {
    _trimItemsToActive();
    _items.add([
      for (var item in _items.last)
        if (item.id != itemId) item,
    ]);
    _activeIndex++;
    notifyListeners();
  }

  void clearItems() {
    _trimItemsToActive();
    _items.add([]);
    _activeIndex++;
    notifyListeners();
  }

  void undo() {
    if (_activeIndex > 0) {
      _activeIndex--;
    }
    notifyListeners();
  }

  void redo() {
    if (_activeIndex < _items.length - 1) {
      _activeIndex++;
    }
    notifyListeners();
  }

  void _trimItemsToActive() {
    if (_activeIndex > 0 && _activeIndex < _items.length - 1) {
      _items.removeRange(_activeIndex + 1, _items.length);
    }
  }
}
