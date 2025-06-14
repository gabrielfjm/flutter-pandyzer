import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final double? height;
  final double? width;
  final bool? obscureText;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.height,
    this.width,
    this.obscureText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 75,
      width: width ?? 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(text: label, color: AppColors.black, fontSize: AppFontSize.fs15, fontWeight: FontWeight.bold),
          appSizedBox(height: AppSpacing.small),
          TextFormField(
            controller: controller,
            initialValue: controller == null ? initialValue : null,
            enabled: enabled,
            obscureText: obscureText ?? false,
            style: TextStyle(
              fontSize: AppFontSize.fs15,
              color: enabled ? AppColors.black : AppColors.grey700,
            ),
            decoration: InputDecoration(
              filled: !enabled,
              fillColor: AppColors.grey200,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.black, width: 1),
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.black, width: 1),
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey300, width: 1),
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
              hintText: label,
              hintStyle: TextStyle(color: AppColors.grey800),
            ),
          ),
        ],
      ),
    );
  }
}