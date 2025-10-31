import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_convert.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/core/pdf/report_generator_service.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_event.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_repository.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_page.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

import '../../../http/services/avaliacoes_report_service.dart';
import '../../../widgets/app_confirm_dialog.dart';

class AvaliacoesDetalhesModal extends StatefulWidget {
  final AvaliacoesBloc bloc;
  final Evaluation evaluation;
  final List<Objective> objectives; // pode vir vazio
  final List<Evaluator> evaluators;

  const AvaliacoesDetalhesModal({
    super.key,
    required this.bloc,
    required this.evaluation,
    required this.objectives,
    required this.evaluators,
  });

  @override
  State<AvaliacoesDetalhesModal> createState() =>
      _AvaliacoesDetalhesModalState();
}

class _AvaliacoesDetalhesModalState extends State<AvaliacoesDetalhesModal> {
  String? _currentUserId;

  // ---- objetivos & loading ----
  List<Objective> _objectives = [];
  bool _isLoadingObjectives = true;

  // ---- problemas por avaliador ----
  final Map<int, List<Problem>> _problemsByEvaluator = {};
  bool _isLoadingProblems = true;

  // ---- relatório ----
  bool _isGeneratingReport = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _bootstrap(); // objetivos -> problemas
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _currentUserId = prefs.getString('userId'));
  }

  Future<void> _bootstrap() async {
    await _ensureObjectives();
    await _loadProblems();
  }

  /// Garante que `_objectives` esteja populado:
  /// - usa os `widget.objectives` se já vierem preenchidos
  /// - caso contrário busca do backend
  Future<void> _ensureObjectives() async {
    if (widget.objectives.isNotEmpty) {
      setState(() {
        _objectives = widget.objectives;
        _isLoadingObjectives = false;
      });
      return;
    }

    try {
      if (widget.evaluation.id != null) {
        final objs = await AvaliacoesRepository.getObjectivesByEvaluationId(
          widget.evaluation.id!,
        );
        if (!mounted) return;
        setState(() {
          _objectives = objs;
          _isLoadingObjectives = false;
        });
      } else {
        setState(() => _isLoadingObjectives = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingObjectives = false);
    }
  }

  Future<void> _loadProblems() async {
    if (widget.evaluation.id == null) {
      setState(() => _isLoadingProblems = false);
      return;
    }

    final grouped = <int, List<Problem>>{};

    for (final evaluator in widget.evaluators) {
      final evaluatorUserId = evaluator.user?.id;
      if (evaluatorUserId == null) continue;

      final problemsForThisEvaluator = <Problem>[];

      // ⚠️ usar _objectives (não widget.objectives)
      for (final objective in _objectives) {
        final objectiveId = objective.id;
        if (objectiveId == null) continue;

        final problems = await AvaliacoesRepository
            .getProblemsByIdObjetivoAndIdEvaluator(
          objectiveId,
          evaluatorUserId,
        );
        problemsForThisEvaluator.addAll(problems);
      }

      grouped[evaluatorUserId] = problemsForThisEvaluator;
    }

    if (!mounted) return;
    setState(() {
      _problemsByEvaluator
        ..clear()
        ..addAll(grouped);
      _isLoadingProblems = false;
    });
  }

  // ----------------- Helpers de Status / Badges -----------------

  _StatusInfo _statusGeral(Evaluation e) {
    // 1 = Em andamento, 2 = Concluída, 3 = Não iniciada (ajuste se for diferente)
    if (widget.evaluators.isEmpty) {
      return _StatusInfo('Não iniciada', AppColors.grey600);
    }

    final allNotStarted = widget.evaluators.every((ev) => ev.status?.id == 3);
    if (allNotStarted) {
      return _StatusInfo('Não iniciada', AppColors.grey600);
    }

    final allDone = widget.evaluators.isNotEmpty &&
        widget.evaluators.every((ev) => ev.status?.id == 2);
    if (allDone) {
      return _StatusInfo('Concluída', AppColors.green300);
    }

    return _StatusInfo('Em andamento', AppColors.primary);
  }

  Widget _chip(String text, {Color? color, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.white24).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color ?? Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.white),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------- Diálogos -----------------

  void _showStartEvaluationConfirmationDialog(Evaluator evaluator) {
    final evaluatorUserId = evaluator.user?.id;
    if (evaluatorUserId == null || widget.evaluation.id == null) return;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Iniciar Avaliação'),
        content: const Text(
          'Tem certeza que deseja começar esta avaliação? '
              'Após iniciar, o status será alterado para "Em Andamento".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.green300),
            onPressed: () {
              widget.bloc.add(StartEvaluationEvent(
                evaluatorRecordId: evaluator.id!,
                evaluatorUserId: evaluator.user!.id!,
                evaluationId: widget.evaluation.id!,
              ));
              _closeDialogsAndGoToProblems(evaluatorUserId);
            },
            child: const Text('Confirmar e Iniciar'),
          ),
        ],
      ),
    );
  }

  void _closeDialogsAndGoToProblems(int evaluatorUserId) {
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();
    if (nav.canPop()) nav.pop();

    NavigationManager().goTo(
      ProblemaPage(
        evaluationId: widget.evaluation.id!,
        evaluatorId: evaluatorUserId,
        mode: ProblemaPageMode.edit,
      ),
    );

    try {
      widget.bloc.add(LoadAvaliacoesEvent());
    } catch (_) {}
  }

  void _showDeleteEvaluatorConfirmationDialog(Evaluator evaluator) {
    showAppConfirmDialog(
      context,
      AppConfirmDialog(
        icon: Icons.delete_outline,
        iconBg: AppColors.red300,
        title: 'Remover avaliador',
        message:
        'Tem certeza que deseja remover ${evaluator.user?.name} desta avaliação?\n'
            'Todos os problemas reportados por ele serão perdidos.',
        confirmText: 'Remover',
        confirmColor: AppColors.red,
        danger: true,
        onConfirm: () {
          widget.bloc.add(
            DeleteEvaluatorAndProblems(
              evaluatorRecordId: evaluator.id!,
              evaluatorUserId: evaluator.user!.id!,
              evaluationId: widget.evaluation.id!,
            ),
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _handleReportGeneration(
      Future<void> Function() reportFunction) async {
    if (_isGeneratingReport) return;
    setState(() => _isGeneratingReport = true);
    try {
      await reportFunction();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao gerar o relatório: $e"),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingReport = false);
    }
  }

  // ----------------- UI -----------------

  @override
  Widget build(BuildContext context) {
    final status = _statusGeral(widget.evaluation);
    final start =
    AppConvert.convertIsoDateToFormattedDate(widget.evaluation.startDate);
    final end =
    AppConvert.convertIsoDateToFormattedDate(widget.evaluation.finalDate);
    final completedCount =
        widget.evaluators.where((e) => e.status?.id == 2).length;
    final canGenerateConsolidated = completedCount >= 1;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.white,
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(AppSpacing.big),
      title: Container(
        padding: const EdgeInsets.all(AppSpacing.big),
        decoration: const BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appText(
                    text: widget.evaluation.description ?? 'Detalhes da Avaliação',
                    color: AppColors.white,
                    fontSize: AppFontSize.fs20,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(status.label, color: status.color, icon: AppIcons.info),
                      _chip('Início $start', icon: AppIcons.calendar),
                      _chip('Entrega $end', icon: AppIcons.calendar),
                      if (widget.evaluation.isPublic)
                        _chip('Pública', icon: AppIcons.public)
                      else
                        _chip('Privada', icon: Icons.lock_outline),
                      if (widget.evaluation.isPublic &&
                          (widget.evaluation.evaluatorsLimit ?? 0) > 0)
                        _chip('Limite ${widget.evaluation.evaluatorsLimit}',
                            icon: AppIcons.users),
                    ],
                  ),
                ],
              ),
            ),
            if (canGenerateConsolidated)
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.white),
                onPressed: _isGeneratingReport
                    ? null
                    : () async {
                  setState(() => _isGeneratingReport = true);
                  try {
                    await AvaliacoesReportService
                        .downloadConsolidated(widget.evaluation.id!);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isGeneratingReport = false);
                  }
                },
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('Relatório Geral'),
              ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.72,
        height: MediaQuery.of(context).size.height * 0.75,
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ESQUERDA
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _SectionCard(
                          title: 'Detalhes Gerais',
                          child: Column(
                            children: [
                              _DetailRow(
                                label: 'Link da Interface',
                                value: widget.evaluation.link ?? '-',
                                isLink: true,
                              ),
                              _DetailRow(label: 'Data de Início', value: start),
                              _DetailRow(label: 'Data de Entrega', value: end),
                              _DetailRow(
                                label: 'Domínio',
                                value: widget.evaluation.applicationType
                                    ?.description ??
                                    '-',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.big),

                        // Objetivos
                        _SectionCard(
                          title: 'Objetivos',
                          child: _isLoadingObjectives
                              ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_objectives.isEmpty)
                                const Text('Nenhum objetivo cadastrado.'),
                              if (_objectives.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _objectives
                                      .map((o) => _ObjectiveChip(
                                    text: o.description ?? '-',
                                  ))
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.big),

                        _SectionCard(
                          title: 'Criada por',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(AppIcons.person,
                                color: AppColors.black),
                            title: Text(
                                widget.evaluation.user?.name ?? 'Não identificado'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.big * 2),

                // DIREITA
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      appText(text: 'Avaliações', fontWeight: FontWeight.bold),
                      const SizedBox(height: AppSpacing.normal),
                      Expanded(
                        child: _isLoadingProblems
                            ? const Center(child: CircularProgressIndicator())
                            : (widget.evaluators.isEmpty)
                            ? const Center(
                            child: Text('Nenhum avaliador atribuído.'))
                            : ListView.builder(
                          itemCount: widget.evaluators.length,
                          itemBuilder: (context, index) {
                            final evaluator = widget.evaluators[index];
                            final problems =
                                _problemsByEvaluator[evaluator.user?.id] ??
                                    [];
                            final isOwner = _currentUserId != null &&
                                _currentUserId ==
                                    widget.evaluation.user?.id
                                        .toString();
                            final isThisEvaluator = _currentUserId != null &&
                                _currentUserId ==
                                    evaluator.user?.id.toString();

                            return _EvaluatorTile(
                              evaluator: evaluator,
                              problems: problems,
                              isOwner: isOwner,
                              isThisEvaluator: isThisEvaluator,
                              onStart: () =>
                                  _showStartEvaluationConfirmationDialog(
                                      evaluator),
                              onViewProblems: () {
                                Navigator.of(context).pop();
                                NavigationManager().goTo(
                                  ProblemaPage(
                                    evaluationId:
                                    widget.evaluation.id!,
                                    evaluatorId:
                                    evaluator.user!.id!,
                                    mode: ProblemaPageMode.view,
                                  ),
                                );
                              },
                              onEditMine: () {
                                Navigator.of(context).pop();
                                NavigationManager().goTo(
                                  ProblemaPage(
                                    evaluationId:
                                    widget.evaluation.id!,
                                    evaluatorId:
                                    evaluator.user!.id!,
                                    mode: ProblemaPageMode.edit,
                                  ),
                                );
                              },
                              onRemove: () =>
                                  _showDeleteEvaluatorConfirmationDialog(
                                      evaluator),
                              onDownloadReport: problems.isEmpty
                                  ? null
                                  : () => _handleReportGeneration(
                                    () => ReportGeneratorService
                                    .generateEvaluatorReport(
                                  context: context,
                                  evaluator: evaluator,
                                  evaluation:
                                  widget.evaluation,
                                  problems: problems,
                                  objectives: _objectives, // <-- importante
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isGeneratingReport)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Gerando relatório, por favor aguarde...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ----------------- Widgets de apoio -----------------

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.big),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(text: title, fontWeight: FontWeight.w700),
          const SizedBox(height: 8),
          Divider(height: 24, color: AppColors.grey300),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLink;
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isValidLink = isLink &&
        value.trim().isNotEmpty &&
        Uri.tryParse(value)?.hasScheme == true;

    void openLink() {
      if (!isValidLink || !kIsWeb) return;
      html.window.open(value, '_blank');
    }

    final Widget valueWidget = isValidLink
        ? MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SelectableText(
              value,
              style: const TextStyle(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
              onTap: openLink,
            ),
          )
        : SelectableText(
            value,
            style: const TextStyle(color: AppColors.grey800),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: valueWidget,
          ),
        ],
      ),
    );
  }
}

class _ObjectiveChip extends StatelessWidget {
  final String text;
  const _ObjectiveChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.check, size: 14, color: AppColors.black),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


class _EvaluatorTile extends StatelessWidget {
  final Evaluator evaluator;
  final List<Problem> problems;

  final bool isOwner;
  final bool isThisEvaluator;

  final VoidCallback onStart;
  final VoidCallback onViewProblems;
  final VoidCallback onEditMine;
  final VoidCallback onRemove;
  final VoidCallback? onDownloadReport;

  const _EvaluatorTile({
    required this.evaluator,
    required this.problems,
    required this.isOwner,
    required this.isThisEvaluator,
    required this.onStart,
    required this.onViewProblems,
    required this.onEditMine,
    required this.onRemove,
    required this.onDownloadReport,
  });

  @override
  Widget build(BuildContext context) {
    final isConcluida = evaluator.status?.id == 2;
    final isNaoIniciada = evaluator.status?.id == 3;

    final Color badgeColor = isConcluida
        ? AppColors.green300
        : (isNaoIniciada ? AppColors.grey600 : AppColors.amber300);
    final String badgeText = evaluator.status?.description ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.normal),
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            children: [
              Expanded(
                child: Text(
                  evaluator.user?.name ?? '-',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: badgeColor, width: 1),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 24),

          // Ações
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (isNaoIniciada && isThisEvaluator)
                _PrimaryFilledAction(
                  label: 'Começar Avaliação',
                  icon: Icons.play_arrow,
                  onPressed: onStart,
                ),
              if (!isNaoIniciada)
                _OutlinedAction(
                  label: 'Visualizar Problemas',
                  icon: AppIcons.view,
                  onPressed: onViewProblems,
                ),
              if (isThisEvaluator && !isNaoIniciada)
                _OutlinedAction(
                  label: 'Minha Avaliação',
                  icon: Icons.playlist_add_check,
                  onPressed: onEditMine,
                ),
              if (isConcluida && onDownloadReport != null)
                // _OutlinedAction(
                //   label: 'Baixar Relatório',
                //   icon: AppIcons.download,
                //   onPressed: onDownloadReport!,
                // ),
              if (isOwner)
                IconButton(
                  tooltip: 'Remover Avaliador',
                  onPressed: onRemove,
                  icon: Icon(AppIcons.delete, color: AppColors.red300, size: 18),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryFilledAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryFilledAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _OutlinedAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _OutlinedAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: AppColors.white),
      label: Text(label, style: const TextStyle(color: AppColors.white)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white24, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white.withValues(alpha: 0.06),
      ),
    );
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  _StatusInfo(this.label, this.color);
}
