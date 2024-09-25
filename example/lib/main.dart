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
            id: 'yellow',
            child: Container(
              width: 20,
              height: 20,
              color: Colors.yellow,
            ),
          ),
          ConstrainedItem(
            id: 'red',
            top: AttachToParent(),
            bottom: AttachToParent(),
            left: AttachToParent(),
            right: AttachToParent(),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.red,
            ),
          ),
          ConstrainedItem(
            id: 'green',
            top: AttachToParent(),
            bottom: AttachTo(id: 'red', edge: Edge.top),
            left: AttachToParent(),
            child: Container(
              width: 80,
              height: 20,
              color: Colors.green,
            ),
          ),
          ConstrainedItem(
            id: 'blue',
            top: AttachTo(id: 'green', edge: Edge.top),
            left: AttachTo(id: 'red', edge: Edge.left),
            right: AttachToParent(),
            child: Container(
              width: 40,
              height: 60,
              color: Colors.blue,
            ),
          ),
          ConstrainedItem(
            id: 'orange',
            top: AttachTo(id: 'red', edge: Edge.top),
            bottom: AttachToParent(),
            left: AttachTo(id: 'blue', edge: Edge.right),
            right: AttachToParent(),
            child: Container(
              width: 80,
              height: 50,
              color: Colors.orange,
            ),
          ),
          ConstrainedItem(
            id: 'indigo',
            top: AttachTo(id: 'orange', edge: Edge.bottom),
            bottom: AttachToParent(),
            left: AttachTo(id: 'green', edge: Edge.right),
            right: AttachTo(id: 'green', edge: Edge.right),
            child: Container(
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
