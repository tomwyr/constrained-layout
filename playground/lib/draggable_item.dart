import 'dart:math';

import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

import 'theme.dart';
import 'widgets/hover_region.dart';

class DraggableItemHandle<IdType> extends StatelessWidget {
  const DraggableItemHandle({
    super.key,
    required this.visible,
    required this.enabled,
    required this.edge,
    required this.itemId,
    required this.onLinkCandidate,
    required this.onLinkCancel,
    required this.onLinkConfirm,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onUnlink,
    this.onHover,
  });

  final bool visible;
  final bool enabled;
  final Edge edge;
  final IdType itemId;
  final void Function() onLinkCandidate;
  final void Function() onLinkCancel;
  final void Function(LinkNode<IdType> node) onLinkConfirm;
  final void Function() onDragStart;
  final void Function(Offset delta) onDragUpdate;
  final void Function() onDragEnd;
  final void Function() onUnlink;
  final void Function(bool hovered)? onHover;

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: DragTarget<LinkNode<IdType>>(
        onMove: (details) {
          if (details.data.itemId != itemId) {
            onLinkCandidate();
          }
        },
        onLeave: (data) {
          if (data?.itemId != itemId) {
            onLinkCancel();
          }
        },
        onAcceptWithDetails: (details) {
          if (details.data.itemId != itemId) {
            onLinkConfirm(details.data);
          }
        },
        builder: (context, candidateData, rejectedData) {
          final dot = Opacity(
            opacity: visible ? 1 : 0,
            child: DotHandle(
              enabled: enabled,
              onTap: onUnlink,
              onHover: onHover,
            ),
          );

          return Draggable<LinkNode<IdType>>(
            data: LinkNode(itemId: itemId, edge: edge),
            onDragStarted: onDragStart,
            onDragUpdate: (details) {
              onDragUpdate(details.delta);
            },
            onDragEnd: (details) {
              onDragEnd();
            },
            feedback: const SizedBox.shrink(),
            childWhenDragging: dot,
            child: dot,
          );
        },
      ),
    );
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
            return DotHandle(
              enabled: draggedEdge == null || edge.axis == draggedEdge?.axis,
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
    required this.item,
    this.opacity = 1,
    this.child,
  });

  final ConstrainedItem item;
  final double opacity;
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
          color: _colorForId(item.id).withValues(alpha: opacity),
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
    this.size = 8,
    this.onTap,
    this.onHover,
  });

  final bool enabled;
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
          child: Dot(
            enabled: enabled,
            size: size,
            scale: scale,
          ),
        ),
      ),
    );
  }

  Tween<double> scaleTween(bool hovered) {
    return Tween(begin: 1, end: enabled && hovered ? 1.5 : 1);
  }
}

class Dot extends StatelessWidget {
  const Dot({
    super.key,
    required this.enabled,
    this.size = 8,
    this.scale = 1,
  });

  final bool enabled;
  final double size;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * scale,
      height: size * scale,
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: enabled ? ghostwhiteAccent : Colors.grey,
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

  @override
  String toString() {
    return 'LinkNode(itemId: $itemId, edge: $edge)';
  }
}

final _random = Random();
final _colorsById = <dynamic, Color>{};
Color _colorForId(dynamic id) => _colorsById.putIfAbsent(id, _randomizeColor);
Color _randomizeColor() {
  final hue = _random.nextDouble() * 360;
  final saturation = 0.5 + _random.nextDouble() * 0.5; // Range: 0.5 to 1.0
  final brightness = 0.7 + _random.nextDouble() * 0.3; // Range: 0.7 to 1.0
  return HSVColor.fromAHSV(1.0, hue, saturation, brightness).toColor();
}
