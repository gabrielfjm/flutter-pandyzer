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

  /// Antes: sempre usava onPerform (iniciar/continuar)
  /// Agora: quando [showJoinButton] == true mostramos “Ingressar”
  final VoidCallback onPerform;
  final VoidCallback? onJoin;

  // compat antigo
  final bool isCurrentUserAnEvaluator;
  final bool currentUserHasStarted;

  /// NOVO: mostrar botão “Ingressar” (quando avaliador logado
  /// não faz parte de uma avaliação pública com vagas)
  final bool showJoinButton;

  const AvaliacaoCard({
    super.key,
    required this.evaluation,
    required this.isOwner,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onPerform,
    required this.isCurrentUserAnEvaluator,
    required this.currentUserHasStarted,
    this.showJoinButton = false,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final status = _computeStatus(evaluation);
    final start = AppConvert.convertIsoDateToFormattedDate(evaluation.startDate);
    final end   = AppConvert.convertIsoDateToFormattedDate(evaluation.finalDate);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.normal),
      padding: const EdgeInsets.all(AppSpacing.big),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey800, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // título + chips
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: appText(
                  text: evaluation.description ?? AppStrings.descricaoDaAvaliacao,
                  fontSize: AppFontSize.fs18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(text: status.label, color: status.color),
                  if (evaluation.isPublic)
                    const _Pill(icon: AppIcons.public, label: 'Pública')
                  else
                    const _Pill(icon: Icons.lock_outline, label: 'Privada'),
                  if (evaluation.isPublic && (evaluation.evaluatorsLimit ?? 0) > 0)
                    _Pill(icon: AppIcons.users, label: 'Limite ${evaluation.evaluatorsLimit}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // infos
          Row(
            children: [
              _IconText(icon: AppIcons.calendar, text: 'Início: $start'),
              const SizedBox(width: 20),
              _IconText(icon: AppIcons.calendar, text: 'Entrega: $end'),
              const Spacer(),
              _IconText(icon: AppIcons.person, text: evaluation.user?.name ?? AppStrings.nomeDoUsuario),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 24),

          // ações
          Row(
            children: [
              if (showJoinButton)
                _FilledAction(
                  label: 'Ingressar',
                  icon: Icons.person_add_alt_1,
                  onPressed: onJoin, // pode ser null => disabled
                )
              else if (isCurrentUserAnEvaluator)
                _ActionButton(
                  tooltip: currentUserHasStarted ? 'Continuar' : 'Iniciar',
                  icon: currentUserHasStarted ? Icons.playlist_add_check : Icons.play_circle_outline,
                  onPressed: onPerform,
                ),
              _ActionButton(tooltip: 'Detalhes', icon: AppIcons.view, onPressed: onView),
              if (isOwner) ...[
                _ActionButton(tooltip: 'Editar', icon: AppIcons.edit, onPressed: onEdit),
                _ActionButton(tooltip: 'Excluir', icon: AppIcons.delete, onPressed: onDelete, color: AppColors.red300),
              ],
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------- helpers visuais -----------------
  /// Calcula o status geral da avaliação a partir dos contadores
  /// preenchidos no BLoC:
  /// - totalEvaluatorsCount
  /// - notStartedEvaluationsCount (status “Não iniciada”)
  /// - completedEvaluationsCount  (status “Concluída”)
  StatusInfo _computeStatus(Evaluation e) {
    final int total       = e.totalEvaluatorsCount ?? 0;
    final int notStarted  = e.notStartedEvaluationsCount ?? 0;
    final int completed   = e.completedEvaluationsCount ?? 0;

    if (total == 0 || notStarted == total) {
      // Ninguém começou (ou sem avaliadores)
      return StatusInfo('Não iniciada', AppColors.grey600);
    }
    if (completed == total) {
      // Todos concluíram
      return StatusInfo('Concluido', AppColors.green);
    }
    // Qualquer mistura restante significa que alguém começou e ainda faltam pessoas
    return StatusInfo('Em andamento', AppColors.primary);
  }
}

class StatusInfo { final String label; final Color color; StatusInfo(this.label, this.color); }

class _Pill extends StatelessWidget {
  final IconData icon; final String label;
  const _Pill({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppColors.white, size: 14),
        const SizedBox(width: 6),
        appText(text: label, color: AppColors.white, fontSize: AppFontSize.fs12, fontWeight: FontWeight.w600),
      ]),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text; final Color color;
  const _StatusChip({required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1),
      ),
      child: appText(text: text, color: Colors.white, fontWeight: FontWeight.w700, fontSize: AppFontSize.fs12),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon; final String text;
  const _IconText({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppColors.white, size: 16),
      const SizedBox(width: 8),
      appText(text: text, fontSize: AppFontSize.fs14, color: AppColors.white),
    ]);
  }
}

class _ActionButton extends StatelessWidget {
  final String tooltip; final IconData icon; final VoidCallback onPressed; final Color? color;
  const _ActionButton({required this.tooltip, required this.icon, required this.onPressed, this.color});
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24, width: 1)),
          child: Icon(icon, color: color ?? AppColors.white, size: 18),
        ),
      ),
    );
  }
}

/// Botão primário preenchido (para "Ingressar")
class _FilledAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  const _FilledAction({required this.label, required this.icon, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? AppColors.grey700 : AppColors.black,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
