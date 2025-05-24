import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';

class AppError extends StatelessWidget {
  final String message;
  final double fontSize;
  final Color color;

  const AppError({
    super.key,
    required this.message,
    this.fontSize = AppFontSize.fs17,
    this.color = AppColors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: appText(
        text: message,
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}
