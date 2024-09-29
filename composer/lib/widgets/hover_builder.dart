import 'package:flutter/material.dart';

typedef HoverBuilder = Widget Function(bool hovered);

class HoverRegion extends StatefulWidget {
  const HoverRegion({
    super.key,
    this.onChange,
    required this.builder,
  }) : _rebuildOnChange = true;

  HoverRegion.listener({
    super.key,
    required this.onChange,
    required Widget child,
  })  : builder = _buildChild(child),
        _rebuildOnChange = false;

  static HoverBuilder _buildChild(Widget child) {
    return (_) => child;
  }

  final ValueChanged<bool>? onChange;
  final HoverBuilder builder;

  final bool _rebuildOnChange;

  @override
  State<HoverRegion> createState() => _HoverRegionState();
}

class _HoverRegionState extends State<HoverRegion> {
  var hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onChange(true),
      onExit: (_) => onChange(false),
      child: widget.builder(hovered),
    );
  }

  void onChange(bool value) {
    hovered = value;
    widget.onChange?.call(value);
    if (widget._rebuildOnChange) {
      setState(() {});
    }
  }
}
