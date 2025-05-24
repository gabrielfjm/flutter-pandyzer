import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'app_container.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> leading;
  final List<Widget> actions;

  const AppBarCustom({
    super.key,
    required this.leading,
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
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.grey800, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 15.0),
                  child: Image.asset(
                    'assets/images/logo_app_bar.png',
                    width: 50,
                    height: kToolbarHeight-10,
                    fit: BoxFit.fill,
                  ),
                ),
                ...leading,
              ],
            ),
            Row(
              children: actions,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
