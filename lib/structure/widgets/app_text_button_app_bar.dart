import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';

class AppTextButtonAppBar extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final double fontSize;
  final double minWidth;
  final double padding;

  const AppTextButtonAppBar({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.fontSize = AppFontSize.fs17,
    this.minWidth = 80,
    this.padding = AppSpacing.big,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(padding),
          minimumSize: Size(minWidth, kToolbarHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
