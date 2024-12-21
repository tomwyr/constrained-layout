import 'dart:math';

import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

import 'widgets/hover_builder.dart';

class DraggableItem<IdType> extends StatefulWidget {
  const DraggableItem({
    super.key,
    required this.itemId,
    required this.draggedNode,
    required this.onLinkCandidate,
    required this.onLinkCancel,
    required this.onLinkConfirm,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onUnlink,
    required this.onHover,
  });

  static Color colorOf(ConstrainedItem item) => _colorForId(item.id);

  final IdType itemId;
  final LinkNode<int>? draggedNode;
  final void Function(Edge edge) onLinkCandidate;
  final void Function() onLinkCancel;
  final void Function(Edge edge, LinkNode<IdType> node) onLinkConfirm;
  final void Function(Edge edge) onDragStart;
  final void Function(Edge edge, Offset delta) onDragUpdate;
  final void Function(Edge edge) onDragEnd;
  final void Function(Edge edge) onUnlink;
  final void Function(bool hovered) onHover;

  @override
  State<DraggableItem<IdType>> createState() => _DraggableItemState();
}

class _DraggableItemState<IdType> extends State<DraggableItem<IdType>> {
  var hovered = false;
  var dragging = false;

  bool get active => hovered || dragging;

  @override
  Widget build(BuildContext context) {
    return HoverRegion.listener(
      onChange: (value) {
        setState(() => hovered = value);
        widget.onHover(value);
      },
      child: ItemSquare(
        color: _colorForId(widget.itemId),
        child: active
            ? Stack(
                fit: StackFit.expand,
                children: [
                  itemHandle(Edge.top),
                  itemHandle(Edge.bottom),
                  itemHandle(Edge.left),
                  itemHandle(Edge.right),
                ],
              )
            : null,
      ),
    );
  }

  Widget itemHandle(Edge edge) {
    return Align(
      alignment: edge.toAlignment(),
      child: DragTarget<LinkNode<IdType>>(
        onMove: (details) {
          if (details.data.itemId != widget.itemId) {
            widget.onLinkCandidate(edge);
          }
        },
        onLeave: (data) {
          if (data?.itemId != widget.itemId) {
            widget.onLinkCancel();
          }
        },
        onAcceptWithDetails: (details) {
          if (details.data.itemId != widget.itemId) {
            widget.onLinkConfirm(edge, details.data);
          }
        },
        builder: (context, candidateData, rejectedData) {
          final dot = DotHandle(
            enabled: itemEdgeEnabled(edge),
            edge: edge,
            onTap: () => widget.onUnlink(edge),
          );

          return Draggable<LinkNode<IdType>>(
            data: LinkNode(itemId: widget.itemId, edge: edge),
            onDragStarted: () {
              setState(() => dragging = true);
              widget.onDragStart(edge);
            },
            onDragUpdate: (details) {
              widget.onDragUpdate(edge, details.delta);
            },
            onDragEnd: (details) {
              setState(() => dragging = false);
              widget.onDragEnd(edge);
            },
            feedback: const SizedBox.shrink(),
            childWhenDragging: dot,
            child: dot,
          );
        },
      ),
    );
  }

  bool itemEdgeEnabled(Edge edge) {
    final origin = widget.draggedNode;
    if (origin == null) {
      return true;
    } else if (origin.itemId == widget.itemId) {
      return origin.edge == edge;
    } else {
      return origin.edge.axis == edge.axis;
    }
  }
}

class ParentItemTarget<IdType> extends StatelessWidget {
  const ParentItemTarget({
    super.key,
    required this.edge,
    required this.draggedEdge,
    required this.onLinkCandidate,
    required this.onLinkCancel,
    required this.onLinkConfirm,
  });

  final Edge edge;
  final Edge? draggedEdge;
  final void Function() onLinkCandidate;
  final void Function() onLinkCancel;
  final void Function(LinkNode<IdType> node) onLinkConfirm;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: edge.toAlignment(),
      child: DragTarget<LinkNode<IdType>>(
        onMove: (details) {
          if (details.data.itemId != null) {
            onLinkCandidate();
          }
        },
        onLeave: (data) {
          if (data?.itemId != null) {
            onLinkCancel();
          }
        },
        onAcceptWithDetails: (details) {
          if (details.data.itemId != null) {
            onLinkConfirm(details.data);
          }
        },
        builder: (context, candidateData, rejectedData) {
          final enabled = draggedEdge == null || edge.axis == draggedEdge?.axis;
          return DotHandle(
            enabled: enabled,
            edge: edge,
          );
        },
      ),
    );
  }

  Offset offset(double value) {
    return switch (edge) {
      Edge.top => Offset(0, -value),
      Edge.bottom => Offset(0, value),
      Edge.left => Offset(-value, 0),
      Edge.right => Offset(value, 0),
    };
  }
}

class ItemSquare extends StatelessWidget {
  const ItemSquare({
    super.key,
    required this.color,
    this.child,
  });

  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          color: color,
        ),
        child: child,
      ),
    );
  }
}

class DotHandle extends StatelessWidget {
  const DotHandle({
    super.key,
    required this.enabled,
    required this.edge,
    this.size = 8,
    this.onTap,
  });

  final bool enabled;
  final Edge edge;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: edge.layoutOffset(size / 2),
      child: HoverRegion(
        builder: (hovered) => AnimatedScale(
          duration: const Duration(milliseconds: 100),
          scale: enabled && hovered ? 1.5 : 1,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: enabled ? Colors.amber[700] : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LinkNode<IdType> {
  LinkNode({
    required this.itemId,
    required this.edge,
  });

  final IdType? itemId;
  final Edge edge;

  bool canLinkTo(LinkNode<IdType> other) {
    return edge.axis == other.edge.axis;
  }
}

extension on Edge {
  Offset layoutOffset(double value) {
    return switch (this) {
      Edge.top => Offset(0, -value),
      Edge.bottom => Offset(0, value),
      Edge.left => Offset(-value, 0),
      Edge.right => Offset(value, 0),
    };
  }
}

final _colorsById = <dynamic, Color>{};
Color _colorForId(dynamic id) => _colorsById.putIfAbsent(id, _randomizeColor);
Color _randomizeColor() {
  final zeroToOne = Random().nextDouble();
  return Color(0xff000000 + 0xffffff * zeroToOne ~/ 2);
}
