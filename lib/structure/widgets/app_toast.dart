import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
/// Exibe um SnackBar (toast) com uma mensagem e cor de fundo baseada no tipo (erro ou sucesso).
///
/// Parâmetros:
///   - `context`: O BuildContext atual, necessário para encontrar o ScaffoldMessenger.
///   - `message`: A mensagem a ser exibida no toast.
///   - `isError`: Booleano que indica se a mensagem é um erro (`true`) ou não (`false`).
///                Determina a cor de fundo do toast (vermelho para erro, verde para sucesso/info).
///   - `duration`: Duração opcional pela qual o SnackBar é exibido. Padrão é 4 segundos.
///   - `textColor`: Cor opcional para o texto da mensagem. Padrão é branco.
void showAppToast({
  required BuildContext context,
  required String message,
  bool isError = false,
  Duration duration = const Duration(seconds: 4),
  Color? textColor, // Adicionado para consistência com appText
}) {
  // Remove qualquer SnackBar que esteja sendo exibido atualmente
  // para evitar o empilhamento de vários toasts.
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  // Determina a cor de fundo com base no parâmetro isError
  final Color backgroundColor = isError
      ? AppColors.red300
      : AppColors.green300;

  final SnackBar snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(
        color: textColor ?? AppColors.white,
        fontSize: AppFontSize.fs15,
      ),
      textAlign: TextAlign.center,
    ),
    backgroundColor: backgroundColor,
    duration: duration,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.s10),
    ),
    margin: EdgeInsets.all(AppSizes.s10),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}