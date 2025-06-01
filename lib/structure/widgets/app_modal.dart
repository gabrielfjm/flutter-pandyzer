import 'package:flutter/material.dart';

class AppModal extends StatelessWidget {
  final Widget child;
  final String title;

  const AppModal({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: child,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
      ],
    );
  }
}
