import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_convert.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';

class AvaliacaoCard extends StatelessWidget {
  final Evaluation evaluation;
  final VoidCallback onPerform;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AvaliacaoCard({
    super.key,
    required this.evaluation,
    required this.onPerform,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.normal),
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(AppSizes.s15),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(
            text: evaluation.description ?? AppStrings.descricaoDaAvaliacao,
            fontSize: AppFontSize.fs18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
          const SizedBox(height: AppSizes.s10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              appText(
                text: 'Data de Início: ${AppConvert.convertIsoDateToFormattedDate(evaluation.startDate)}',
                fontSize: AppFontSize.fs14,
                color: AppColors.white,
              ),
              appText(
                text: 'Data de Entrega: ${AppConvert.convertIsoDateToFormattedDate(evaluation.finalDate)}',
                fontSize: AppFontSize.fs14,
                color: AppColors.white,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(AppIcons.person, color: AppColors.white),
                  const SizedBox(width: AppSizes.s10),
                  appText(
                    text: evaluation.user?.name ?? AppStrings.nomeDoUsuario,
                    fontSize: AppFontSize.fs14,
                    color: AppColors.white,
                  ),
                ],
              ),
              Row(
                children: [
                  appText(
                    //text: evaluation.status?.description ?? AppStrings.status,
                    text: 'Qtd. Avaliações: 0',
                    fontSize: AppFontSize.fs14,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: AppSizes.s10),
                  IconButton(
                    tooltip: 'Realizar Avaliação',
                    icon: Icon(AppIcons.add, color: AppColors.white), // Exemplo de ícone
                    onPressed: onPerform,
                  ),
                  IconButton(
                    tooltip: 'Visualizar Avaliação',
                    icon: Icon(AppIcons.view, color: AppColors.white),
                    onPressed: onView,
                  ),
                  IconButton(
                    tooltip: 'Editar Avaliação',
                    icon: Icon(AppIcons.edit, color: AppColors.white),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: 'Excluir Avaliação',
                    icon: Icon(AppIcons.delete, color: AppColors.red300),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
