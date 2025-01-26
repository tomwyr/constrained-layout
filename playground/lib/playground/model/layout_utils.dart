import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

import '../../utils/extensions.dart';

class LayoutUtils {
  final _itemKeys = <int?, GlobalKey>{};

  final _layoutKey = GlobalKey();
  Key get layoutKey => _layoutKey;

  GlobalKey getItemKey(int itemId) {
    return _itemKeys.putIfAbsent(itemId, () => GlobalKey());
  }

  Offset positionOfEdge(int? itemId, Edge edge) {
    final edgeLayoutKey = itemId != null ? getItemKey(itemId) : _layoutKey;
    return edgeLayoutKey.centerOfEdge(edge) - _layoutKey.origin;
  }

  bool isItemRendered(int itemId) {
    final context = getItemKey(itemId).currentContext;
    try {
      final box = context?.findRenderObject();
      return box is RenderBox && box.hasSize;
    } catch (_) {
      return false;
    }
  }
}
