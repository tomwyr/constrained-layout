import 'package:constrained_layout/src/layout_order.dart';
import 'package:constrained_layout/src/widget.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  const layoutOrder = LayoutOrder();

  List<int> orderOf(List<ConstrainedItem<int>> items) {
    return layoutOrder.resolve(items).map((item) => item.id).toList();
  }

  test('resolves layout with no constraints', () {
    final items = [
      testItem(id: 1),
      testItem(id: 2),
      testItem(id: 3),
    ];

    expect(orderOf(items), [1, 2, 3]);
  });

  test('resolves layout with parent constraints', () {
    final items = [
      testItem(
        id: 1,
        top: parent(),
        bottom: parent(),
        left: parent(),
        right: parent(),
      ),
      testItem(
        id: 2,
        top: parent(),
        bottom: parent(),
        left: parent(),
        right: parent(),
      ),
      testItem(
        id: 3,
        top: parent(),
        bottom: parent(),
        left: parent(),
        right: parent(),
      ),
    ];

    expect(orderOf(items), [1, 2, 3]);
  });

  test('resolves layout with simple unidirectional constraints', () {
    final items = [
      testItem(
        id: 1,
        top: parent(),
        bottom: parent(),
        left: parent(),
        right: parent(),
      ),
      testItem(
        id: 2,
        top: item(1, top),
        bottom: item(1, bottom),
        left: item(1, left),
        right: item(1, right),
      ),
      testItem(
        id: 3,
        top: item(2, top),
        bottom: item(2, bottom),
        left: item(1, left),
        right: item(1, right),
      ),
    ];

    expect(orderOf(items), [1, 2, 3]);
  });

  test('resolves layout with complex unidirectional constraints', () {
    final items = [
      testItem(
        id: 1,
        top: parent(),
        bottom: item(3, top),
        right: parent(),
      ),
      testItem(
        id: 2,
        top: item(3, bottom),
        right: item(1, left),
      ),
      testItem(
        id: 3,
        top: parent(),
        bottom: parent(),
        left: parent(),
        right: parent(),
      ),
      testItem(
        id: 4,
        top: item(2, top),
        bottom: item(5, bottom),
        left: item(3, left),
        right: item(1, left),
      ),
      testItem(
        id: 5,
        top: item(2, bottom),
        right: item(2, left),
      ),
    ];

    expect(orderOf(items), [3, 1, 2, 5, 4]);
  });

  test('fails to resolve layout with multidirectional constraints', () {
    final items = [
      testItem(
        id: 1,
        top: parent(),
        bottom: parent(),
        left: item(2, left),
        right: item(3, right),
      ),
      testItem(
        id: 2,
        top: item(1, top),
        bottom: item(1, bottom),
        left: item(1, left),
        right: item(1, right),
      ),
      testItem(
        id: 3,
        top: item(2, top),
        bottom: item(2, bottom),
        left: item(2, left),
        right: item(2, right),
      ),
    ];

    expect(() => orderOf(items), throwsA(isA<UnresolvedLayoutError>()));
  });
}
