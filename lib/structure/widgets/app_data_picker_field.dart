
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';

import 'app_sized_box.dart';
import 'app_text.dart';

class AppDatePickerField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final double? height;
  final double? width;

  /// Novo: permite digitação com máscara (ex.: dd/MM/yyyy)
  final List<TextInputFormatter>? inputFormatters;

  /// Novo: tipo de teclado (ex.: TextInputType.number)
  final TextInputType? keyboardType;

  /// Novo: controlar se abre o date picker ao tocar no campo.
  /// Se `false`, o picker abre apenas no toque do ícone de calendário.
  final bool openPickerOnTap;

  /// Datas configuráveis do date picker
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDatePickerField({
    super.key,
    required this.label,
    required this.controller,
    this.height,
    this.width,
    this.inputFormatters,
    this.keyboardType,
    this.openPickerOnTap = true,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  Future<void> _openPicker(BuildContext context) async {
    final fmt = DateFormat('dd/MM/yyyy');
    DateTime initial = initialDate ?? DateTime.now();
    try {
      if (controller.text.isNotEmpty) {
        initial = fmt.parse(controller.text);
      }
    } catch (_) {}

    final DateTime fd = firstDate ?? DateTime(DateTime.now().year);
    final DateTime ld = lastDate ?? DateTime(2100);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: fd,
      lastDate: ld,
    );
    if (picked != null) {
      controller.text = fmt.format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 75,
      width: width ?? 400,
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
          TextField(
            style: TextStyle(
              color: AppColors.black,
              fontSize: AppFontSize.fs15,
            ),
            controller: controller,
            readOnly: !openPickerOnTap ? false : true, // se abre no tap, mantemos readOnly; caso contrário, permite digitar
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
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
              suffixIcon: InkWell(
                onTap: () => _openPicker(context),
                child: const Icon(AppIcons.calendar),
              ),
            ),
            onTap: openPickerOnTap ? () => _openPicker(context) : null,
          ),
        ],
      ),
    );
  }
}
