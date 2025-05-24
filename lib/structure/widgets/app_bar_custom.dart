import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'app_container.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> actions;

  const AppBarCustom({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey900,
      child: appContainer(
        height: kToolbarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Row(
          children: actions,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
