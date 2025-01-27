import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/hover_region.dart';
import '../../utils/widget_code.dart';
import '../model.dart';

class PlaygroundCodeSection extends StatelessWidget {
  const PlaygroundCodeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([hoverTracker, itemsHistory]),
      builder: (context, child) {
        final widgetCode = ConstrainedLayout(items: itemsHistory.items)
            .widgetCodeSpan(highlightedItems: hoverTracker.hoveredItems);

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
                    child: CopyCodeButton(
                      content: widgetCode.toPlainText(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class CopyCodeButton extends StatelessWidget {
  const CopyCodeButton({
    super.key,
    required this.content,
  });

  final String content;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Copy',
      preferBelow: false,
      child: HoverRegion(
        builder: (hovered) => IconButton(
          icon: const Icon(Icons.copy, size: 16),
          color: !hovered ? Colors.grey : null,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: content));
          },
        ),
      ),
    );
  }
}
