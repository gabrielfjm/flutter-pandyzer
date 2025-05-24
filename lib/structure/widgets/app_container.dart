import 'package:flutter/material.dart';

/// Gera um Container com estilo padrão.
Widget appContainer({
  required Widget child,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? margin,
  double? width,
  double? height,
  BoxDecoration? decoration,
  AlignmentGeometry? alignment,
  Color? color,
}) {
  return Container(
    padding: padding,
    margin: margin,
    width: width,
    height: height,
    alignment: alignment,
    decoration: decoration,
    color: color,
    child: child,
  );
}
