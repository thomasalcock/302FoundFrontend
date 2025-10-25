import 'package:flutter/material.dart';
import 'package:threeotwo_found_frontend/menu.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text('Welcome to Flutter!'),
              const Text('Hello World!'),
              const Menu(),
              FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.wifi),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
