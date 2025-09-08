// lib/structure/widgets/app_toast.dart
import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';

/// Exibe um toast seguro usando ScaffoldMessenger (sem OverlayEntry).
/// - `isError` muda cor/ícone
/// - `duration` controla por quanto tempo fica visível
/// - Estilo flutuante com margem para parecer um "card" no canto inferior-direito.
void showAppToast({
  required BuildContext context,
  required String message,
  bool isError = false,
  Duration duration = const Duration(seconds: 5),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  // Fecha um snackbar anterior (se houver), para não empilhar
  messenger.clearSnackBars();

  final Color bg = isError ? AppColors.red100 : AppColors.green100;
  final Color iconColor = isError ? AppColors.red : AppColors.green;
  final IconData icon = isError ? Icons.error_outline : Icons.check_circle_outline;

  // Para posicionar mais “à direita”, usamos behavior: floating + margin.
  // A largura será limitada pelo próprio conteúdo; se quiser fixar 350px,
  // envolvemos em um SizedBox.
  final snack = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent, // Deixa transparente p/ mostrarmos nosso card
    elevation: 0,
    duration: duration,
    margin: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
    content: Align(
      alignment: Alignment.bottomRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: iconColor.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: AppFontSize.fs15,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => messenger.hideCurrentSnackBar(),
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.close, size: 18, color: AppColors.grey700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  messenger.showSnackBar(snack);
}
