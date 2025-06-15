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
  final ValueChanged<T?>? onChanged;
  final double? height;
  final double? width;
  final String Function(T)? itemLabelBuilder;
  final bool enabled;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.height,
    this.width,
    this.itemLabelBuilder,
    this.enabled = true,
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
                itemLabelBuilder != null ? itemLabelBuilder!(e) : e.toString(),
                style: const TextStyle(fontSize: AppFontSize.fs15),
              ),
            ))
                .toList(),
            onChanged: enabled ? onChanged : null, // 5. Desabilita a ação se 'enabled' for false
            decoration: InputDecoration(
              filled: !enabled, // 6. Preenche com cor de fundo quando desabilitado
              fillColor: AppColors.grey200,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.s10),
                borderSide: const BorderSide(color: AppColors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.s10),
                borderSide: BorderSide(color: AppColors.grey500),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.s10),
                borderSide: BorderSide(color: AppColors.grey300),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
            ),
            buttonStyleData: ButtonStyleData(
              padding: const EdgeInsets.only(right: 8),
              height: height ?? 48,
            ),
          ),
        ],
      ),
    );
  }
}