import 'package:flutter/material.dart';

import 'playground.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Constrained Layout',
      theme: ThemeData(
        canvasColor: Colors.white,
      ),
      home: const Material(
        child: Playground(),
      ),
    );
  }
}
