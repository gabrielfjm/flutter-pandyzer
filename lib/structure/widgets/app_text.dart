import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';

/// Gera um Text com estilo padrão da aplicação.
Widget appText({
  required String text,
  double? fontSize,
  FontWeight fontWeight = FontWeight.normal,
  Color? color,
  int? maxLines,
  TextOverflow? overflow,
  TextAlign? textAlign,
}) {
  return Text(
    text,
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
    style: TextStyle(
      fontSize: fontSize ?? 20,
      fontWeight: fontWeight,
      color: color ?? AppColors.black,
    ),
  );
}
