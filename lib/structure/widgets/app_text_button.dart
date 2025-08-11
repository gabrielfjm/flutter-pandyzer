import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'app_text.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final double fontSize;
  final double padding;
  final Color? backgroundColor;
  final bool? border;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final IconData? icon;
  final double iconSize;
  final double? width;
  final double? height;

  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.fontSize = AppFontSize.fs17,
    this.padding = AppSpacing.medium,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.borderColor,
    this.icon,
    this.iconSize = AppFontSize.fs17,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? AppSizes.s50,
      width: width ?? AppSizes.s100,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.black,
        borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.normal),
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
          padding: EdgeInsets.all(padding),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            appText(
              text: text,
              color: textColor ?? AppColors.white,
              fontSize: fontSize,
              overflow: TextOverflow.ellipsis,
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: iconSize, color: textColor ?? AppColors.white),
            ],
          ],
        ),
      ),
    );
  }
}
