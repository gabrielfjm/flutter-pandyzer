import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/structure/pages/main_page.dart';

void main() {
  runApp(const PandyzerApp());
}

class PandyzerApp extends StatelessWidget {
  const PandyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pandyzer',
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}
