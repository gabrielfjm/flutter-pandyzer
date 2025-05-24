import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final double size;
  final double diameter;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool? border;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.size = 20.0,
    this.diameter = 40.0,
    this.padding = const EdgeInsets.all(8),
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.transparent,
        shape: BoxShape.circle,
        border: border == true
            ? Border.all(
          color: AppColors.grey800,
          width: 1,
        )
            : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? AppColors.white,
          size: size,
        ),
        padding: padding,
        splashRadius: diameter / 2,
      ),
    );
  }
}
