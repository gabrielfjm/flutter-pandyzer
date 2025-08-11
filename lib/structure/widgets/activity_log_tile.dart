import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/structure/http/models/ActivityLog.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';

class ActivityLogTile extends StatefulWidget {
  final ActivityLog activity;

  const ActivityLogTile({super.key, required this.activity});

  @override
  State<ActivityLogTile> createState() => _ActivityLogTileState();
}

class _ActivityLogTileState extends State<ActivityLogTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isHovering ? 1.02 : 1.0),
        transformAlignment: FractionalOffset.center,
        color: _isHovering ? AppColors.grey200 : Colors.transparent,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: appText(
              text: widget.activity.userName.substring(0, 2).toUpperCase(),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          title: Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: AppFontSize.fs16,
                color: AppColors.black,
              ),
              children: [
                TextSpan(
                  text: widget.activity.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' ${widget.activity.action} '),
                TextSpan(
                  text: widget.activity.evaluationTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          subtitle: appText(
            text: widget.activity.timestamp,
            color: AppColors.grey800,
          ),
        ),
      ),
    );
  }
}