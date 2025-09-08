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

  // espaçamento consistente entre itens
  List<Widget> _spaced(List<Widget> items, double gap) {
    if (items.isEmpty) return items;
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) out.add(SizedBox(width: gap));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.grey900,
              AppColors.grey900.withValues(alpha: 0.95),
              AppColors.grey800.withValues(alpha: 0.92),
            ],
          ),
          border: Border(
            bottom: BorderSide(color: AppColors.grey800, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: appContainer(
            height: kToolbarHeight + 2,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ——— esquerda: logo + navegação
                Row(
                  children: _spaced([
                    Padding(
                      padding: const EdgeInsets.only(left: 6, right: 18),
                      child: Image.asset(
                        'assets/images/logo_app_bar.png',
                        height: kToolbarHeight - 12,
                        fit: BoxFit.contain,
                      ),
                    ),
                    ...leading,
                  ], 18),
                ),

                // ——— direita: apenas Row com ações (sem pill)
                Row(
                  children: _spaced(actions, 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
