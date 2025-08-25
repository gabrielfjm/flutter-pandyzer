import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';

/// Exibe uma notificação customizada no canto inferior direito da tela com animação de fade.
void showAppToast({
  required BuildContext context,
  required String message,
  bool isError = false,
  Duration duration = const Duration(seconds: 5),
}) {
  OverlayEntry? overlayEntry;

  // Chave para acessar o estado do nosso widget de toast e chamar a animação de saída.
  final GlobalKey<_CustomToastWidgetState> toastKey = GlobalKey();

  // Função para remover o toast da tela, chamada após a animação de fade out.
  void removeToast() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 20.0,
      right: 20.0,
      child: _CustomToastWidget(
        key: toastKey, // Passa a chave para o widget
        message: message,
        isError: isError,
        onClose: removeToast,
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry!);

  // Agenda o início da animação de fade out.
  Timer(duration, () {
    toastKey.currentState?.close();
  });
}

/// O widget interno que representa o toast, com animação de fade.
class _CustomToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onClose;

  const _CustomToastWidget({
    super.key,
    required this.message,
    required this.isError,
    required this.onClose,
  });

  @override
  State<_CustomToastWidget> createState() => _CustomToastWidgetState();
}

class _CustomToastWidgetState extends State<_CustomToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400), // Duração do fade
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    // Inicia a animação de fade in
    _controller.forward();
  }

  /// Inicia a animação de fade out e remove o widget da tela ao concluir.
  void close() {
    _controller.reverse().whenComplete(() {
      widget.onClose();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.isError ? AppColors.red100 : AppColors.green100;
    final Color iconColor = widget.isError ? AppColors.red : AppColors.green;
    final IconData icon = widget.isError ? Icons.error_outline : Icons.check_circle_outline;

    // --- ALTERAÇÃO PRINCIPAL AQUI ---
    // Envolve o widget com FadeTransition em vez de SlideTransition
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 350,
          constraints: const BoxConstraints(minHeight: 60),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSizes.s10),
            border: Border.all(color: iconColor.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: AppFontSize.fs15,
                    color: AppColors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.close, size: 18, color: AppColors.grey700),
                onPressed: close, // O botão de fechar também chama a animação de saída
              ),
            ],
          ),
        ),
      ),
    );
  }
}