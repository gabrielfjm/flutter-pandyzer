import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';

class AnimatedActionButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final double collapsedWidth;
  final double expandedWidth;

  const AnimatedActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.collapsedWidth = 50.0,
    this.expandedWidth = 170.0,
  });

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _isHovering ? widget.expandedWidth : widget.collapsedWidth,
          height: widget.collapsedWidth,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(widget.collapsedWidth / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                opacity: _isHovering ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeIn,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: appText(
                      text: widget.text,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: _isHovering ? Alignment.centerRight : Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: _isHovering ? 16.0 : 0.0),
                  child: Icon(
                    widget.icon,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}