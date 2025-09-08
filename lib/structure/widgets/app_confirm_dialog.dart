import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';

class AppConfirmDialog extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String message;
  final String confirmText;
  final VoidCallback onConfirm;
  final Color confirmColor; // ex.: AppColors.black / AppColors.red
  final String cancelText;
  final bool danger; // pinta detalhes em vermelho quando true

  const AppConfirmDialog({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.confirmColor = AppColors.black,
    this.cancelText = 'Cancelar',
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.s12),
        side: const BorderSide(color: AppColors.black, width: 1),
      ),
      elevation: 8,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header preto
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.big),
              decoration: const BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.s12),
                  topRight: Radius.circular(AppSizes.s12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppFontSize.fs18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    splashRadius: 18,
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Corpo
            Padding(
              padding: const EdgeInsets.all(AppSpacing.big),
              child: Text(
                message,
                style: TextStyle(
                  color: danger ? AppColors.red : AppColors.grey900,
                  fontSize: AppFontSize.fs15,
                  height: 1.4,
                ),
              ),
            ),

            const Divider(height: 1),

            // Ações
            Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.black, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.s10),
                        ),
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(color: AppColors.black)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.s10),
                        ),
                      ),
                      child: Text(confirmText),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper para abrir com transição de fade + scale
Future<void> showAppConfirmDialog(BuildContext context, AppConfirmDialog dialog) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: Colors.black.withOpacity(0.35),
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (_, __, ___) => dialog,
    transitionBuilder: (_, anim, __, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.98, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}
