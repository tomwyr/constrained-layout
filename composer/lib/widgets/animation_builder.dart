import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef AnimationValueBuilder = Widget Function(double value);
typedef AnimationListenableBuilder = Widget Function(
  ValueListenable<double> listenable,
);

class AnimationBuilder extends StatefulWidget {
  const AnimationBuilder({
    super.key,
    this.active = true,
    this.looped = true,
    required this.duration,
    this.valueBuilder,
    this.listenableBuilder,
  }) : assert(
          (valueBuilder != null) ^ (listenableBuilder != null),
          'Either value or listenable builder must be provided (but not both)',
        );

  final bool active;
  final bool looped;
  final Duration duration;
  final AnimationValueBuilder? valueBuilder;
  final AnimationListenableBuilder? listenableBuilder;

  @override
  State<AnimationBuilder> createState() => _AnimationBuilderState();
}

class _AnimationBuilderState extends State<AnimationBuilder>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    controller.addStatusListener((status) {
      if (widget.looped && status == AnimationStatus.completed) {
        controller.forward(from: 0);
      }
    });
    if (widget.active) {
      controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimationBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      if (widget.active) {
        controller.forward();
      } else {
        controller.stop();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.valueBuilder case var builder?) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return builder(controller.value);
        },
      );
    }
    if (widget.listenableBuilder case var builder?) {
      return builder(controller);
    }
    throw FlutterError(
      'No builder was provided to the AnimationBuilder widget',
    );
  }
}
