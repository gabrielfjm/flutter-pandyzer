import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_routes.dart';
import 'package:flutter_pandyzer/core/app_theme.dart';

void main() {
  runApp(const Pandyzer());
}

class Pandyzer extends StatelessWidget {
  const Pandyzer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pandyzer',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
    );
  }
}
