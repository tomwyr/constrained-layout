import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../utils/fullscreen/fullscreen.dart';
import 'model.dart';

class PlaygroundActions extends StatelessWidget {
  const PlaygroundActions({
    super.key,
    required this.createItem,
    required this.onToggleLinks,
    required this.onToggleCode,
  });

  final ValueGetter<ConstrainedItem<int>> createItem;
  final VoidCallback onToggleLinks;
  final VoidCallback onToggleCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _addItemButton(),
        _clearItemsButton(),
        _toggleLinksButton(),
        _toggleCodeButton(),
        if (isFullScreenSupported) _fullScreenButton(),
        _historyUndoButton(),
        _historyRedoButton(),
      ],
    );
  }

  Widget _addItemButton() {
    return PlaygroundActionButton(
      hint: 'Add new item',
      icon: Icons.add,
      onClick: () => itemsHistory.addItem(createItem()),
    );
  }

  Widget _clearItemsButton() {
    return PlaygroundActionButton(
      hint: 'Delete items',
      icon: Icons.delete,
      onClick: itemsHistory.clearItems,
    );
  }

  Widget _toggleLinksButton() {
    return PlaygroundActionButton(
      hint: 'Toggle links visibility',
      icon: Icons.link,
      onClick: onToggleLinks,
    );
  }

  Widget _toggleCodeButton() {
    return PlaygroundActionButton(
      hint: 'Toggle code tab',
      icon: Icons.code,
      onClick: onToggleCode,
    );
  }

  Widget _fullScreenButton() {
    return PlaygroundActionButton(
      hint: 'Toggle full screen',
      icon: isFullScreen() ? Icons.fullscreen_exit : Icons.fullscreen,
      onClick: () {
        setFullScreen(!isFullScreen());
      },
    );
  }

  Widget _historyUndoButton() {
    return PlaygroundActionButton(
      hint: 'Undo',
      icon: Icons.undo,
      onClick: itemsHistory.canUndo ? itemsHistory.undo : null,
    );
  }

  Widget _historyRedoButton() {
    return PlaygroundActionButton(
      hint: 'Redo',
      icon: Icons.redo,
      onClick: itemsHistory.canRedo ? itemsHistory.redo : null,
    );
  }
}

class PlaygroundActionButton extends StatelessWidget {
  const PlaygroundActionButton({
    super.key,
    required this.hint,
    required this.icon,
    required this.onClick,
  });

  final String hint;
  final IconData icon;
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Opacity(
        opacity: onClick == null ? 0.5 : 1,
        child: DecoratedBox(
          decoration: const ShapeDecoration(
            color: AppColors.canvas,
            shape: CircleBorder(
              side: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Tooltip(
            message: hint,
            child: IconButton(
              iconSize: 16,
              icon: Icon(icon),
              onPressed: onClick,
            ),
          ),
        ),
      ),
    );
  }
}
