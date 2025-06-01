import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final double? height;
  final double? width;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 820,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(
            text: label,
            color: AppColors.black,
            fontSize: AppFontSize.fs15,
            fontWeight: FontWeight.bold,
          ),
          appSizedBox(height: AppSpacing.small),
          DropdownButtonFormField2<T>(
            isExpanded: true,
            value: value,
            items: items
                .map((e) => DropdownMenuItem<T>(
              value: e,
              child: Text(
                e.toString(),
                style: TextStyle(fontSize: AppFontSize.fs15),
              ),
            ))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.s10),
                borderSide: BorderSide(color: AppColors.black),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
              offset: const Offset(0, 0),
              isOverButton: false,
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }
}
