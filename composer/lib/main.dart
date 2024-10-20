import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'composer.dart';

void main() {
  setWindowTitle();
  runApp(const App());
}

void setWindowTitle() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow(
    const WindowOptions(title: 'Constrained Layout'),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Constrained Layout',
      home: Material(
        child: Composer(),
      ),
    );
  }
}
