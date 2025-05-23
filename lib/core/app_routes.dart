import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/structure/pages/home/home_page.dart';

class AppRoutes {
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomePage(),
  };
}
