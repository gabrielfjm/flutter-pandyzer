import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';

import 'app_sized_box.dart';
import 'app_text.dart';

class AppObjectivesField extends StatefulWidget {
  final List<String> objectives;
  final Function(String) onAdd;
  final Function(String) onRemove;
  final double? width;

  const AppObjectivesField({
    super.key,
    required this.objectives,
    required this.onAdd,
    required this.onRemove,
    this.width,
  });

  @override
  State<AppObjectivesField> createState() => _AppObjectivesFieldState();
}

class _AppObjectivesFieldState extends State<AppObjectivesField> {
  final TextEditingController _controller = TextEditingController();
  String? _hoveredObjective;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 820,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(
            text: AppStrings.objetivos,
            color: AppColors.black,
            fontSize: AppFontSize.fs15,
            fontWeight: FontWeight.bold,
          ),
          appSizedBox(height: AppSpacing.small),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.black),
                      borderRadius: BorderRadius.circular(AppSizes.s10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.black),
                      borderRadius: BorderRadius.circular(AppSizes.s10),
                    ),
                    hint: appText(
                      text: AppStrings.objetivos,
                      fontSize: AppFontSize.fs15,
                      color: AppColors.grey800,
                    ),
                    focusColor: AppColors.black,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    widget.onAdd(_controller.text);
                    _controller.clear();
                  }
                },
              )
            ],
          ),
          appSizedBox(height: AppSpacing.medium),
          ...widget.objectives.map((e) {
            return MouseRegion(
              onEnter: (_) => setState(() => _hoveredObjective = e),
              onExit: (_) => setState(() => _hoveredObjective = null),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.medium),
                margin: const EdgeInsets.only(bottom: AppSpacing.small),
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(AppSizes.s10),
                  border: Border.all(color: AppColors.grey500),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        e,
                        style: const TextStyle(fontSize: AppFontSize.fs15),
                      ),
                    ),
                    if (_hoveredObjective == e)
                      GestureDetector(
                        onTap: () => widget.onRemove(e),
                        child: const Padding(
                          padding: EdgeInsets.only(left: AppSpacing.small),
                          child: Icon(Icons.delete, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
