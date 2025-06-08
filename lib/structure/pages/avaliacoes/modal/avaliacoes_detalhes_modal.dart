import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_convert.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';

class AvaliacoesDetalhesModal extends StatelessWidget {
  final Evaluation evaluation;
  final List<Objective> objectives;
  final List<Evaluator> evaluators;

  const AvaliacoesDetalhesModal({
    super.key,
    required this.evaluation,
    required this.objectives,
    required this.evaluators,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.big),
      title: Container(
        padding: const EdgeInsets.all(AppSpacing.big),
        decoration: BoxDecoration(
          color: AppColors.grey900,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: appText(
                text: evaluation.description ?? 'Detalhes da Avaliação',
                color: AppColors.white,
                fontSize: AppFontSize.fs20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5, // 50% da largura da tela
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.big),
              _buildSectionTitle('Detalhes Gerais'),
              _buildDetailRow('Link da Interface:', evaluation.link ?? '-'),
              _buildDetailRow('Data de Início:', AppConvert.convertIsoDateToFormattedDate(evaluation.startDate)),
              _buildDetailRow('Data Final:', AppConvert.convertIsoDateToFormattedDate(evaluation.finalDate)),
              _buildDetailRow('Domínio:', evaluation.applicationType?.description ?? '-'),
              const Divider(height: AppSpacing.big * 2),
              _buildSectionTitle('Objetivos'),
              ...objectives.map((obj) => _buildListItem(obj.description ?? '-', AppIcons.check)),
              if (objectives.isEmpty) appText(text: 'Nenhum objetivo cadastrado.'),
              const Divider(height: AppSpacing.big * 2),
              _buildSectionTitle('Avaliadores'),
              ...evaluators.map((ev) => _buildListItem(ev.user?.name ?? '-', AppIcons.person)),
              if (evaluators.isEmpty) appText(text: 'Nenhum avaliador atribuído.'),
              const SizedBox(height: AppSpacing.big),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.normal),
      child: appText(
        text: title,
        fontSize: AppFontSize.fs18,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: appText(text: label, fontWeight: FontWeight.bold),
          ),
          Expanded(
            flex: 5,
            child: appText(text: value, color: AppColors.grey800),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String text, IconData icon) {
    return Card(
      elevation: 0,
      color: AppColors.grey200,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: ListTile(
        leading: Icon(icon, color: AppColors.grey800),
        title: Text(text),
      ),
    );
  }
}