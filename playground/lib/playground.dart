import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'draggable_item.dart';
import 'link_path.dart';
import 'utils/extensions.dart';
import 'utils/fullscreen/fullscreen.dart';
import 'utils/functions.dart';
import 'utils/widget_code.dart';
import 'widgets/animation_builder.dart';
import 'widgets/hover_region.dart';

class Playground extends StatefulWidget {
  const Playground({super.key});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  static const _previewItemId = -1;

  final layoutKey = GlobalKey();
  final handleKeys = <int?, GlobalKey>{};
  final itemsTracker = ItemsTracker();
  final layoutOrder = const LayoutOrder();

  var itemIdCounter = 0;
  var hoverTracker = HoverTracker<int>();
  var itemLinks = <Widget>[];
  var itemHandles = <Widget>[];
  var showAllLinks = true;
  var showCode = true;

  BoxConstraints? lastConstraints;
  ItemDragData? dragData;
  LinkNode<int>? dragTarget;

  List<ConstrainedItem<int>> get items => itemsTracker.activeItmes;

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
        if (isFullScreenSupported) fullScreenButton(),
        ...historyButtons(),
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
            if (dragData != null) ...[
              if (dragData!.moved && dragTarget == null) dragLink(),
              if (dragTarget != null) ...itemPreviewLinks(),
            ],
            constrainedLayout(),
            ...itemHandles,
            if (dragData != null) ...[
              if (dragTarget != null) ...itemPreviewHandles(),
              parentHandles(),
            ],
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
    if (origin != null && target != null && canLink(origin, target)) {
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
        key: handleKeyFor(_previewItemId),
        item: originItem,
      ),
    );

    return item
        .withConstraintsOf(originItem)
        .constrainedAlong(constraint, origin.edge);
  }

  Widget layoutCode() {
    return ValueListenableBuilder(
      valueListenable: hoverTracker.hoveredItems,
      builder: (context, hoveredItems, child) {
        final widgetCode = ConstrainedLayout(items: items)
            .widgetCodeSpan(highlightedItems: hoveredItems);

        return HoverRegion(
          builder: (hovered) => Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: SelectableText.rich(widgetCode),
              ),
              if (hovered)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: copyCodeButton(widgetCode.toPlainText()),
                  ),
                ),
            ],
          ),
        );
      },
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

  List<Widget> itemPreviewHandles() {
    final pendingPreview = handleKeyFor(_previewItemId).currentContext == null;
    if (pendingPreview) {
      return [];
    }

    return [
      for (var edge in Edge.values)
        Positioned(
          key: ValueKey((_previewItemId, edge)),
          left: positionOfEdge(_previewItemId, edge).dx,
          top: positionOfEdge(_previewItemId, edge).dy,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: Dot(
              enabled: dragData!.origin.edge == edge,
            ),
          ),
        ),
    ];
  }

  List<Widget> itemPreviewLinks() {
    final pendingPreview = handleKeyFor(_previewItemId).currentContext == null;
    if (pendingPreview) {
      return [];
    }

    final linkedItem = linkItem(dragData!.origin, dragTarget!);

    return [
      for (var (edge, constraint) in linkedItem.constraints.records)
        if (constraint != null)
          itemLink(
            _previewItemId,
            edge,
            constraint,
            overrideActive: edge == dragData!.origin.edge,
          ),
    ];
  }

  Widget itemLink(
    int itemId,
    Edge edge,
    Constraint constraint, {
    bool? overrideActive,
  }) {
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

    final active =
        overrideActive ?? dragData == null && hoverTracker.isHovered(itemId);

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
    final visible = dragTarget == null || item.id != dragData?.origin.itemId;

    final origin = dragData?.origin;
    final target = LinkNode(itemId: item.id, edge: edge);
    final enabled = canLink(origin, target);

    return Positioned(
      key: ValueKey((item.id, edge)),
      left: position.dx,
      top: position.dy,
      child: DraggableItemHandle(
        edge: edge,
        itemId: item.id,
        visible: visible,
        enabled: enabled,
        onLinkCandidate: () {
          setDragTarget(LinkNode(itemId: item.id, edge: edge));
        },
        onLinkCancel: () {
          setDragTarget(null);
        },
        onLinkConfirm: (node) {
          final linkTarget = LinkNode(itemId: item.id, edge: edge);
          setDragTarget(null);
          linkItemAndReplace(node, linkTarget);
        },
        onDragStart: () {
          setState(() {
            dragData = ItemDragData(
              origin: LinkNode(itemId: item.id, edge: edge),
              delta: Offset.zero,
            );
          });
          syncItemOverlays();
        },
        onDragUpdate: (delta) {
          setState(() {
            dragData = ItemDragData(
              origin: LinkNode(itemId: item.id, edge: edge),
              delta: dragData!.delta + delta,
            );
          });
        },
        onDragEnd: () {
          setState(() {
            dragData = null;
          });
          syncItemOverlays();
        },
        onUnlink: () {
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

  bool canLink(LinkNode<int>? origin, LinkNode<int> target) {
    if (origin == null) {
      return true;
    } else if (origin.itemId == target.itemId) {
      return origin.edge == target.edge;
    } else if (origin.edge.axis != target.edge.axis) {
      return false;
    }

    return layoutOrder.canResolve([
      for (var item in items)
        item.id == origin.itemId ? linkItem(origin, target) : item
    ]);
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
        linkItemAndReplace(node, linkTarget);
      },
    );
  }

  Widget addItemButton() {
    return PlaygroundActionButton(
      icon: Icons.add,
      onClick: addNewItem,
    );
  }

  Widget clearItemsButton() {
    return PlaygroundActionButton(
      icon: Icons.delete,
      onClick: clearItems,
    );
  }

  Widget toggleLinksButton() {
    return PlaygroundActionButton(
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
    return PlaygroundActionButton(
      icon: Icons.code,
      onClick: () {
        setState(() {
          showCode = !showCode;
        });
      },
    );
  }

  Widget fullScreenButton() {
    return PlaygroundActionButton(
      icon: isFullScreen() ? Icons.fullscreen_exit : Icons.fullscreen,
      onClick: () {
        setState(() {
          setFullScreen(!isFullScreen());
        });
      },
    );
  }

  List<Widget> historyButtons() {
    return [
      PlaygroundActionButton(
        icon: Icons.undo,
        onClick:
            itemsTracker.canUndo ? () => modifyItems(itemsTracker.undo) : null,
      ),
      PlaygroundActionButton(
        icon: Icons.redo,
        onClick:
            itemsTracker.canRedo ? () => modifyItems(itemsTracker.redo) : null,
      ),
    ];
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

    modifyItems(() {
      itemsTracker.addItem(item);
    });
  }

  void removeItem(ConstrainedItem<int> item) {
    modifyItems(() {
      itemsTracker.removeItem(item.id);
    });
  }

  void replaceItem(ConstrainedItem<int> item) {
    modifyItems(() {
      itemsTracker.replaceItem(item);
    });
  }

  void clearItems() {
    modifyItems(() {
      itemsTracker.clearItems();
    });
  }

  void modifyItems(VoidCallback callback) {
    setState(callback);
    runPostFrame(syncItemOverlays);
  }

  void setDragTarget(LinkNode<int>? target) {
    final origin = dragData?.origin;
    if (target != null && origin != null && !canLink(origin, target)) {
      return;
    }

    setState(() {
      dragTarget = target;
    });

    runPostFrame(syncItemOverlays);
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
      if (dragTarget != null && dragData!.origin.itemId == item.id) {
        return false;
      }

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

  ConstrainedItem<int> linkItem(LinkNode<int> origin, LinkNode<int> target) {
    final constraint = switch (target) {
      LinkNode(:var itemId?, :var edge) => LinkTo(id: itemId, edge: edge),
      LinkNode(itemId: null) => LinkToParent(),
    };

    return findItem(origin).constrainedAlong(constraint, origin.edge);
  }

  void linkItemAndReplace(LinkNode<int> origin, LinkNode<int> target) {
    if (!canLink(origin, target)) {
      return;
    }
    replaceItem(linkItem(origin, target));
  }

  ConstrainedItem<int> findItem(LinkNode<int> node) {
    return items.firstWhere((item) => item.id == node.itemId);
  }
}

class PlaygroundActionButton extends StatelessWidget {
  const PlaygroundActionButton({
    super.key,
    required this.icon,
    required this.onClick,
  });

  final IconData icon;
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Opacity(
        opacity: onClick == null ? 0.5 : 1,
        child: FloatingActionButton.small(
          onPressed: onClick,
          child: Icon(icon),
        ),
      ),
    );
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

class HoverTracker<IdType> {
  final Map<IdType, Set<Edge>> _edges = {};
  final Set<IdType> _items = {};

  final _hoveredItems = ValueNotifier(<IdType>[]);
  ValueListenable<List<IdType>> get hoveredItems => _hoveredItems;

  void setItemHovered(IdType itemId, bool hovered) {
    final itemsChanged = hovered ? _items.add(itemId) : _items.remove(itemId);
    if (itemsChanged) {
      _hoveredItems.value = _items.toList();
    }
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

class ItemsTracker {
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
  }

  void replaceItem(ConstrainedItem<int> item) {
    _trimItemsToActive();
    _items.add([
      for (var nextItem in _items.last)
        if (nextItem.id != item.id) nextItem else item,
    ]);
    _activeIndex++;
  }

  void removeItem(int itemId) {
    _trimItemsToActive();
    _items.add([
      for (var item in _items.last)
        if (item.id != itemId) item,
    ]);
    _activeIndex++;
  }

  void clearItems() {
    _trimItemsToActive();
    _items.add([]);
    _activeIndex++;
  }

  void undo() {
    if (_activeIndex > 0) {
      _activeIndex--;
    }
  }

  void redo() {
    if (_activeIndex < _items.length - 1) {
      _activeIndex++;
    }
  }

  void _trimItemsToActive() {
    if (_activeIndex > 0 && _activeIndex < _items.length - 1) {
      _items.removeRange(_activeIndex + 1, _items.length);
    }
  }
}
