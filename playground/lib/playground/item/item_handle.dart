import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

import '../../types.dart';
import '../model.dart';
import 'item_dot.dart';

class ItemHandle extends StatelessWidget {
  const ItemHandle({
    super.key,
    required this.item,
    required this.edge,
  });

  final ConstrainedItem<int> item;
  final Edge edge;

  @override
  Widget build(BuildContext context) {
    final origin = dragModel.dragData?.origin;
    final position = layoutUtils.positionOfEdge(item.id, edge);
    final visible = dragModel.dragTarget == null || item.id != origin?.itemId;

    final target = LinkNode(itemId: item.id, edge: edge);
    final enabled = itemsModel.canLink(origin, target);

    return Positioned(
      key: ValueKey((item.id, edge)),
      left: position.dx,
      top: position.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: DragTarget<LinkNode<int>>(
          onMove: (details) {
            if (details.data.itemId != item.id) {
              dragModel.setDragTarget(LinkNode(itemId: item.id, edge: edge));
            }
          },
          onLeave: (data) {
            if (data?.itemId != item.id) {
              dragModel.setDragTarget(null);
            }
          },
          onAcceptWithDetails: (details) {
            if (details.data.itemId != item.id) {
              final linkTarget = LinkNode(itemId: item.id, edge: edge);
              dragModel.setDragTarget(null);
              itemsModel.linkItemAndReplace(details.data, linkTarget);
            }
          },
          builder: (context, candidateData, rejectedData) {
            final dot = Opacity(
              opacity: visible ? 1 : 0,
              child: ItemLinkDot(
                enabled: enabled,
                onTap: () {
                  final updatedItem = item.constrainedAlong(null, edge);
                  itemsHistory.replaceItem(updatedItem);
                },
                onHover: (hovered) {
                  hoverTracker.setEdgeHovered(item.id, edge, hovered);
                },
              ),
            );

            return Draggable<LinkNode<int>>(
              data: LinkNode(itemId: item.id, edge: edge),
              onDragStarted: () {
                dragModel.startDrag(item, edge);
              },
              onDragUpdate: (details) {
                dragModel.updateDrag(item, edge, details.delta);
              },
              onDragEnd: (details) {
                dragModel.endDrag();
              },
              feedback: const SizedBox.shrink(),
              childWhenDragging: dot,
              child: dot,
            );
          },
        ),
      ),
    );
  }
}

class ParentHandle extends StatelessWidget {
  const ParentHandle({
    super.key,
    required this.edge,
  });

  final Edge edge;

  @override
  Widget build(BuildContext context) {
    final linkTarget = LinkNode<int>(itemId: null, edge: edge);
    final draggedEdge = dragModel.dragData?.origin.edge;

    return Align(
      alignment: edge.toAlignment(),
      child: FractionalTranslation(
        translation: _dotOffset(0.5),
        child: DragTarget<LinkNode<int>>(
          onMove: (details) {
            if (details.data.itemId != null) {
              dragModel.setDragTarget(linkTarget);
            }
          },
          onLeave: (data) {
            if (data?.itemId != null) {
              dragModel.setDragTarget(null);
            }
          },
          onAcceptWithDetails: (details) {
            if (details.data.itemId != null) {
              dragModel.setDragTarget(null);
              itemsModel.linkItemAndReplace(details.data, linkTarget);
            }
          },
          builder: (context, candidateData, rejectedData) {
            return ItemLinkDot(
              enabled: draggedEdge == null || edge.axis == draggedEdge.axis,
            );
          },
        ),
      ),
    );
  }

  Offset _dotOffset(double value) {
    return switch (edge) {
      Edge.top => Offset(0, -value),
      Edge.bottom => Offset(0, value),
      Edge.left => Offset(-value, 0),
      Edge.right => Offset(value, 0),
    };
  }
}

class PreviewHandle extends StatelessWidget {
  const PreviewHandle({
    super.key,
    required this.itemId,
    required this.edge,
  });

  final int itemId;
  final Edge edge;

  @override
  Widget build(BuildContext context) {
    final origin = dragModel.dragData!.origin;
    final position = layoutUtils.positionOfEdge(itemId, edge);

    return Positioned(
      key: ValueKey((itemId, edge)),
      left: position.dx,
      top: position.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Dot(
          enabled: origin.edge == edge,
        ),
      ),
    );
  }
}
