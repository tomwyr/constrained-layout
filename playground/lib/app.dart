import 'package:flutter/material.dart';

import 'playground/playground.dart';

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

class AppColors {
  static const canvas = Color(0xfff8f8ff);
  static const accent = Color(0xffffb05f);
}
