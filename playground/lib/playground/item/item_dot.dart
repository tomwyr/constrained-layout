import 'package:flutter/material.dart';

import '../../app.dart';
import '../../common/hover_region.dart';

class ItemLinkDot extends StatelessWidget {
  const ItemLinkDot({
    super.key,
    required this.enabled,
    this.size = 8,
    this.onTap,
    this.onHover,
  });

  final bool enabled;
  final double size;
  final VoidCallback? onTap;
  final void Function(bool hovered)? onHover;

  @override
  Widget build(BuildContext context) {
    return HoverRegion(
      onChange: onHover,
      builder: (hovered) => TweenAnimationBuilder(
        duration: const Duration(milliseconds: 100),
        tween: _scaleTween(hovered),
        builder: (context, scale, child) => GestureDetector(
          onTap: onTap,
          child: Dot(
            enabled: enabled,
            size: size,
            scale: scale,
          ),
        ),
      ),
    );
  }

  Tween<double> _scaleTween(bool hovered) {
    return Tween(begin: 1, end: enabled && hovered ? 1.5 : 1);
  }
}

class Dot extends StatelessWidget {
  const Dot({
    super.key,
    required this.enabled,
    this.size = 8,
    this.scale = 1,
  });

  final bool enabled;
  final double size;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * scale,
      height: size * scale,
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: enabled ? AppColors.accent : Colors.grey,
      ),
    );
  }
}
