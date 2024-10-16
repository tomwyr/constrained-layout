import 'package:constrained_layout/constrained_layout.dart';

import 'extensions.dart';

extension ConstrainedLayoutWidgetCode on ConstrainedLayout {
  String get widgetCode {
    final itemsCode = switch (items) {
      [] => '[]',
      _ => '''[
${items.map((item) => item.widgetCode).join('\n')}
    ]''',
    };

    return '''
  ConstrainedLayout(
    items: $itemsCode,
  )''';
  }
}

extension on ConstrainedItem {
  String get widgetCode {
    final constraintsCode = [
      for (var (edge, constraint) in constraints.records)
        if (constraint != null) '${edge.name}: ${constraint.widgetCode}'.linePrefixed('  ' * 4),
    ].join('\n');

    return [
      '''
      ConstrainedItem(
        id: $id,''',
      if (constraintsCode.isNotEmpty) constraintsCode,
      '''
        child: Square(),
      ),'''
    ].join('\n');
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
