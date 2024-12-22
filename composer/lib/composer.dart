import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'draggable_item.dart';
import 'link_path.dart';
import 'utils/extensions.dart';
import 'utils/functions.dart';
import 'utils/widget_code.dart';
import 'widgets/animation_builder.dart';
import 'widgets/hover_region.dart';

class Composer extends StatefulWidget {
  const Composer({super.key});

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  static const _previewItemId = -1;

  final layoutKey = GlobalKey();
  final handleKeys = <int?, GlobalKey>{};

  var itemIdCounter = 0;
  var items = <ConstrainedItem<int>>[];
  var hoverTracker = HoverTracker();
  var itemLinks = <Widget>[];
  var itemHandles = <Widget>[];
  var showAllLinks = true;
  var showCode = true;

  BoxConstraints? lastConstraints;
  ComposerDragData? dragData;
  LinkNode<int>? dragTarget;

  GlobalKey handleKeyFor(int itemId) {
    return handleKeys.putIfAbsent(itemId, () => GlobalKey());
  }

  @override
  void initState() {
    super.initState();
    addNewItem(linkToParent: true);
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
          flex: 2,
          child: ColoredBox(
            color: Colors.grey[200]!,
            child: layoutBuilder(),
          ),
        ),
        if (showCode) ...[
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
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
        toggleLinksButton(),
        toggleCodeButton(),
      ],
    );
  }

  Widget layoutBuilder() {
    return LayoutBuilder(
      builder: (context, constraints) {
        syncLayout(constraints);

        return Stack(
          children: [
            ...itemLinks,
            if (dragData case ComposerDragData(:var moved)) ...[
              if (moved) dragLink(),
              parentHandles(),
            ],
            constrainedLayout(),
            ...itemHandles,
          ],
        );
      },
    );
  }

  Widget constrainedLayout() {
    return ConstrainedLayout(
      key: layoutKey,
      items: [
        ...items.map(itemWithChild),
        if (linkPreviewData() case (var start, var end))
          linkPreviewItem(start, end),
      ],
    );
  }

  ConstrainedItem<int> itemWithChild(ConstrainedItem<int> item) {
    final previewed = dragData?.origin.itemId == item.id && dragTarget != null;
    final child = HoverRegion.listener(
      key: handleKeyFor(item.id),
      onChange: (hovered) {
        hoverTracker.setItemHovered(item.id, hovered);
        syncItemOverlays();
      },
      child: ItemSquare(
        item: item,
        opacity: previewed ? 0.5 : 1,
      ),
    );

    return item.swapChild(child);
  }

  (LinkNode<int> origin, LinkNode<int> target)? linkPreviewData() {
    final (origin, target) = (dragData?.origin, dragTarget);
    if (origin != null && target != null && origin.canLinkTo(target)) {
      return (origin, target);
    }
    return null;
  }

  ConstrainedItem<int> linkPreviewItem(
    LinkNode<int> origin,
    LinkNode<int> target,
  ) {
    final constraint = switch (target.itemId) {
      null => LinkToParent(),
      var targetId => LinkTo(id: targetId, edge: target.edge),
    };

    final originItem = findItem(origin);
    final item = ConstrainedItem(
      id: _previewItemId,
      child: ItemSquare(
        item: originItem,
      ),
    );

    return item
        .withConstraintsOf(originItem)
        .constrainedAlong(constraint, origin.edge);
  }

  Widget layoutCode() {
    final widgetCode = ConstrainedLayout(items: items).widgetCode;

    return HoverRegion(
      builder: (hovered) => Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: SelectableText(widgetCode),
          ),
          if (hovered)
            Positioned(
              top: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: copyCodeButton(widgetCode),
              ),
            ),
        ],
      ),
    );
  }

  Widget copyCodeButton(String widgetCode) {
    return Tooltip(
      message: 'Copy',
      preferBelow: false,
      child: HoverRegion(
        builder: (hovered) => IconButton(
          icon: const Icon(Icons.copy),
          color: !hovered ? Colors.grey : null,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: widgetCode));
          },
        ),
      ),
    );
  }

  Widget dragLink() {
    final LinkNode(:itemId, :edge) = dragData!.origin;
    final fromOffset = positionOfEdge(itemId, edge);
    final toOffset = switch (dragTarget) {
      LinkNode(:var itemId, :var edge) => positionOfEdge(itemId, edge),
      null => fromOffset + dragData!.delta,
    };
    final toParent = switch (dragTarget) {
      LinkNode(itemId: null) => true,
      _ => false,
    };

    return AnimationBuilder(
      active: dragTarget != null,
      duration: const Duration(seconds: 1),
      listenableBuilder: (listenable) => LinkPath(
        animation: listenable,
        type: LinkPathStyle.bold,
        fromOffset: fromOffset,
        toOffset: toOffset,
        fromEdge: edge,
        toEdge: dragTarget?.edge,
        toParent: toParent,
      ),
    );
  }

  Widget itemLink(int itemId, Edge edge, Constraint constraint) {
    final fromOffset = positionOfEdge(itemId, edge);
    final toOffset = switch (constraint) {
      LinkToParent() => positionOfEdge(null, edge),
      LinkTo(:var id, :var edge) => positionOfEdge(id, edge),
    };
    final toEdge = switch (constraint) {
      LinkToParent() => edge,
      LinkTo(:var edge) => edge,
    };
    final toParent = switch (constraint) {
      LinkToParent() => true,
      LinkTo() => false,
    };

    final active = dragData == null && hoverTracker.isHovered(itemId);

    return AnimationBuilder(
      active: active,
      duration: const Duration(seconds: 1),
      listenableBuilder: (listenable) => LinkPath(
        animation: listenable,
        type: active ? LinkPathStyle.normal : LinkPathStyle.light,
        fromOffset: fromOffset,
        toOffset: toOffset,
        fromEdge: edge,
        toEdge: toEdge,
        toParent: toParent,
      ),
    );
  }

  Widget itemHandle(ConstrainedItem<int> item, Edge edge) {
    final position = positionOfEdge(item.id, edge);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: DraggableItemHandle(
        edge: edge,
        itemId: item.id,
        draggedNode: dragData?.origin,
        onLinkCandidate: (edge) {
          setDragTarget(LinkNode(itemId: item.id, edge: edge));
        },
        onLinkCancel: () {
          setDragTarget(null);
        },
        onLinkConfirm: (edge, node) {
          final linkTarget = LinkNode(itemId: item.id, edge: edge);
          setDragTarget(null);
          linkItem(node, linkTarget);
        },
        onDragStart: (edge) {
          setState(() {
            dragData = ComposerDragData(
              origin: LinkNode(itemId: item.id, edge: edge),
              delta: Offset.zero,
            );
          });
          syncItemOverlays();
        },
        onDragUpdate: (edge, delta) {
          setState(() {
            dragData = ComposerDragData(
              origin: LinkNode(itemId: item.id, edge: edge),
              delta: dragData!.delta + delta,
            );
          });
        },
        onDragEnd: (edge) {
          setState(() {
            dragData = null;
          });
          syncItemOverlays();
        },
        onUnlink: (edge) {
          final updatedItem = item.constrainedAlong(null, edge);
          replaceItem(updatedItem);
        },
        onHover: (hovered) {
          hoverTracker.setEdgeHovered(item.id, edge, hovered);
          syncItemOverlays();
        },
      ),
    );
  }

  Offset positionOfEdge(int? itemId, Edge edge) {
    final edgeLayoutKey = itemId != null ? handleKeyFor(itemId) : layoutKey;
    return edgeLayoutKey.centerOfEdge(edge) - layoutKey.origin;
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
    final linkTarget = LinkNode<int>(itemId: null, edge: edge);

    return ParentItemTarget<int>(
      edge: edge,
      draggedEdge: dragData?.origin.edge,
      onLinkCandidate: () {
        setDragTarget(linkTarget);
      },
      onLinkCancel: () {
        setDragTarget(null);
      },
      onLinkConfirm: (node) {
        setDragTarget(null);
        linkItem(node, linkTarget);
      },
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

  Widget toggleLinksButton() {
    return ComposerActionButton(
      icon: Icons.link,
      onClick: () {
        setState(() {
          showAllLinks = !showAllLinks;
        });
        syncItemOverlays();
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

  void addNewItem({bool linkToParent = false}) {
    final itemId = itemIdCounter++;

    final constraint = linkToParent ? LinkToParent() : null;
    final item = ConstrainedItem(
      id: itemId,
      top: constraint,
      bottom: constraint,
      left: constraint,
      right: constraint,
      child: Container(),
    );

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
    runPostFrame(syncItemOverlays);
  }

  void setDragTarget(LinkNode<int>? target) {
    final origin = dragData?.origin;
    if (target != null && origin != null && !origin.canLinkTo(target)) {
      return;
    }

    setState(() {
      dragTarget = target;
    });
  }

  void syncLayout(BoxConstraints constraints) {
    if (lastConstraints != null && lastConstraints != constraints) {
      lastConstraints = constraints;
      runPostFrame(syncItemOverlays);
    }
    lastConstraints = constraints;
  }

  void syncItemOverlays() async {
    final activeLinkItems = items.where((item) {
      return showAllLinks ||
          dragData?.origin.itemId == item.id ||
          hoverTracker.isHovered(item.id);
    }).sortedBy((item1, item2) {
      return hoverTracker.isHovered(item1.id) ? 1 : -1;
    });

    final itemLinks = [
      for (var item in activeLinkItems)
        for (var (edge, constraint) in item.constraints.records)
          if (constraint != null) itemLink(item.id, edge, constraint),
    ];

    final activeHandleItems = items.where((item) {
      return dragData != null || hoverTracker.isHovered(item.id);
    });

    final itemHandles = [
      for (var item in activeHandleItems)
        for (var edge in Edge.values) itemHandle(item, edge),
    ];

    setState(() {
      this.itemLinks = itemLinks;
      this.itemHandles = itemHandles;
    });
  }

  void linkItem(LinkNode<int> origin, LinkNode<int> target) {
    if (!origin.canLinkTo(target)) {
      return;
    }

    final constraint = switch (target) {
      LinkNode(:var itemId?, :var edge) => LinkTo(id: itemId, edge: edge),
      LinkNode(itemId: null) => LinkToParent(),
    };
    final updatedItem =
        findItem(origin).constrainedAlong(constraint, origin.edge);
    replaceItem(updatedItem);
  }

  ConstrainedItem<int> findItem(LinkNode<int> node) {
    return items.firstWhere((item) => item.id == node.itemId);
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

class ComposerDragData {
  ComposerDragData({
    required this.origin,
    required this.delta,
  });

  final LinkNode<int> origin;
  final Offset delta;

  bool get moved => delta != Offset.zero;
}

class HoverTracker<IdType> {
  final Map<IdType, Set<Edge>> _edges = {};
  final Set<IdType> _items = {};

  void setItemHovered(IdType itemId, bool hovered) {
    hovered ? _items.add(itemId) : _items.remove(itemId);
  }

  void setEdgeHovered(IdType itemId, Edge edge, bool hovered) {
    hovered ? _edgesOf(itemId).add(edge) : _edgesOf(itemId).remove(edge);
  }

  bool isHovered(IdType itemId) {
    return _items.contains(itemId) || _edgesOf(itemId).isNotEmpty;
  }

  Set<Edge> _edgesOf(IdType itemId) {
    return _edges.putIfAbsent(itemId, () => {});
  }
}
