import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:intl/intl.dart';
import 'app_sized_box.dart';
import 'app_text.dart';

class AppDatePickerField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final double? height;
  final double? width;

  const AppDatePickerField({super.key, required this.label, required this.controller, this.height, this.width});

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
          TextField(
            style: TextStyle(
              color: AppColors.black,
              fontSize: AppFontSize.fs15,
            ),
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.black, width: 1),
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.black, width: 1),
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
              hint: appText(
                text: label,
                fontSize: AppFontSize.fs15,
                color: AppColors.grey800,
              ),
              focusColor: AppColors.black,
              suffixIcon: const Icon(AppIcons.calendar),
            ),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(DateTime.now().year),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                controller.text = DateFormat('dd/MM/yyyy').format(picked);
              }
            },
          ),
        ],
      ),
    );
  }
}
