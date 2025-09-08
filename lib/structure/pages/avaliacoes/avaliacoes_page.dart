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
import 'package:flutter_pandyzer/structure/http/models/Status.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_event.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_state.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/cadastro/cadastro_avaliacoes_page.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/modal/avaliacoes_detalhes_modal.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/tabs/comunidade_avaliacoes_tab.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/tabs/minhas_avaliacoes_tab.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_page.dart';
import 'package:flutter_pandyzer/structure/widgets/animated_action_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_container.dart';
import 'package:flutter_pandyzer/structure/widgets/app_data_picker_field.dart';
import 'package:flutter_pandyzer/structure/widgets/app_dropdown.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_field.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../http/models/User.dart';
import '../../widgets/app_confirm_dialog.dart';
import 'avaliacoes_repository.dart';

class AvaliacoesPage extends StatefulWidget {
  const AvaliacoesPage({super.key});

  @override
  State<AvaliacoesPage> createState() => _AvaliacoesPageState();
}

class _AvaliacoesPageState extends State<AvaliacoesPage>
    with SingleTickerProviderStateMixin {
  final AvaliacoesBloc _bloc = AvaliacoesBloc();
  late TabController _tabController;
  String? _currentUserId;

  final _descriptionFilterController = TextEditingController();
  Status? _selectedStatus;
  List<Status> _availableStatuses = [];
  User? _selectedCreator;
  List<User> _availableCreators = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUserAndData();
    _loadFilterDependencies();
  }

  Future<void> _loadCreators() async {
    try {
      if (_currentUserId == null) return;
      final userId = int.parse(_currentUserId!);
      final creators = await AvaliacoesRepository.getCreatorsForUser(userId);
      if (mounted) {
        setState(() {
          _availableCreators = creators;
        });
      }
    } catch (_) {
      if (mounted) {
        showAppToast(
          context: context,
          message: "Erro ao carregar criadores.",
          isError: true,
        );
      }
    }
  }

  Future<void> _loadFilterDependencies() async {
    try {
      final statuses = await AvaliacoesRepository.getStatuses();
      if (mounted) {
        setState(() {
          _availableStatuses = statuses;
        });
      }
    } catch (e) {
      if (mounted) {
        showAppToast(
          context: context,
          message: "Erro ao carregar os status para o filtro.",
          isError: true,
        );
      }
    }
  }

  Future<void> _loadCurrentUserAndData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentUserId = prefs.getString('userId');
      });
    }
    _bloc.add(LoadAvaliacoesEvent());
    await _loadCreators();

  }

  @override
  void dispose() {
    _tabController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onChangeState(BuildContext context, AvaliacoesState state) {
    if (state is EvaluationDetailsLoaded) {
      _showDetailsModal(
        context,
        state.evaluation!,
        state.objectives,
        state.evaluators,
      );
    }
    if (state is AvaliacaoDeleted) {
      showAppToast(context: context, message: "Avaliação excluída com sucesso!");
    }
    if (state is AvaliacoesError) {
      showAppToast(
        context: context,
        message: state.message ?? "Ocorreu um erro",
        isError: true,
      );
    }
  }

  // --- Ações ---

  void _applyFilters() {
    _bloc.add(ApplyFiltersEvent(
      description: _descriptionFilterController.text,
      creatorId: _selectedCreator?.id, // <- novo
      status: _selectedStatus,
    ));
  }

  void _clearFilters() {
    _descriptionFilterController.clear();
    setState(() {
      _selectedStatus = null;
      _selectedCreator = null;
    });
    _bloc.add(LoadAvaliacoesEvent());
  }


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
      _showStartEvaluationConfirmationDialog(viewData);
    }
  }

  void _viewAvaliacao(int evaluationId) {
    _bloc.add(LoadEvaluationDetailsEvent(evaluationId));
  }

  void _editAvaliacao(int evaluationId) {
    NavigationManager().goTo(
      CadastroAvaliacaoPage(editarAvaliacaoId: evaluationId),
    );
  }

  void _deleteAvaliacao(EvaluationViewData viewData) {
    if (viewData.evaluation.id == null) return;
    _showDeleteConfirmationDialog(viewData.evaluation);
  }

  // --- Diálogos ---

  void _showDetailsModal(
      BuildContext context,
      Evaluation evaluation,
      List<Objective> objectives,
      List<Evaluator> evaluators,
      ) {
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
    final evaluation = viewData.evaluation;
    final evaluator = viewData.currentUserAsEvaluator;
    // usamos o ID do USUÁRIO do avaliador (necessário para o endpoint /evaluators/{idUser}/{idEvaluation}/status/{idStatus})
    final evaluatorUserId = evaluator?.user?.id;
    if (evaluatorUserId == null || evaluation.id == null) return;

    showAppConfirmDialog(
      context,
      AppConfirmDialog(
        icon: Icons.play_circle_outline,
        iconBg: AppColors.grey900,
        title: 'Iniciar avaliação',
        message:
        'Você está prestes a iniciar a avaliação "${evaluation.description}".\n'
            'O status será alterado para "Em Andamento" e você poderá registrar problemas.',
        confirmText: 'Confirmar e iniciar',
        confirmColor: AppColors.black,
        onConfirm: () {
          _bloc.add(StartEvaluationEvent(
            evaluatorRecordId: evaluator!.id!,        // evaluator.currentUserAsEvaluator.id
            evaluatorUserId: evaluator.user!.id!,    // evaluator.currentUserAsEvaluator.user.id
            evaluationId: evaluation.id!,
          ));
          // navega para edição dos problemas do próprio avaliador
          NavigationManager().goTo(
            ProblemaPage(
              evaluationId: evaluation.id!,
              evaluatorId: evaluatorUserId,
              mode: ProblemaPageMode.edit,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(Evaluation evaluation) {
    showAppConfirmDialog(
      context,
      AppConfirmDialog(
        icon: Icons.delete_outline,
        iconBg: AppColors.red300,
        title: 'Excluir avaliação',
        message: 'Tem certeza que deseja excluir a avaliação '
            '"${evaluation.description}"?\nEsta ação não pode ser desfeita.',
        confirmText: 'Excluir',
        confirmColor: AppColors.red,
        danger: true,
        onConfirm: () {
          _bloc.add(DeleteAvaliacaoEvent(evaluation.id!));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocProvider.value(
        value: _bloc,
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

                  const SizedBox(height: 8),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    labelColor: AppColors.black,
                    unselectedLabelColor: AppColors.grey600,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: .5,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      letterSpacing: .25,
                    ),
                    indicator: const UnderlineTabIndicator(
                      borderSide:
                      BorderSide(width: 2, color: AppColors.black),
                      insets: EdgeInsets.symmetric(horizontal: 24),
                    ),
                    overlayColor:
                    const WidgetStatePropertyAll(Colors.transparent),
                    tabs: const [
                      Tab(
                        child: _CleanTab(
                          icon: Icons.person_outline,
                          text: 'MINHAS AVALIAÇÕES',
                        ),
                      ),
                      Tab(
                        child: _CleanTab(
                          icon: Icons.groups_outlined,
                          text: 'COMUNIDADE',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Divider(height: 1, color: AppColors.grey300),
                  const SizedBox(height: 8),

                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        MinhasAvaliacoesTab(
                          currentUserId: _currentUserId,
                          onPerform: _performAction,
                          onView: _viewAvaliacao,
                          onEdit: _editAvaliacao,
                          onDelete: _deleteAvaliacao,
                        ),
                        ComunidadeAvaliacoesTab(
                          currentUserId: _currentUserId,
                          onPerform: _performAction,
                          onView: _viewAvaliacao,
                          onEdit: _editAvaliacao,
                          onDelete: _deleteAvaliacao,
                          onJoin: _joinEvaluation,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          appText(
            text: AppStrings.avaliacoes,
            fontSize: AppFontSize.fs28,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          AnimatedActionButton(
            text: "Nova Avaliação",
            icon: AppIcons.add,
            onPressed: () =>
                NavigationManager().goTo(const CadastroAvaliacaoPage()),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return ExpansionTile(
      title: appText(text: "Filtros", fontWeight: FontWeight.bold),
      leading: const Icon(AppIcons.filter),
      childrenPadding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: AppTextField(
                label: 'Título da Avaliação',
                controller: _descriptionFilterController,
                height: 75,
              ),
            ),
            appSizedBox(width: AppSpacing.normal),
            // —— novo: dropdown de Criador (entra no lugar das duas datas)
            Expanded(
              flex: 1,
              child: AppDropdown<User>(
                label: 'Criador',
                value: _selectedCreator,
                items: _availableCreators,
                hintText: 'Selecione o criador',
                height: 30,
                onChanged: (u) => setState(() => _selectedCreator = u),
                itemLabelBuilder: (u) => u.name ?? '—',
              ),
            ),
            appSizedBox(width: AppSpacing.normal),
            Expanded(
              flex: 1,
              child: AppDropdown<Status>(
                label: 'Status',
                value: _selectedStatus,
                items: _availableStatuses,
                hintText: 'Selecione um status',
                height: 30,
                onChanged: (status) => setState(() => _selectedStatus = status),
                itemLabelBuilder: (status) => status.description ?? '',
              ),
            ),
          ],
        ),
        appSizedBox(height: AppSpacing.medium),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppTextButton(
              text: "Limpar Filtros",
              backgroundColor: AppColors.grey600,
              onPressed: _clearFilters,
              width: 150,
            ),
            appSizedBox(width: AppSpacing.normal),
            AppTextButton(
              text: "Aplicar Filtros",
              icon: AppIcons.search,
              onPressed: _applyFilters,
              width: 150,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _joinEvaluation(Evaluation evaluation) async {
    if (_currentUserId == null || evaluation.id == null) return;

    await showAppConfirmDialog(
      context,
      AppConfirmDialog(
        icon: Icons.person_add_alt_1,
        iconBg: AppColors.grey900,
        title: 'Ingressar na avaliação',
        message:
        'Deseja ingressar na avaliação pública "${evaluation.description}"?\n'
            'Você passará a constar como avaliador desta avaliação.',
        confirmText: 'Ingressar',
        confirmColor: AppColors.black,
        onConfirm: () async {
          try {
            final statusCreate = await AvaliacoesRepository.getStatusById(3); // Não iniciada
            await AvaliacoesRepository.createAvaliador(
              Evaluator(
                user: User(id: int.parse(_currentUserId!)),
                evaluation: Evaluation(id: evaluation.id),
                status: statusCreate,
                register: DateTime.now().toIso8601String(),
              ),
            );

            if (!mounted) return;
            showAppToast(context: context, message: 'Você ingressou na avaliação!');
            _bloc.add(LoadAvaliacoesEvent());
          } catch (e) {
            if (!mounted) return;
            showAppToast(
              context: context,
              message: 'Não foi possível ingressar: $e',
              isError: true,
            );
          }
        },
      ),
    );
  }
}

class _CleanTab extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CleanTab({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
