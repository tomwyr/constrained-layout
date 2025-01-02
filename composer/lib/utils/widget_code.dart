import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/widgets.dart';

import 'extensions.dart';

extension ConstrainedLayoutWidgetCode<IdType extends Object>
    on ConstrainedLayout<IdType> {
  String get widgetCode {
    final itemsCode = [
      if (items.isEmpty)
        '[]'
      else ...[
        '[\n',
        items.widgetCode,
        '  ]',
      ],
    ];

    return [
      'ConstrainedLayout(',
      '  items: ${itemsCode.join()},',
      ')',
    ].join('\n');
  }

  TextSpan widgetCodeSpan({List<IdType> highlightedItems = const []}) {
    final itemSpans = items.widgetCodeSpans(highlightedItems: highlightedItems);

    final itemsCode = [
      if (itemSpans.isEmpty)
        '[],'
      else ...[
        '[\n',
        itemSpans,
        '  ],',
      ],
    ];

    return TextSpan(
      children: [
        'ConstrainedLayout(\n',
        '  items: ',
        itemsCode,
        '\n)',
      ].spans,
    );
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
  String linePrefixed(String prefix) {
    return split('\n').map((line) => prefix + line).join('\n');
  }
}

extension ConstrainedItemsExtensions<IdType> on List<ConstrainedItem<IdType>> {
  String get widgetCode {
    return [
      for (var item in this) '${item.widgetCode},\n',
    ].join();
  }

  List<Object> widgetCodeSpans({List<IdType> highlightedItems = const []}) {
    return [
      for (var item in this) ...[
        item.widgetCodeSpan(highlighted: highlightedItems.contains(item.id)),
        ',\n',
      ],
    ];
  }
}

extension on List<Object> {
  List<InlineSpan> get spans {
    return [
      for (var element in this)
        ...switch (element) {
          List<Object>() => element.spans,
          InlineSpan() => [element],
          String() => [TextSpan(text: element)],
          _ => throw ArgumentError('Unsupported rich text type: $element'),
        },
    ];
  }
}
