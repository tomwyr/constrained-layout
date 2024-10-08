import 'dart:math';

import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

import 'widgets/hover_builder.dart';

class DraggableItem<IdType> extends StatefulWidget {
  const DraggableItem({
    super.key,
    required this.itemId,
    required this.onLink,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final IdType itemId;
  final void Function(Edge edge, LinkNode<IdType> node) onLink;
  final void Function(Edge edge) onDragStart;
  final void Function(Edge edge, Offset delta) onDragUpdate;
  final void Function(Edge edge) onDragEnd;

  @override
  State<DraggableItem<IdType>> createState() => _DraggableItemState();
}

class _DraggableItemState<IdType> extends State<DraggableItem<IdType>> {
  late final color = randomizeColor();

  var hovered = false;
  var dragging = false;

  bool get active => hovered || dragging;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: HoverRegion.listener(
        onChange: (value) {
          setState(() => hovered = value);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            itemBox(),
            if (active) ...[
              itemHandle(Edge.top),
              itemHandle(Edge.bottom),
              itemHandle(Edge.left),
              itemHandle(Edge.right),
            ],
          ],
        ),
      ),
    );
  }

  Widget itemBox() {
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        color: color,
      ),
    );
  }

  Widget itemHandle(Edge edge) {
    final dot = DotHandle(edge: edge, size: 8);

    return Align(
      alignment: edge.toAlignment(),
      child: DragTarget<LinkNode<IdType>>(
        onAcceptWithDetails: (details) {
          if (details.data.itemId != widget.itemId) {
            widget.onLink(edge, details.data);
          }
        },
        builder: (context, candidateData, rejectedData) => Draggable<LinkNode<IdType>>(
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
        ),
      ),
    );
  }

  Color randomizeColor() {
    final zeroToOne = Random().nextDouble();
    return Color(0xff000000 + 0xffffff * zeroToOne ~/ 2);
  }
}

class ParentItemTarget<IdType> extends StatelessWidget {
  const ParentItemTarget({
    super.key,
    required this.edge,
    required this.onLink,
  });

  final Edge edge;
  final void Function(LinkNode<IdType> node) onLink;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: edge.toAlignment(),
      child: DragTarget<LinkNode<IdType>>(
        onAcceptWithDetails: (details) {
          if (details.data case LinkNode<IdType> node) {
            onLink(node);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return DotHandle(edge: edge, size: 12);
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

class LinkNode<IdType> {
  LinkNode({
    required this.itemId,
    required this.edge,
  });

  final IdType? itemId;
  final Edge edge;
}

class DotHandle extends StatelessWidget {
  const DotHandle({
    super.key,
    required this.edge,
    required this.size,
  });

  final Edge edge;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: edge.layoutOffset(size / 2),
      child: HoverRegion(
        builder: (hovered) => AnimatedScale(
          duration: const Duration(milliseconds: 100),
          scale: hovered ? 1.5 : 1,
          child: Container(
            width: size,
            height: size,
            decoration: ShapeDecoration(
              shape: const CircleBorder(),
              color: Colors.amber[700],
            ),
          ),
        ),
      ),
    );
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
