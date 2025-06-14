import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_convert.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/file_downloader_service.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_event.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_page.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_repository.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_page.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvaliacoesDetalhesModal extends StatefulWidget {
  final AvaliacoesBloc bloc;
  final Evaluation evaluation;
  final List<Objective> objectives;
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
  final Map<int, List<Problem>> _problemsByEvaluator = {};
  bool _isLoadingProblems = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadProblems();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentUserId = prefs.getString('userId');
      });
    }
  }

  Future<void> _loadProblems() async {
    if (widget.evaluation.id == null) {
      setState(() => _isLoadingProblems = false);
      return;
    }
    final groupedProblems = <int, List<Problem>>{};
    final List<Future> fetchFutures = [];
    for (final evaluator in widget.evaluators) {
      final evaluatorUserId = evaluator.user?.id;
      if (evaluatorUserId != null) {
        groupedProblems[evaluatorUserId] = [];
        for (final objective in widget.objectives) {
          final objectiveId = objective.id;
          if (objectiveId != null) {
            final future = AvaliacoesRepository.getProblemsByIdObjetivoAndIdEvaluator(
              objectiveId,
              evaluatorUserId,
            ).then((problems) {
              groupedProblems[evaluatorUserId]?.addAll(problems);
            });
            fetchFutures.add(future);
          }
        }
      }
    }
    await Future.wait(fetchFutures);
    if (mounted) {
      setState(() {
        _problemsByEvaluator.addAll(groupedProblems);
        _isLoadingProblems = false;
      });
    }
  }

  void _showDeleteEvaluatorConfirmationDialog(Evaluator evaluator) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja remover ${evaluator.user?.name} desta avaliação? Todos os problemas reportados por ele serão perdidos.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Excluir'),
              onPressed: () {
                widget.bloc.add(DeleteEvaluatorAndProblems(
                  evaluatorId: evaluator.id!,
                  evaluationId: widget.evaluation.id!,
                ));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(AppSpacing.big),
      title: _buildHeader(context),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildLeftColumn(),
            ),
            const VerticalDivider(width: AppSpacing.big * 2),
            Expanded(
              flex: 2,
              child: _buildRightColumn(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.big),
      decoration: const BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: appText(
              text: widget.evaluation.description ?? 'Detalhes da Avaliação',
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
    );
  }

  Widget _buildLeftColumn() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Detalhes Gerais'),
          _buildDetailRow('Link da Interface:', widget.evaluation.link ?? '-'),
          _buildDetailRow('Data de Início:', AppConvert.convertIsoDateToFormattedDate(widget.evaluation.startDate)),
          _buildDetailRow('Data de Entrega:', AppConvert.convertIsoDateToFormattedDate(widget.evaluation.finalDate)),
          _buildDetailRow('Domínio:', widget.evaluation.applicationType?.description ?? '-'),
          const Divider(height: AppSpacing.big * 2, thickness: 1),
          _buildSectionTitle('Objetivos'),
          ...widget.objectives.map((obj) => _buildListItem(obj.description ?? '-', AppIcons.check)),
          if (widget.objectives.isEmpty) appText(text: 'Nenhum objetivo cadastrado.'),
          const Divider(height: AppSpacing.big * 2, thickness: 1),
          _buildSectionTitle('Criada Por'),
          _buildCreatorInfo(widget.evaluation.user?.name ?? 'Não identificado'),
        ],
      ),
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Avaliações'),
        if (_isLoadingProblems)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (widget.evaluators.isEmpty)
          Expanded(child: Center(child: appText(text: 'Nenhum avaliador atribuído.')))
        else
          Expanded(
            child: ListView.builder(
              itemCount: widget.evaluators.length,
              itemBuilder: (context, index) {
                final evaluator = widget.evaluators[index];
                final problemsOfThisEvaluator = _problemsByEvaluator[evaluator.user?.id] ?? [];
                return _buildEvaluatorCard(evaluator, problemsOfThisEvaluator);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEvaluatorCard(Evaluator evaluator, List<Problem> problems) {
    final bool isConcluida = evaluator.status?.id == 2;
    // O dono da avaliação principal
    final bool isOwner = _currentUserId != null && _currentUserId == widget.evaluation.user?.id.toString();

    // Verifica se o usuário logado é o PRÓPRIO avaliador deste card
    final bool isThisEvaluator = _currentUserId != null && _currentUserId == evaluator.user?.id.toString();

    final bool canDownloadReport = isConcluida;

    return Card(
      color: AppColors.grey900,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: AppSpacing.normal),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                appText(text: 'Avaliador: ${evaluator.user?.name ?? '-'}', color: AppColors.white, fontWeight: FontWeight.bold),
                appText(
                  text: 'Status: ${evaluator.status?.description ?? '-'}',
                  color: isConcluida ? AppColors.green300 : AppColors.amber300,
                  fontSize: AppFontSize.fs12,
                ),
              ],
            ),
            Divider(color: AppColors.grey700),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canDownloadReport)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.white),
                    onPressed: () async {
                      try {
                        await FileDownloaderService.downloadAssetPdf(
                          assetPath: 'pdf/relatorio.pdf',
                          downloadFileName: 'Relatorio_${widget.evaluation.description?.replaceAll(' ', '_')}.pdf',
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao baixar o arquivo: $e"), backgroundColor: AppColors.red));
                      }
                    },
                    icon: const Icon(AppIcons.download, size: 16),
                    label: appText(text: 'Baixar Relatório', color: AppColors.white, fontSize: AppFontSize.fs12),
                  ),
                const Spacer(),

                // Botão de Visualizar (sempre visível)
                IconButton(
                  tooltip: 'Visualizar Problemas',
                  onPressed: () {
                    Navigator.of(context).pop();
                    NavigationManager().goTo(
                      ProblemaPage(
                        evaluationId: widget.evaluation.id!,
                        evaluatorId: evaluator.user!.id!,
                        mode: ProblemaPageMode.view,
                      ),
                    );
                  },
                  icon: const Icon(AppIcons.view, color: AppColors.white, size: 18),
                ),

                // Botão de Editar (apenas para o próprio avaliador)
                if (isThisEvaluator)
                  IconButton(
                    tooltip: 'Minha Avaliação',
                    onPressed: () {
                      Navigator.of(context).pop();
                      NavigationManager().goTo(
                        ProblemaPage(
                          evaluationId: widget.evaluation.id!,
                          evaluatorId: evaluator.user!.id!,
                          mode: ProblemaPageMode.edit,
                        ),
                      );
                    },
                    icon: const Icon(Icons.playlist_add_check, color: AppColors.white, size: 18),
                  ),

                // Botão de Excluir (apenas para o dono da avaliação)
                if (isOwner)
                  IconButton(
                    tooltip: 'Remover Avaliador',
                    onPressed: () => _showDeleteEvaluatorConfirmationDialog(evaluator),
                    icon: Icon(AppIcons.delete, color: AppColors.red300, size: 18),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.normal),
      child: appText(text: title, fontSize: AppFontSize.fs18, fontWeight: FontWeight.bold, color: AppColors.black),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: appText(text: label, fontWeight: FontWeight.bold)),
          Expanded(flex: 2, child: appText(text: value, color: AppColors.grey800)),
        ],
      ),
    );
  }

  Widget _buildListItem(String text, IconData icon) {
    return Card(
      elevation: 0,
      color: AppColors.grey100,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: ListTile(
        leading: Icon(icon, color: AppColors.grey800, size: 20),
        title: Text(text),
        dense: true,
      ),
    );
  }

  Widget _buildCreatorInfo(String name) {
    return Card(
      elevation: 0,
      color: AppColors.grey100,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: ListTile(
        leading: const Icon(AppIcons.person, color: AppColors.black),
        title: Text(name),
      ),
    );
  }
}