import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';

class AppLoading extends StatelessWidget {
  final Color? color;
  final double size;

  const AppLoading({
    super.key,
    this.color,
    this.size = AppSizes.s24,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color ?? AppColors.white,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
