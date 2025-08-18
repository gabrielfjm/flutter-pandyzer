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
    // ALTERADO: O destaque agora considera o hover OU a seleção vinda do pai
    final bool highlighted = _isHovering || widget.isHighlighted;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 280,
        transform: Matrix4.identity()..scale(highlighted ? 1.05 : 1.0),
        transformAlignment: FractionalOffset.center,
        decoration: BoxDecoration(
          color: highlighted ? AppColors.grey200 : AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.s10),
          border: Border.all(color: AppColors.grey600),
          boxShadow: [
            BoxShadow(
              color: highlighted
                  ? AppColors.grey600.withValues(alpha: 0.7)
                  : AppColors.grey400.withValues(alpha: 0.5),
              spreadRadius: highlighted ? 2 : 1,
              blurRadius: highlighted ? 5 : 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  appText(
                    text: widget.title,
                    fontSize: AppFontSize.fs16,
                    color: AppColors.grey900,
                    fontWeight: FontWeight.w600,
                  ),
                  Icon(widget.icon, color: widget.iconColor, size: 28),
                ],
              ),
              const SizedBox(height: AppSpacing.big),
              appText(
                text: widget.value,
                fontSize: AppFontSize.fs36,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}