import 'package:flutter/material.dart';

class AppTextButtonAppBar extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final double fontSize;
  final double minWidth;
  final EdgeInsetsGeometry padding;

  const AppTextButtonAppBar({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.fontSize = 16,
    this.minWidth = 80,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: padding,
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
