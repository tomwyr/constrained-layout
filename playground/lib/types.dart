import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

class LinkNode<IdType> {
  LinkNode({
    required this.itemId,
    required this.edge,
  });

  final IdType? itemId;
  final Edge edge;

  @override
  String toString() {
    return 'LinkNode(itemId: $itemId, edge: $edge)';
  }
}

class ItemDragData {
  ItemDragData({
    required this.origin,
    required this.delta,
  });

  final LinkNode<int> origin;
  final Offset delta;

  bool get moved => delta != Offset.zero;
}
