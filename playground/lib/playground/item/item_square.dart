import 'dart:math';

import 'package:flutter/material.dart';

import '../../common/hover_region.dart';

class ItemSquare extends StatelessWidget {
  const ItemSquare({
    super.key,
    required this.colorId,
    this.size = 50,
    this.opacity = 1,
    this.onHover,
    this.child,
  });

  final Object colorId;
  final double size;
  final double opacity;
  final void Function(bool hovered)? onHover;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return HoverRegion(
      onChange: onHover,
      builder: (hovered) => SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            color: ItemColors.instance
                .colorForId(colorId)
                .withValues(alpha: opacity),
          ),
          child: child,
        ),
      ),
    );
  }
}

class ItemColors {
  static final instance = ItemColors();

  final _random = Random();
  final _colorsById = <dynamic, Color>{};

  Color colorForId(dynamic id) => _colorsById.putIfAbsent(id, _randomizeColor);

  Color _randomizeColor() {
    final hue = _random.nextDouble() * 360;
    final saturation = 0.5 + _random.nextDouble() * 0.5;
    final brightness = 0.7 + _random.nextDouble() * 0.3;
    return HSVColor.fromAHSV(1.0, hue, saturation, brightness).toColor();
  }
}
