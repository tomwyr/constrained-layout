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
            top: LinkToParent(),
            bottom: LinkToParent(),
            left: LinkToParent(),
            right: LinkToParent(),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.red,
            ),
          ),
          ConstrainedItem(
            id: 'green',
            top: LinkToParent(),
            bottom: LinkTo(id: 'red', edge: Edge.top),
            left: LinkToParent(),
            child: Container(
              width: 80,
              height: 20,
              color: Colors.green,
            ),
          ),
          ConstrainedItem(
            id: 'blue',
            top: LinkTo(id: 'green', edge: Edge.top),
            left: LinkTo(id: 'red', edge: Edge.left),
            right: LinkToParent(),
            child: Container(
              width: 40,
              height: 60,
              color: Colors.blue,
            ),
          ),
          ConstrainedItem(
            id: 'orange',
            top: LinkTo(id: 'red', edge: Edge.top),
            bottom: LinkToParent(),
            left: LinkTo(id: 'blue', edge: Edge.right),
            right: LinkToParent(),
            child: Container(
              width: 80,
              height: 50,
              color: Colors.orange,
            ),
          ),
          ConstrainedItem(
            id: 'indigo',
            top: LinkTo(id: 'orange', edge: Edge.bottom),
            bottom: LinkToParent(),
            left: LinkTo(id: 'green', edge: Edge.right),
            right: LinkTo(id: 'green', edge: Edge.right),
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
