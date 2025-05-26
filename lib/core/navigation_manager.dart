import 'package:flutter/material.dart';

class NavigationManager {
  late void Function(Widget) _navigate;

  static final NavigationManager _instance = NavigationManager._internal();

  factory NavigationManager() => _instance;

  NavigationManager._internal();

  void registerNavigation(void Function(Widget) navigate) {
    _navigate = navigate;
  }

  void goTo(Widget page) {
    _navigate(page);
  }
}
