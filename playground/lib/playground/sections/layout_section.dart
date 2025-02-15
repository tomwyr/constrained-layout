import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

import '../../types.dart';
import '../../utils/extensions.dart';
import '../../utils/functions.dart';
import '../item/item_handle.dart';
import '../item/item_link.dart';
import '../item/item_square.dart';
import '../model.dart';

class PlaygroundLayoutSection extends StatelessWidget {
  const PlaygroundLayoutSection({
    super.key,
    required this.showAllLinks,
  });

  final bool showAllLinks;

  @override
  Widget build(BuildContext context) {
    final dragData = dragState.dragData;
    final dragTarget = dragState.dragTarget;
    final previewItem = dragData != null && dragTarget != null
        ? itemsActions.linkPreviewItem(dragData.origin, dragTarget)
        : null;

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          ..._itemLinks(),
          if (dragData != null) ...[
            if (dragData.moved && dragTarget == null) _dragLink(dragData),
            if (previewItem != null) ..._previewLinks(previewItem),
          ],
          const PlaygroundItemsLayout(),
          ..._itemHandles(),
          if (dragData != null) ...[
            if (previewItem != null) ..._previewHandles(previewItem),
            ..._parentHandles(),
          ],
        ],
      ),
    );
  }

  List<Widget> _itemLinks() {
    final activeItems =
        itemResolver.getActiveLinkItems(showAllLinks: showAllLinks);

    return [
      for (var item in activeItems)
        for (var (edge, constraint) in item.constraints.records)
          if (constraint != null)
            PostItemLayout(
              key: ValueKey((item.id, edge, 'item link')),
              itemId: item.id,
              builder: (_) => ItemLink(
                itemId: item.id,
                edge: edge,
                constraint: constraint,
              ),
            ),
    ];
  }

  Widget _dragLink(ItemDragData dragData) {
    final LinkNode(:itemId, :edge) = dragData.origin;
    return PostItemLayout(
      key: ValueKey((itemId, edge, 'drag link')),
      itemId: itemId!,
      builder: (_) => const DragLink(),
    );
  }

  List<Widget> _previewLinks(ConstrainedItem<int> previewItem) {
    final itemId = previewItem.id;

    return [
      for (var (edge, constraint) in previewItem.constraints.records)
        if (constraint != null)
          PostItemLayout(
            key: ValueKey((itemId, edge, 'preview link')),
            itemId: itemId,
            builder: (_) => ItemLink(
              itemId: itemId,
              edge: edge,
              constraint: constraint,
              overrideActive: edge == dragState.dragData!.origin.edge,
            ),
          ),
    ];
  }

  List<Widget> _itemHandles() {
    final activeItems = itemResolver.getActiveHandleItems();

    return [
      for (var item in activeItems)
        for (var edge in Edge.values)
          PostItemLayout(
            key: ValueKey((item.id, edge, 'item handle')),
            itemId: item.id,
            builder: (_) => ItemHandle(
              item: item,
              edge: edge,
            ),
          ),
    ];
  }

  List<Widget> _previewHandles(ConstrainedItem<int> previewItem) {
    final itemId = previewItem.id;

    return [
      for (var edge in Edge.values)
        PostItemLayout(
          key: ValueKey((itemId, edge, 'preview handle')),
          itemId: itemId,
          builder: (_) => PreviewHandle(
            itemId: itemId,
            edge: edge,
          ),
        ),
    ];
  }

  List<Widget> _parentHandles() {
    return [
      for (var edge in Edge.values) ParentHandle(edge: edge),
    ];
  }
}

class PlaygroundItemsLayout extends StatelessWidget {
  const PlaygroundItemsLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: itemsHistory,
      builder: (context, child) => ConstrainedLayout(
        key: layoutUtils.layoutKey,
        items: [
          ...itemsHistory.items.map(_regularItem),
          if (_previewItem() case var previewItem?) previewItem,
        ],
      ),
    );
  }

  ConstrainedItem<int> _regularItem(ConstrainedItem<int> item) {
    final previewed = dragState.dragData?.origin.itemId == item.id &&
        dragState.dragTarget != null;
    final child = ItemSquare(
      key: layoutUtils.getItemKey(item.id),
      onHover: (hovered) {
        hoverTracker.setItemHovered(item.id, hovered);
      },
      colorId: item.id,
      opacity: previewed ? 0.5 : 1,
    );

    return item.swapChild(child);
  }

  ConstrainedItem<int>? _previewItem() {
    final originId = dragState.dragData?.origin.itemId;
    final previewItem = itemResolver.getLinkPreviewItem();
    if (originId == null || previewItem == null) {
      return null;
    }

    final child = ItemSquare(
      key: layoutUtils.getItemKey(previewItem.id),
      colorId: originId,
    );
    return previewItem.swapChild(child);
  }
}

class PostItemLayout extends StatefulWidget {
  const PostItemLayout({
    super.key,
    required this.itemId,
    required this.builder,
  });

  final int itemId;
  final WidgetBuilder builder;

  @override
  State<PostItemLayout> createState() => _PostItemLayoutState();
}

class _PostItemLayoutState extends State<PostItemLayout> {
  bool get _isRendered => layoutUtils.isItemRendered(widget.itemId);

  @override
  void didUpdateWidget(covariant PostItemLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    runPostFrame(_scheduleRebuild);
  }

  void _scheduleRebuild() {
    runPostFrame(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRendered) {
      _scheduleRebuild();
    }
    return _isRendered ? widget.builder(context) : const SizedBox.shrink();
  }
}
