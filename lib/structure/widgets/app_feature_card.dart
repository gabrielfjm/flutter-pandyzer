import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';

import 'app_text.dart';

Widget appFeatureCard({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Container(
    width: 300,
    padding: const EdgeInsets.all(AppSpacing.medium),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 40, color: AppColors.primary),
        const SizedBox(height: AppSpacing.small),
        appText(
          text: title,
          fontSize: AppFontSize.fs18,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        const SizedBox(height: AppSpacing.small),
        appText(
          text: description,
          fontSize: AppFontSize.fs14,
          color: AppColors.grey900,
        ),
      ],
    ),
  );
}