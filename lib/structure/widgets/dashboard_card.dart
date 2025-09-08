import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';

class DashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isHighlighted;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.black,
    this.isHighlighted = false,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = _isHovering || widget.isHighlighted;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        // ❌ sem width fixa; deixa o pai controlar (Expanded)
        transform: Matrix4.identity()..scale(highlighted ? 1.02 : 1.0),
        transformAlignment: FractionalOffset.center,
        decoration: BoxDecoration(
          color: highlighted ? AppColors.grey200 : AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.s10),
          border: Border.all(color: AppColors.grey600),
          boxShadow: [
            BoxShadow(
              color: (highlighted ? AppColors.grey600 : AppColors.grey400).withValues(alpha: 0.5),
              spreadRadius: highlighted ? 1.5 : 1,
              blurRadius: highlighted ? 6 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: ConstrainedBox(
            // dá um mínimo pra não ficar espremido
            constraints: const BoxConstraints(minHeight: 110, minWidth: 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: appText(
                        text: widget.title,
                        fontSize: AppFontSize.fs16,
                        color: AppColors.grey900,
                        fontWeight: FontWeight.w600,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(widget.icon, color: widget.iconColor, size: 22),
                  ],
                ),
                const SizedBox(height: AppSpacing.big),
                appText(
                  text: widget.value,
                  fontSize: AppFontSize.fs32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
