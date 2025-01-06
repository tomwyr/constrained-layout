import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const top = Edge.top;
const bottom = Edge.bottom;
const left = Edge.left;
const right = Edge.right;

Constraint parent() => LinkToParent();
Constraint item(int id, Edge edge) => LinkTo(id: id, edge: edge);

ConstrainedItem<int> testItem({
  required int id,
  Constraint? top,
  Constraint? bottom,
  Constraint? left,
  Constraint? right,
  double? width,
  double? height,
}) {
  return ConstrainedItem(
    id: id,
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    child: SizedBox(
      width: width ?? 100,
      height: height ?? 100,
    ),
  );
}

extension WidgetTesterExtensions on WidgetTester {
  Future<void> setScreenSize(double width, double height) async {
    binding.setSurfaceSize(Size(width, height));
    addTearDown(() => binding.setSurfaceSize(null));
  }
}

extension CommonFindersExtensions on CommonFinders {
  Finder constrainedItem<IdType>({
    required IdType id,
    double? x,
    double? y,
    double? w,
    double? h,
  }) {
    return find.byElementPredicate((element) {
      final widget = element.widget;
      if (widget is! LayoutId || widget.id != id) {
        return false;
      }

      final box = element.renderObject as RenderBox;
      final offset = box.localToGlobal(Offset.zero);
      final size = box.size;

      if (x != null && offset.dx != x) {
        return false;
      }
      if (y != null && offset.dy != y) {
        return false;
      }
      if (w != null && size.width != w) {
        return false;
      }
      if (h != null && size.height != h) {
        return false;
      }

      return true;
    });
  }
}
