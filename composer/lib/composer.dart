import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'draggable_item.dart';
import 'extensions/map.dart';
import 'link_path.dart';
import 'utils/widget_code.dart';

class Composer extends StatefulWidget {
  const Composer({super.key});

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  final layoutKey = GlobalKey();
  final handleKeys = <int?, GlobalKey>{};

  var itemIdCounter = 0;
  var items = <ConstrainedItem<int>>[];
  var itemLinks = <Widget>[];
  var showCode = true;

  ComposerDragData? dragData;

  bool get dragging => dragData != null;

  GlobalKey handleKeyFor(int itemId) {
    return handleKeys.putIfAbsent(itemId, () => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        layoutActions(),
        const SizedBox(height: 4),
        Expanded(
          child: layoutBody(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget layoutBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: ColoredBox(
            color: Colors.grey[200]!,
            child: layoutBuilder(),
          ),
        ),
        if (showCode) ...[
          const SizedBox(width: 12),
          Expanded(
            child: ColoredBox(
              color: Colors.grey[200]!,
              child: layoutCode(),
            ),
          ),
        ],
        const SizedBox(width: 12),
      ],
    );
  }

  Widget layoutActions() {
    return Row(
      children: [
        addItemButton(),
        clearItemsButton(),
        toggleCodeButton(),
      ],
    );
  }

  Widget layoutBuilder() {
    return Stack(
      children: [
        ...itemLinks,
        if (dragging) ...[
          dragLink(),
          parentHandles(),
        ],
        ConstrainedLayout(
          key: layoutKey,
          items: items,
        ),
      ],
    );
  }

  Widget layoutCode() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SelectableText(
        ConstrainedLayout(items: items).widgetCode,
      ),
    );
  }

  Widget dragLink() {
    final LinkNode(:itemId, :edge) = dragData!.origin;
    final from = positionOfEdge(itemId, edge);
    final to = from + dragData!.delta;
    return LinkPath(active: true, from: from, to: to);
  }

  Widget itemLink(int itemId, Edge edge, Constraint constraint) {
    final from = positionOfEdge(itemId, edge);
    final to = switch (constraint) {
      LinkToParent() => positionOfEdge(null, edge),
      LinkTo(:var id, :var edge) => positionOfEdge(id, edge),
    };
    return LinkPath(active: false, from: from, to: to);
  }

  Offset positionOfEdge(int? itemId, Edge edge) {
    final edgeLayoutKey = itemId != null ? handleKeyFor(itemId) : layoutKey;
    return edgeLayoutKey.centerOfEdge(edge) - layoutKey.origin;
  }

  RenderBox constrainedLayoutBox() {
    final layoutBox = layoutKey.currentContext?.findRenderObject();
    if (layoutBox is! RenderBox) {
      throw 'Unable to access layout position';
    }
    return layoutBox;
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
        edge: edge,
        onLink: (node) => linkItem(null, edge, node),
      ),
    );
  }

  Widget addItemButton() {
    return ComposerActionButton(
      icon: Icons.add,
      onClick: addNewItem,
    );
  }

  Widget clearItemsButton() {
    return ComposerActionButton(
      icon: Icons.delete,
      onClick: () {
        setItems([]);
      },
    );
  }

  Widget toggleCodeButton() {
    return ComposerActionButton(
      icon: Icons.code,
      onClick: () {
        setState(() {
          showCode = !showCode;
        });
      },
    );
  }

  void addNewItem() {
    final itemId = itemIdCounter++;

    final child = DraggableItem(
      key: handleKeyFor(itemId),
      itemId: itemId,
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

    setItems([...items, item]);
  }

  void removeItem(ConstrainedItem item) {
    setItems([
      for (var nextItem in items)
        if (nextItem.id != item.id) nextItem,
    ]);
  }

  void replaceItem(ConstrainedItem<int> item) {
    setItems([
      for (var nextItem in items)
        if (nextItem.id != item.id) nextItem else item,
    ]);
  }

  void setItems(List<ConstrainedItem<int>> items) {
    setState(() {
      this.items = items;
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final itemLinks = [
        for (var item in items)
          for (var (edge, constraint) in item.constraints.records)
            if (constraint != null) itemLink(item.id, edge, constraint),
      ];

      setState(() {
        this.itemLinks = itemLinks;
      });
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
    required this.icon,
    required this.onClick,
  });

  final IconData icon;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: FloatingActionButton.small(
        onPressed: onClick,
        child: Icon(icon),
      ),
    );
  }
}

typedef ComposerDragData = ({LinkNode<int> origin, Offset delta});

extension on GlobalKey {
  Offset get origin {
    return requireRenderBox().localToGlobal(Offset.zero);
  }

  Offset centerOfEdge(Edge edge) {
    final box = requireRenderBox();
    final Size(:width, :height) = box.size;
    final localCenter = switch (edge) {
      Edge.top => Offset(width / 2, 0),
      Edge.bottom => Offset(width / 2, height),
      Edge.left => Offset(0, height / 2),
      Edge.right => Offset(width, height / 2),
    };
    return box.localToGlobal(localCenter);
  }

  RenderBox requireRenderBox() {
    final box = currentContext?.findRenderObject();
    if (box is! RenderBox) {
      throw 'Unable to access widget\'s render object';
    }
    return box;
  }
}
