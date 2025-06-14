import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
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
  final String? defaultLabel;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged, // 2. Remove o 'required'
    this.height,
    this.width,
    this.itemLabelBuilder,
    this.defaultLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onChanged != null;

    return SizedBox(
      height: height ?? 75,
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
          DropdownButtonFormField<T>(
            value: value,
            style: TextStyle(
              color: isEnabled ? AppColors.black : AppColors.grey700,
              fontSize: AppFontSize.fs15,
            ),
            decoration: InputDecoration(
              filled: !isEnabled, // 3. Adiciona um fundo cinza quando desabilitado
              fillColor: AppColors.grey200,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.black, width: 1),
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.black, width: 1),
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
              disabledBorder: OutlineInputBorder( // 4. Estilo da borda quando desabilitado
                borderSide: BorderSide(color: AppColors.grey300, width: 1),
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
              hintText: defaultLabel ?? AppStrings.selecioneUmaOpcao,
              hintStyle: TextStyle(color: AppColors.grey800),
            ),
            hint: appText(
              text: defaultLabel ?? AppStrings.selecioneUmaOpcao,
              color: AppColors.grey800,
              fontSize: AppFontSize.fs15,
            ),
            items: items.map(
                  (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabelBuilder != null
                      ? itemLabelBuilder!(item)
                      : item.toString(),
                ),
              ),
            ).toList(),
            onChanged: onChanged, // 5. Passa o onChanged (que pode ser nulo)
          ),
        ],
      ),
    );
  }
}