import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/widgets.dart';

import 'extensions.dart';

extension ConstrainedLayoutWidgetCode<IdType extends Object>
    on ConstrainedLayout<IdType> {
  String get widgetCode {
    final itemsCode = switch (items) {
      [] => '[]',
      _ => '''[
${items.widgetCode}
  ]''',
    };

    return '''
ConstrainedLayout(
  items: $itemsCode,
)''';
  }

  TextSpan widgetCodeSpan({List<IdType> highlightedItems = const []}) {
    final itemsCode = switch (items) {
      [] => ['[]'.span],
      _ => [
          '  items: [\n'.span,
          for (var span
              in items.widgetCodeSpans(highlightedItems: highlightedItems)) ...[
            span,
            ',\n'.span,
          ],
          '  ],'.span
        ],
    };

    return TextSpan(children: [
      'ConstrainedLayout(\n'.span,
      ...itemsCode,
      '\n)'.span,
    ]);
  }
}

extension on ConstrainedItem {
  String get widgetCode {
    final constraintsCode = [
      for (var (edge, constraint) in constraints.records)
        if (constraint != null)
          '${edge.name}: ${constraint.widgetCode}'.linePrefixed('  ' * 3),
    ].join('\n');

    return [
      '''
    ConstrainedItem(
      id: $id,''',
      if (constraintsCode.isNotEmpty) constraintsCode,
      '''
      child: Square(),
    )'''
    ].join('\n');
  }

  InlineSpan widgetCodeSpan({bool highlighted = false}) {
    return TextSpan(
      text: widgetCode,
      style: TextStyle(
        fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

extension on Constraint {
  String get widgetCode {
    return switch (this) {
      LinkToParent() => 'LinkToParent(),',
      LinkTo(:var id, :var edge) => 'LinkTo(id: $id, edge: Edge.${edge.name}),',
    };
  }
}

extension on String {
  TextSpan get span => TextSpan(text: this);

  String linePrefixed(String prefix) {
    return split('\n').map((line) => prefix + line).join('\n');
  }
}

extension ConstrainedItemsExtensions<IdType> on List<ConstrainedItem<IdType>> {
  String get widgetCode {
    return [
      for (var item in this) '${item.widgetCode},',
    ].join('\n');
  }

  List<InlineSpan> widgetCodeSpans({List<IdType> highlightedItems = const []}) {
    return [
      for (var item in this)
        item.widgetCodeSpan(highlighted: highlightedItems.contains(item.id)),
    ];
  }
}
