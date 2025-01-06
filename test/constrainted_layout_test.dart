import 'package:constrained_layout/src/widget.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  testWidgets('renders unconstrained item', (tester) async {
    final widget = ConstrainedLayout(
      items: [
        testItem(
          id: 1,
          width: 500,
          height: 500,
        ),
      ],
    );

    await tester.setScreenSize(1000, 1000);
    await tester.pumpWidget(widget);

    expect(
      find.constrainedItem(id: 1, x: 0, y: 0, w: 500, h: 500),
      findsOneWidget,
    );
  });

  testWidgets('renders centered item', (tester) async {
    final widget = ConstrainedLayout(
      items: [
        testItem(
          id: 1,
          top: parent(),
          bottom: parent(),
          left: parent(),
          right: parent(),
          width: 500,
          height: 500,
        ),
      ],
    );

    await tester.setScreenSize(1000, 1000);
    await tester.pumpWidget(widget);

    expect(
      find.constrainedItem(id: 1, x: 250, y: 250, w: 500, h: 500),
      findsOneWidget,
    );
  });

  testWidgets('renders items with simple unidirectional constraints',
      (tester) async {
    final widget = ConstrainedLayout(
      items: [
        testItem(
          id: 1,
          top: parent(),
          bottom: parent(),
          left: parent(),
          right: parent(),
          width: 200,
          height: 200,
        ),
        testItem(
          id: 2,
          top: parent(),
          bottom: item(1, top),
          left: parent(),
          right: item(1, left),
          width: 60,
          height: 80,
        ),
        testItem(
          id: 3,
          top: parent(),
          bottom: item(1, top),
          left: item(2, right),
          right: parent(),
          width: 40,
          height: 20,
        ),
      ],
    );

    await tester.setScreenSize(1000, 1000);
    await tester.pumpWidget(widget);

    expect(
      find.constrainedItem(id: 1, x: 400, y: 400, w: 200, h: 200),
      findsOneWidget,
    );
    expect(
      find.constrainedItem(id: 2, x: 170, y: 160, w: 60, h: 80),
      findsOneWidget,
    );
    expect(
      find.constrainedItem(id: 3, x: 595, y: 190, w: 40, h: 20),
      findsOneWidget,
    );
  });
}
