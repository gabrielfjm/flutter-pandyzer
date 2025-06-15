import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_convert.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';

class AvaliacaoCard extends StatelessWidget {
  final Evaluation evaluation;
  final bool isOwner;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPerform;

  const AvaliacaoCard({
    super.key,
    required this.evaluation,
    required this.isOwner,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onPerform,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.normal),
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(15.0),
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
          const SizedBox(height: 10),
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
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(AppIcons.person, color: AppColors.white, size: 18),
                  const SizedBox(width: 10),
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
                    text: 'Concluídas: ${evaluation.completedEvaluationsCount ?? 0}',
                    fontSize: AppFontSize.fs14,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: AppSpacing.normal),
                  // 1. Botão "Realizar Avaliação"
                  if (evaluation.isCurrentUserAnEvaluator)
                    IconButton(
                      tooltip: 'Minha Avaliação',
                      icon: const Icon(Icons.playlist_add_check, color: AppColors.white),
                      onPressed: onPerform,
                    ),

                  // 2. Botão "Visualizar Detalhes" (sempre visível)
                  IconButton(
                    tooltip: 'Visualizar Detalhes',
                    icon: const Icon(AppIcons.view, color: AppColors.white),
                    onPressed: onView,
                  ),

                  // 3. Botões "Editar" e "Excluir" (apenas para o dono)
                  if (isOwner) ...[
                    IconButton(
                      tooltip: 'Editar Avaliação',
                      icon: const Icon(AppIcons.edit, color: AppColors.white),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      tooltip: 'Excluir Avaliação',
                      icon: Icon(AppIcons.delete, color: AppColors.red300),
                      onPressed: onDelete,
                    ),
                  ]
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}