import 'package:flutter/material.dart';
import 'package:threeotwo_found_frontend/trusted_persons_list_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hessentag Fulda 2026',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const LostAndFound(title: 'Hessentag Fulda - Lost and Found'),
    );
  }
}

class LostAndFound extends StatefulWidget {
  const LostAndFound({super.key, required this.title});

  final String title;

  @override
  State<LostAndFound> createState() => _LostAndFoundState();
}

class _LostAndFoundState extends State<LostAndFound> {
  @override
  Widget build(BuildContext context) {
    return TrustedPersonsListView();
  }
}
