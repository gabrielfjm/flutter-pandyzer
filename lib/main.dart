// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_page.dart';
import 'package:flutter_pandyzer/structure/pages/main_page.dart';
import 'package:flutter_pandyzer/core/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PandyzerApp());
}

class PandyzerApp extends StatelessWidget {
  const PandyzerApp({super.key});

  Future<bool> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pandyzer',
      theme: AppTheme.lightTheme,
      home: FutureBuilder<bool>(
        future: _checkSession(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return snapshot.data! ? const MainPage() : const LoginPage();
        },
      ),
    );
  }
}
