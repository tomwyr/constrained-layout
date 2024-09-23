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
            child: Container(key: const Key('1'), width: 50, height: 50, color: Colors.red),
          ),
          ConstrainedItem(
            child: Container(key: const Key('2'), width: 80, height: 20, color: Colors.green),
          ),
          ConstrainedItem(
            child: Container(key: const Key('3'), width: 40, height: 60, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
