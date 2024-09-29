import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

import 'draggable_item.dart';
import 'item_list.dart';
import 'link_path.dart';

class Composer extends StatefulWidget {
  const Composer({super.key});

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  final layoutKey = GlobalKey();
  final handleKeys = <String, GlobalKey>{};

  var itemListExpanded = false;
  var itemIdCounter = 0;
  var items = <ConstrainedItem<int>>[];

  ComposerDragData? dragData;

  bool get dragging => dragData != null;

  GlobalKey handleKeyFor(int? itemId, Edge edge) {
    final id = '$itemId ${edge.name}';
    return handleKeys.putIfAbsent(id, () => GlobalKey(debugLabel: id));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            toggleListButton(),
            addItemButton(),
          ],
        ),
        Expanded(
          child: Stack(
            children: [
              ConstrainedLayout(
                key: layoutKey,
                items: items,
              ),
              if (dragging) ...[
                targetPath(),
                parentHandles(),
              ],
              if (itemListExpanded) itemList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget targetPath() {
    final handleBox = dragHandleBox();
    final layoutBox = constrainedLayoutBox();
    final handleCenter = Offset(handleBox.size.width / 2, handleBox.size.height / 2);

    final from = handleBox.localToGlobal(handleCenter) - layoutBox.localToGlobal(Offset.zero);
    final to = from + dragData!.delta;

    return LinkPath(active: true, from: from, to: to);
  }

  RenderBox constrainedLayoutBox() {
    final layoutBox = layoutKey.currentContext?.findRenderObject();
    if (layoutBox is! RenderBox) {
      throw 'Unable to access layout position';
    }
    return layoutBox;
  }

  RenderBox dragHandleBox() {
    final LinkNode(:itemId, :edge) = dragData!.origin;
    final handleBox = handleKeyFor(itemId, edge).currentContext?.findRenderObject();
    if (handleBox is! RenderBox) {
      throw 'Unable to access item\'s handle position';
    }
    return handleBox;
  }

  Widget parentHandles() {
    return Positioned.fill(
      child: Stack(
        children: [
          parentHandle(Edge.top),
          parentHandle(Edge.bottom),
          parentHandle(Edge.left),
          parentHandle(Edge.right),
        ],
      ),
    );
  }

  Widget parentHandle(Edge edge) {
    return Align(
      alignment: edge.toAlignment(),
      child: ParentItemTarget<int>(
        handleKey: handleKeyFor(null, edge),
        edge: edge,
        onLink: (node) => linkItem(null, edge, node),
      ),
    );
  }

  Widget itemList() {
    return Positioned(
      left: 8,
      top: 0,
      child: ItemList(
        items: items,
        onRemove: removeItem,
      ),
    );
  }

  Widget toggleListButton() {
    return ComposerActionButton(
      alignment: Alignment.topRight,
      icon: Icons.list,
      onClick: () {
        setState(() {
          itemListExpanded = !itemListExpanded;
        });
      },
    );
  }

  Widget addItemButton() {
    return ComposerActionButton(
      alignment: Alignment.bottomRight,
      icon: Icons.add,
      onClick: addNewItem,
    );
  }

  void addNewItem() {
    final itemId = itemIdCounter++;

    final child = DraggableItem(
      itemId: itemId,
      handleKeyBuilder: handleKeyFor,
      onLink: (edge, node) => linkItem(itemId, edge, node),
      onDragStart: (edge) {
        setState(() {
          dragData = (
            origin: LinkNode(itemId: itemId, edge: edge),
            delta: Offset.zero,
          );
        });
      },
      onDragUpdate: (edge, delta) {
        setState(() {
          dragData = (
            origin: LinkNode(itemId: itemId, edge: edge),
            delta: dragData!.delta + delta,
          );
        });
      },
      onDragEnd: (edge) {
        setState(() {
          dragData = null;
        });
      },
    );

    final item = ConstrainedItem(id: itemId, child: child);

    setState(() {
      items = [...items, item];
    });
  }

  void removeItem(ConstrainedItem item) {
    setState(() {
      items = [
        for (var nextItem in items)
          if (nextItem.id != item.id) nextItem,
      ];
    });
  }

  void replaceItem(ConstrainedItem<int> item) {
    setState(() {
      items = [
        for (var nextItem in items)
          if (nextItem.id != item.id) nextItem else item,
      ];
    });
  }

  void linkItem(int? itemId, Edge edge, LinkNode<int> node) {
    final constraint = itemId != null ? LinkTo(id: itemId, edge: edge) : LinkToParent();
    final updatedItem =
        items.firstWhere((item) => item.id == node.itemId).constrainedAlong(constraint, node.edge);
    replaceItem(updatedItem);
  }
}

class ComposerActionButton extends StatelessWidget {
  const ComposerActionButton({
    super.key,
    required this.alignment,
    required this.icon,
    required this.onClick,
  });

  final Alignment alignment;
  final IconData icon;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FloatingActionButton.small(
          onPressed: onClick,
          child: Icon(icon),
        ),
      ),
    );
  }
}

typedef ComposerDragData = ({LinkNode origin, Offset delta});
