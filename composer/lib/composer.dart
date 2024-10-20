import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'draggable_item.dart';
import 'link_path.dart';
import 'utils/extensions.dart';
import 'utils/widget_code.dart';
import 'widgets/animation_builder.dart';

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
  var itemLinks = <Widget>[];
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
            ConstrainedLayout(
              key: layoutKey,
              items: [
                ...items.map(itemWithChild),
                if (linkPreviewData() case (var start, var end))
                  linkPreviewItem(start, end),
              ],
            ),
          ],
        );
      },
    );
  }

  ConstrainedItem<int> itemWithChild(ConstrainedItem<int> item) {
    final child = DraggableItem(
      key: handleKeyFor(item.id),
      itemId: item.id,
      draggedEdge: dragData?.origin.edge,
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
      },
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
        color: DraggableItem.colorOf(originItem).withOpacity(0.25),
      ),
    );

    return item
        .withConstraintsOf(originItem)
        .constrainedAlong(constraint, origin.edge);
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
    final fromOffset = positionOfEdge(itemId, edge);
    final toOffset = switch (dragTarget) {
      LinkNode(:var itemId, :var edge) => positionOfEdge(itemId, edge),
      null => fromOffset + dragData!.delta,
    };
    final toParent = switch (dragTarget) {
      LinkNode(itemId: null) => true,
      _ => false,
    };
    return LinkPath(
      active: true,
      fromOffset: fromOffset,
      toOffset: toOffset,
      fromEdge: edge,
      toEdge: dragTarget?.edge,
      toParent: toParent,
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
    return AnimationBuilder(
      active: true,
      looped: true,
      duration: const Duration(milliseconds: 500),
      listenableBuilder: (listenable) => LinkPath(
        animation: listenable,
        active: false,
        fromOffset: fromOffset,
        toOffset: toOffset,
        fromEdge: edge,
        toEdge: toEdge,
        toParent: toParent,
      ),
    );
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
    final linkTarget = LinkNode<int>(itemId: null, edge: edge);

    return Align(
      alignment: edge.toAlignment(),
      child: ParentItemTarget<int>(
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
    syncItemLinks();
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
      syncItemLinks();
    }
    lastConstraints = constraints;
  }

  void syncItemLinks() {
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
