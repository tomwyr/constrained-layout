import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

import '../../common/animation_builder.dart';
import '../../common/link_path/link_path.dart';
import '../../types.dart';
import '../model.dart';

class ItemLink extends StatelessWidget {
  const ItemLink({
    super.key,
    required this.itemId,
    required this.edge,
    required this.constraint,
    this.overrideActive,
  });

  final int itemId;
  final Edge edge;
  final Constraint constraint;
  final bool? overrideActive;

  @override
  Widget build(BuildContext context) {
    final fromOffset = layoutUtils.positionOfEdge(itemId, edge);
    final toOffset = switch (constraint) {
      LinkToParent() => layoutUtils.positionOfEdge(null, edge),
      LinkTo(:var id, :var edge) => layoutUtils.positionOfEdge(id, edge),
    };
    final toEdge = switch (constraint) {
      LinkToParent() => edge,
      LinkTo(:var edge) => edge,
    };
    final toParent = switch (constraint) {
      LinkToParent() => true,
      LinkTo() => false,
    };

    final active = overrideActive ??
        dragModel.dragData == null && hoverTracker.isHovered(itemId);

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
}

class DragLink extends StatelessWidget {
  const DragLink({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dragModel,
      builder: (context, child) {
        final LinkNode(:itemId, :edge) = dragModel.dragData!.origin;
        final fromOffset = layoutUtils.positionOfEdge(itemId, edge);
        final toOffset = switch (dragModel.dragTarget) {
          LinkNode(:var itemId, :var edge) =>
            layoutUtils.positionOfEdge(itemId, edge),
          null => fromOffset + dragModel.dragData!.delta,
        };
        final toParent = switch (dragModel.dragTarget) {
          LinkNode(itemId: null) => true,
          _ => false,
        };

        return AnimationBuilder(
          active: dragModel.dragTarget != null,
          duration: const Duration(seconds: 1),
          listenableBuilder: (listenable) => LinkPath(
            animation: listenable,
            type: LinkPathStyle.bold,
            fromOffset: fromOffset,
            toOffset: toOffset,
            fromEdge: edge,
            toEdge: dragModel.dragTarget?.edge,
            toParent: toParent,
          ),
        );
      },
    );
  }
}
