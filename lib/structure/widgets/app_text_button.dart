import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/structure/widgets/app_container.dart';
import 'app_text.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool? border;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;

  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.fontSize = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.s100,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.black,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: border == true
            ? Border.all(
          color: borderColor ?? AppColors.white,
          width: 1,
        )
            : null,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
        child: appText(
          text: text,
          color: textColor,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
