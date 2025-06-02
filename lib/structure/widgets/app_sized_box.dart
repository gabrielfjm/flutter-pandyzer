import 'package:flutter/material.dart';

/// Gera um SizedBox com largura e altura.
Widget appSizedBox({
  double? width,
  double? height,
  Widget? child,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: child,
  );
}
