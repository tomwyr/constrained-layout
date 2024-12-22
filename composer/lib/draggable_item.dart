import 'dart:math';

import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

import 'widgets/hover_region.dart';

class DraggableItem<IdType> extends StatelessWidget {
  const DraggableItem({
    super.key,
    required this.itemId,
    required this.onHover,
  });

  static Color colorOf(ConstrainedItem item) => _colorForId(item.id);

  final IdType itemId;
  final void Function(bool hovered) onHover;

  @override
  Widget build(BuildContext context) {
    return HoverRegion.listener(
      onChange: onHover,
      child: ItemSquare(
        color: _colorForId(itemId),
      ),
    );
  }
}

class DraggableItemHandle<IdType> extends StatelessWidget {
  const DraggableItemHandle({
    super.key,
    required this.edge,
    required this.itemId,
    required this.draggedNode,
    required this.onLinkCandidate,
    required this.onLinkCancel,
    required this.onLinkConfirm,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onUnlink,
    this.onHover,
  });

  final Edge edge;
  final IdType itemId;
  final LinkNode<int>? draggedNode;
  final void Function(Edge edge) onLinkCandidate;
  final void Function() onLinkCancel;
  final void Function(Edge edge, LinkNode<IdType> node) onLinkConfirm;
  final void Function(Edge edge) onDragStart;
  final void Function(Edge edge, Offset delta) onDragUpdate;
  final void Function(Edge edge) onDragEnd;
  final void Function(Edge edge) onUnlink;
  final void Function(bool hovered)? onHover;

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: DragTarget<LinkNode<IdType>>(
        onMove: (details) {
          if (details.data.itemId != itemId) {
            onLinkCandidate(edge);
          }
        },
        onLeave: (data) {
          if (data?.itemId != itemId) {
            onLinkCancel();
          }
        },
        onAcceptWithDetails: (details) {
          if (details.data.itemId != itemId) {
            onLinkConfirm(edge, details.data);
          }
        },
        builder: (context, candidateData, rejectedData) {
          final dot = DotHandle(
            enabled: itemEdgeEnabled(edge),
            edge: edge,
            onTap: () => onUnlink(edge),
            onHover: onHover,
          );

          return Draggable<LinkNode<IdType>>(
            data: LinkNode(itemId: itemId, edge: edge),
            onDragStarted: () {
              onDragStart(edge);
            },
            onDragUpdate: (details) {
              onDragUpdate(edge, details.delta);
            },
            onDragEnd: (details) {
              onDragEnd(edge);
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
    final origin = draggedNode;
    if (origin == null) {
      return true;
    } else if (origin.itemId == itemId) {
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
      child: FractionalTranslation(
        translation: dotOffset(0.5),
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
            final enabled =
                draggedEdge == null || edge.axis == draggedEdge?.axis;
            return DotHandle(
              enabled: enabled,
              edge: edge,
            );
          },
        ),
      ),
    );
  }

  Offset dotOffset(double value) {
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
    this.onHover,
  });

  final bool enabled;
  final Edge edge;
  final double size;
  final VoidCallback? onTap;
  final void Function(bool hovered)? onHover;

  @override
  Widget build(BuildContext context) {
    return HoverRegion(
      onChange: onHover,
      builder: (hovered) => TweenAnimationBuilder(
        duration: const Duration(milliseconds: 100),
        tween: scaleTween(hovered),
        builder: (context, scale, child) => GestureDetector(
          onTap: onTap,
          child: Container(
            width: size * scale,
            height: size * scale,
            decoration: ShapeDecoration(
              shape: const CircleBorder(),
              color: enabled ? Colors.amber[700] : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Tween<double> scaleTween(bool hovered) {
    return Tween(begin: 1, end: enabled && hovered ? 1.5 : 1);
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

final _colorsById = <dynamic, Color>{};
Color _colorForId(dynamic id) => _colorsById.putIfAbsent(id, _randomizeColor);
Color _randomizeColor() {
  final zeroToOne = Random().nextDouble();
  return Color(0xff000000 + 0xffffff * zeroToOne ~/ 2);
}
