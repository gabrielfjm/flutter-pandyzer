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
  final Set<String> _hovered = {};

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
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    widget.onAdd(text);
                    _controller.clear();
                  }
                },
              )
            ],
          ),
          appSizedBox(height: AppSpacing.medium),
          SizedBox(
            height: 140,
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: widget.objectives.length,
                itemBuilder: (context, index) {
                  final text = widget.objectives[index];
                  final isHovered = _hovered.contains(text);

                  return MouseRegion(
                    onEnter: (_) => setState(() => _hovered.add(text)),
                    onExit: (_) => setState(() => _hovered.remove(text)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(text)),
                          if (isHovered)
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => widget.onRemove(text),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.delete, size: 18),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
