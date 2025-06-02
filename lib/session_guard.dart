import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionGuard extends StatelessWidget {
  final Widget child;

  const SessionGuard({super.key, required this.child});

  Future<bool> _hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSession(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.data!) {
          return const LoginPage();
        }

        return child;
      },
    );
  }
}
