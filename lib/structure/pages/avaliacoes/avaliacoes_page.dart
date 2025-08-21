import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/EvaluationViewData.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_event.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_state.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/cadastro/cadastro_avaliacoes_page.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/modal/avaliacoes_detalhes_modal.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/tabs/comunidade_avaliacoes_tab.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/tabs/minhas_avaliacoes_tab.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_page.dart';
import 'package:flutter_pandyzer/structure/widgets/app_container.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvaliacoesPage extends StatefulWidget {
  const AvaliacoesPage({super.key});

  @override
  State<AvaliacoesPage> createState() => _AvaliacoesPageState();
}

class _AvaliacoesPageState extends State<AvaliacoesPage> with SingleTickerProviderStateMixin {
  final AvaliacoesBloc _bloc = AvaliacoesBloc();
  late TabController _tabController;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUserAndData();
  }

  Future<void> _loadCurrentUserAndData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentUserId = prefs.getString('userId');
      });
    }
    _bloc.add(LoadAvaliacoesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onChangeState(BuildContext context, AvaliacoesState state) {
    if (state is EvaluationDetailsLoaded) {
      _showDetailsModal(context, state.evaluation!, state.objectives, state.evaluators);
    }
    if (state is AvaliacaoDeleted) {
      showAppToast(context: context, message: "Avaliação excluída com sucesso!");
    }
    if (state is AvaliacoesError) {
      showAppToast(context: context, message: state.message ?? "Ocorreu um erro", isError: true);
    }
  }

  // --- Funções de Ação Centralizadas ---

  void _performAction(EvaluationViewData viewData) {
    final evaluation = viewData.evaluation;
    if (_currentUserId == null || evaluation.id == null) return;

    if (viewData.currentUserHasStarted) {
      NavigationManager().goTo(
        ProblemaPage(
          evaluationId: evaluation.id!,
          evaluatorId: int.parse(_currentUserId!),
          mode: ProblemaPageMode.edit,
        ),
      );
    } else {
      // A chamada agora passa o objeto viewData completo
      _showStartEvaluationConfirmationDialog(viewData);
    }
  }

  void _viewAvaliacao(int evaluationId) {
    _bloc.add(LoadEvaluationDetailsEvent(evaluationId));
  }

  void _editAvaliacao(int evaluationId) {
    NavigationManager().goTo(CadastroAvaliacoesPage(bloc: _bloc, evaluationId: evaluationId));
  }

  void _deleteAvaliacao(EvaluationViewData viewData) {
    if (viewData.evaluation.id == null) return;
    _showDeleteConfirmationDialog(viewData.evaluation);
  }

  // --- Funções de Diálogo ---

  void _showDetailsModal(BuildContext context, Evaluation evaluation, List<Objective> objectives, List<Evaluator> evaluators) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: _bloc,
        child: AvaliacoesDetalhesModal(
          evaluation: evaluation,
          objectives: objectives,
          evaluators: evaluators,
          bloc: _bloc,
        ),
      ),
    );
  }

  void _showStartEvaluationConfirmationDialog(EvaluationViewData viewData) {
    // Agora acessamos os dados através do viewData
    final evaluation = viewData.evaluation;
    final evaluator = viewData.currentUserAsEvaluator;

    // A verificação continua válida
    if (evaluator?.id == null || evaluation.id == null) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Iniciar Avaliação'),
          content: const Text('Tem certeza que deseja começar esta avaliação? Após iniciar, o status será alterado para "Em Andamento".'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.green),
              child: const Text('Confirmar e Iniciar'),
              onPressed: () {
                _bloc.add(StartEvaluationEvent(
                  evaluatorId: evaluator!.id!,
                  evaluationId: evaluation.id!,
                ));
                Navigator.of(dialogContext).pop();
                NavigationManager().goTo(
                  ProblemaPage(
                    evaluationId: evaluation.id!,
                    evaluatorId: evaluator.user!.id!,
                    mode: ProblemaPageMode.edit,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Evaluation evaluation) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir a avaliação "${evaluation.description}"? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Excluir'),
              onPressed: () {
                _bloc.add(DeleteAvaliacaoEvent(evaluation.id!));
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
    return Scaffold(
      backgroundColor: AppColors.white,
      // O BlocProvider cria e fornece a instância do BLoC para todos os widgets filhos (incluindo as abas)
      body: BlocProvider.value(
        value: _bloc,
        // O BlocListener ouve os estados para ações como mostrar toasts e modais
        child: BlocListener<AvaliacoesBloc, AvaliacoesState>(
          listener: _onChangeState,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.big),
            child: appContainer(
              width: 1600,
              padding: const EdgeInsets.all(AppSpacing.big),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: AppColors.grey800),
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  _filters(),
                  appSizedBox(height: 16),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.grey700,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(icon: Icon(Icons.person_outline), text: 'MINHAS AVALIAÇÕES'),
                      Tab(icon: Icon(Icons.groups_outlined), text: 'COMUNIDADE'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Primeira Aba
                        MinhasAvaliacoesTab(
                          currentUserId: _currentUserId,
                          onPerform: _performAction,
                          onView: _viewAvaliacao,
                          onEdit: _editAvaliacao,
                          onDelete: _deleteAvaliacao,
                        ),
                        // Segunda Aba
                        ComunidadeAvaliacoesTab(
                          currentUserId: _currentUserId,
                          onPerform: _performAction,
                          onView: _viewAvaliacao,
                          onEdit: _editAvaliacao,
                          onDelete: _deleteAvaliacao,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return appContainer(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.centerLeft,
      child: appText(
        text: AppStrings.avaliacoes,
        fontSize: AppFontSize.fs28,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }

  Widget _filters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Filtrar avaliações...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.s10)),
            ),
          ),
        ),
        appSizedBox(width: AppSpacing.big),
        AppTextButton(
          text: "Nova Avaliação",
          icon: AppIcons.add,
          width: AppSizes.s200,
          onPressed: () => NavigationManager().goTo(CadastroAvaliacoesPage(bloc: _bloc)),
        ),
      ],
    );
  }
}