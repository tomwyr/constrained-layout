import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ConstrainedLayout(
        items: [
          ConstrainedItem(
            child: Container(
              key: const Key('yellow'),
              width: 20,
              height: 20,
              color: Colors.yellow,
            ),
          ),
          ConstrainedItem(
            top: AttachToParent(),
            bottom: AttachToParent(),
            left: AttachToParent(),
            right: AttachToParent(),
            child: Container(
              key: const Key('red'),
              width: 50,
              height: 50,
              color: Colors.red,
            ),
          ),
          ConstrainedItem(
            top: AttachToParent(),
            bottom: AttachTo(key: const Key('red'), edge: Edge.top),
            left: AttachToParent(),
            child: Container(
              key: const Key('green'),
              width: 80,
              height: 20,
              color: Colors.green,
            ),
          ),
          ConstrainedItem(
            top: AttachTo(key: const Key('green'), edge: Edge.top),
            left: AttachTo(key: const Key('red'), edge: Edge.left),
            right: AttachToParent(),
            child: Container(
              key: const Key('blue'),
              width: 40,
              height: 60,
              color: Colors.blue,
            ),
          ),
          ConstrainedItem(
            top: AttachTo(key: const Key('red'), edge: Edge.top),
            bottom: AttachToParent(),
            left: AttachTo(key: const Key('blue'), edge: Edge.right),
            right: AttachToParent(),
            child: Container(
              key: const Key('orange'),
              width: 80,
              height: 50,
              color: Colors.orange,
            ),
          ),
          ConstrainedItem(
            top: AttachTo(key: const Key('orange'), edge: Edge.bottom),
            bottom: AttachToParent(),
            left: AttachTo(key: const Key('green'), edge: Edge.right),
            right: AttachTo(key: const Key('green'), edge: Edge.right),
            child: Container(
              key: const Key('indigo'),
              width: 30,
              height: 30,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }
}
