import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Heuristic.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';
import 'package:flutter_pandyzer/structure/http/models/Severity.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_page.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_event.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_state.dart';
import 'package:flutter_pandyzer/structure/widgets/app_dropdown.dart';
import 'package:flutter_pandyzer/structure/widgets/app_error.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_field.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'problema_bloc.dart';

// Enum para controlar o modo da página
enum ProblemaPageMode { edit, view }

// Classe auxiliar para agrupar o problema e seus controladores
class ProblemForm {
  final Problem problem;
  final TextEditingController descriptionController;
  final TextEditingController recommendationController;
  XFile? pickedFile;

  ProblemForm(this.problem)
      : descriptionController = TextEditingController(text: problem.description),
        recommendationController =
        TextEditingController(text: problem.recomendation);

  void dispose() {
    descriptionController.dispose();
    recommendationController.dispose();
  }
}

class ProblemaPage extends StatefulWidget {
  final int evaluationId;
  final int evaluatorId;
  final ProblemaPageMode mode;

  const ProblemaPage({
    super.key,
    required this.evaluationId,
    required this.evaluatorId,
    this.mode = ProblemaPageMode.edit,
  });

  @override
  State<ProblemaPage> createState() => _ProblemaPageState();
}

class _ProblemaPageState extends State<ProblemaPage>
    with SingleTickerProviderStateMixin {
  late final ProblemaBloc _bloc;
  TabController? _tabController;
  int _currentTabIndex = 0;

  final Map<int, List<ProblemForm>> _reportedProblemForms = {};
  List<Heuristic> _heuristics = [];
  List<Severity> _severities = [];
  List<Problem> _initialProblems = [];

  bool get _isReadOnly => widget.mode == ProblemaPageMode.view;

  @override
  void initState() {
    super.initState();
    _bloc = ProblemaBloc();
    _bloc.add(LoadProblemaPageData(
        evaluationId: widget.evaluationId, evaluatorId: widget.evaluatorId));
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    for (var formList in _reportedProblemForms.values) {
      for (var form in formList) {
        form.dispose();
      }
    }
    _bloc.close();
    super.dispose();
  }

  void _onChangeState(BuildContext context, ProblemaState state) {
    if (state is ProblemaLoaded) {
      final bool shouldShowFinalizarTab = !_isReadOnly && state.currentUserStatusId == 1;
      final tabCount = state.objectives.length + (shouldShowFinalizarTab ? 1 : 0);

      if (_tabController?.length != tabCount) {
        _tabController?.removeListener(_handleTabSelection);
        _tabController = TabController(length: tabCount, vsync: this);
        _tabController!.addListener(_handleTabSelection);
      }

      // Reinicializa os formulários com os dados mais recentes do estado
      // Isso é crucial após a recarga de dados
      _reportedProblemForms.clear();
      for (var problem in state.initialProblems) {
        final objectiveId = problem.objective?.id;
        if (objectiveId != null) {
          _reportedProblemForms
              .putIfAbsent(objectiveId, () => [])
              .add(ProblemForm(problem));
        }
      }

      setState(() {
        _heuristics = state.heuristics;
        _severities = state.severities;
        _initialProblems = state.initialProblems;
      });
    }

    // --- LÓGICA MODIFICADA ---
    if (state is ProblemaSaveSuccess) {
      showAppToast(
          context: context, message: 'Operação realizada com sucesso!');
      // A navegação foi removida daqui. O BLoC agora cuida de recarregar os dados.
    }

    if (state is ProblemaFinalizeSuccess) {
      showAppToast(
          context: context, message: 'Operação realizada com sucesso!');
      NavigationManager().goTo(AvaliacoesPage());
    }

    if (state is ProblemaError) {
      showAppToast(context: context, message: state.message, isError: true);
    }
  }

  void _handleTabSelection() {
    if (_tabController != null && _tabController!.index != _currentTabIndex) {
      setState(() {
        _currentTabIndex = _tabController!.index;
      });
    }
  }

  void _handleFinalize() {
    _bloc.add(FinalizeEvaluation(
        evaluatorId: widget.evaluatorId,
        statusId: 2, // Finaliza com status 2 (Concluído)
        evaluationId: widget.evaluationId));
  }

  void _handleCancel() {
    NavigationManager().goTo(AvaliacoesPage());
  }

  Future<void> _handleSave() async {
    final List<Problem> currentProblems = [];
    _reportedProblemForms.forEach((objectiveId, forms) {
      for (var form in forms) {
        form.problem.description = form.descriptionController.text;
        form.problem.recomendation = form.recommendationController.text;
        form.problem.objective = Objective(id: objectiveId);
        if (form.problem.description?.isNotEmpty ?? false) {
          currentProblems.add(form.problem);
        }
      }
    });

    final initialIds = _initialProblems.map((p) => p.id).toSet();
    final currentIds = currentProblems.map((p) => p.id).toSet();

    final List<int> idsToDelete = initialIds.difference(currentIds)
        .where((id) => id != null)
        .cast<int>()
        .toList();

    // Adiciona os IDs necessários para o evento de recarga
    _bloc.add(UpdateProblems(
      problemsToUpsert: currentProblems,
      problemIdsToDelete: idsToDelete,
      evaluationId: widget.evaluationId,
      evaluatorId: widget.evaluatorId,
    ));
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.big),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2))
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppTextButton(
              onPressed: _handleCancel,
              text: "Voltar",
              backgroundColor: AppColors.white,
              textColor: AppColors.black,
              border: true,
              borderColor: AppColors.black),
          const SizedBox(width: AppSpacing.normal),
          if (!_isReadOnly)
            AppTextButton(onPressed: _handleSave, text: "Salvar"),
        ],
      ),
    );
  }

  Widget _buildFinalizarTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Finalizar Avaliação",
              style: TextStyle(
                  fontSize: AppFontSize.fs24, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.normal),
          Text(
              "Ao finalizar, você não poderá mais editar os problemas reportados.",
              style: TextStyle(color: AppColors.grey700)),
          const SizedBox(height: AppSpacing.big),
          AppTextButton(
            onPressed: _handleFinalize,
            text: "Confirmar Finalização",
            width: 250,
          ),
          const SizedBox(height: AppSpacing.normal),
          AppTextButton(
            onPressed: () => _tabController?.animateTo(0),
            text: "Voltar aos Problemas",
            width: 250,
            backgroundColor: AppColors.white,
            textColor: AppColors.black,
            border: true,
            borderColor: AppColors.black,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProblemaBloc, ProblemaState>(
      bloc: _bloc,
      listener: _onChangeState,
      child: BlocBuilder<ProblemaBloc, ProblemaState>(
        bloc: _bloc,
        builder: (context, state) {
          // Quando estiver carregando, mostra o loading, mas mantém o conteúdo antigo por baixo
          if (state is ProblemaLoading && state.evaluation == null) {
            return const Scaffold(body: AppLoading());
          }

          if (state is ProblemaError) {
            return Scaffold(body: AppError(message: state.message));
          }

          if (state.evaluation == null) {
            return const Scaffold(body: AppLoading());
          }

          final objectives = state.objectives;
          final evaluation = state.evaluation!;

          if (_tabController == null) {
            // A inicialização do TabController agora é feita de forma mais robusta no _onChangeState
            // Este return é um fallback de segurança.
            return const Scaffold(body: AppLoading());
          }

          final bool showFinalizarTab = !_isReadOnly && state.currentUserStatusId == 1;
          bool isFinalizarTabActive = showFinalizarTab && _currentTabIndex == objectives.length;

          return Center(
            child: Container(
              width: 1600,
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.black),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4))
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(evaluation.description ?? 'Reportar Problemas'),
                    backgroundColor: AppColors.grey900,
                    foregroundColor: AppColors.white,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(kToolbarHeight),
                      child: Container(
                        color: AppColors.grey200,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabs: [
                            ...objectives.map((obj) =>
                                Tab(text: obj.description ?? 'Objetivo')),
                            if (showFinalizarTab) const Tab(text: 'Finalizar'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  body: Stack(
                    children: [
                      TabBarView(
                        controller: _tabController,
                        children: [
                          ...objectives.map((obj) {
                            final objectiveId = obj.id;
                            if (objectiveId == null) {
                              return const Center(
                                  child: Text("Erro: Objetivo sem ID."));
                            }
                            return _ObjectiveTabView(
                              key: ValueKey(objectiveId),
                              objectiveId: objectiveId,
                              problemForms: _reportedProblemForms.putIfAbsent(
                                  objectiveId, () => []),
                              heuristics: _heuristics,
                              severities: _severities,
                              isReadOnly: _isReadOnly,
                              onAddProblem: () => setState(() =>
                                  _reportedProblemForms
                                      .putIfAbsent(objectiveId, () => [])
                                      .add(ProblemForm(Problem()))),
                              onRemoveProblem: (form) => setState(() {
                                form.dispose();
                                _reportedProblemForms[objectiveId]?.remove(form);
                              }),
                            );
                          }),
                          if (showFinalizarTab) _buildFinalizarTab(),
                        ],
                      ),
                      if (state is ProblemaLoading)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(child: AppLoading(color: Colors.white)),
                        )
                    ],
                  ),
                  bottomNavigationBar:
                  isFinalizarTabActive ? null : _buildFooter(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =======================================================
// WIDGET INTERNO STATEFUL PARA CADA ABA
// (Nenhuma alteração necessária aqui)
// =======================================================
class _ObjectiveTabView extends StatefulWidget {
  final int objectiveId;
  final List<ProblemForm> problemForms;
  final List<Heuristic> heuristics;
  final List<Severity> severities;
  final bool isReadOnly;
  final VoidCallback onAddProblem;
  final ValueChanged<ProblemForm> onRemoveProblem;

  const _ObjectiveTabView({
    super.key,
    required this.objectiveId,
    required this.problemForms,
    required this.heuristics,
    required this.severities,
    required this.isReadOnly,
    required this.onAddProblem,
    required this.onRemoveProblem,
  });

  @override
  State<_ObjectiveTabView> createState() => __ObjectiveTabViewState();
}

class __ObjectiveTabViewState extends State<_ObjectiveTabView>
    with AutomaticKeepAliveClientMixin {
  late final PageController _pageController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ProblemForm form) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() => form.pickedFile = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.problemForms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 60, color: AppColors.green300),
            const SizedBox(height: AppSpacing.medium),
            Text(
              "Nenhum problema identificado para este objetivo",
              style: TextStyle(
                  fontSize: AppFontSize.fs18, color: AppColors.grey700),
            ),
            const SizedBox(height: AppSpacing.big),
            if (!widget.isReadOnly)
              AppTextButton(
                onPressed: widget.onAddProblem,
                text: 'Reportar Primeiro Problema',
                icon: Icons.add,
                backgroundColor: AppColors.grey200,
                textColor: AppColors.black,
                width: 250,
              ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.problemForms.length,
            itemBuilder: (context, index) {
              return _buildProblemCard(widget.problemForms[index], index + 1);
            },
          ),
        ),
        _buildPaginationControls(),
      ],
    );
  }

  Widget _buildPaginationControls() {
    final int currentPage =
    _pageController.hasClients ? (_pageController.page?.round() ?? 0) : 0;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease)),
          Text("Problema ${currentPage + 1} de ${widget.problemForms.length}"),
          IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease)),
          const Spacer(),
          if (!widget.isReadOnly)
            AppTextButton(
              onPressed: () {
                widget.onAddProblem();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_pageController.hasClients) {
                    _pageController.animateToPage(widget.problemForms.length,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.ease);
                  }
                });
              },
              text: 'Adicionar Problema',
              icon: Icons.add,
              backgroundColor: AppColors.grey200,
              textColor: AppColors.black,
              width: 200,
            ),
        ],
      ),
    );
  }

  Widget _buildProblemCard(ProblemForm form, int problemNumber) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.big),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.normal),
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.grey300)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Reportar Problema $problemNumber",
                      style: const TextStyle(
                          fontSize: AppFontSize.fs18,
                          fontWeight: FontWeight.bold)),
                  if (!widget.isReadOnly)
                    IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.red),
                        onPressed: () => widget.onRemoveProblem(form)),
                ],
              ),
              const Divider(),
              AppDropdown<Heuristic>(
                label: 'Heurística de Nielsen',
                value: form.problem.heuristic,
                items: widget.heuristics,
                itemLabelBuilder: (h) => h.description ?? '',
                onChanged: widget.isReadOnly
                    ? null
                    : (h) => setState(() => form.problem.heuristic = h),
                enabled: !widget.isReadOnly,
              ),
              const SizedBox(height: AppSpacing.medium),
              AppTextField(
                  label: 'Descrição do Problema',
                  controller: form.descriptionController,
                  enabled: !widget.isReadOnly),
              const SizedBox(height: AppSpacing.medium),
              AppTextField(
                  label: 'Recomendação de Melhoria',
                  controller: form.recommendationController,
                  enabled: !widget.isReadOnly),
              const SizedBox(height: AppSpacing.medium),
              AppDropdown<Severity>(
                label: 'Severidade do Problema',
                value: form.problem.severity,
                items: widget.severities,
                itemLabelBuilder: (s) => s.description ?? '',
                onChanged: widget.isReadOnly
                    ? null
                    : (s) => setState(() => form.problem.severity = s),
                enabled: !widget.isReadOnly,
              ),
              const Divider(height: AppSpacing.big),
              const Text('Evidência',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppFontSize.fs15)),
              const SizedBox(height: AppSpacing.small),
              Row(
                children: [
                  if (!widget.isReadOnly)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.attach_file, size: 18),
                      label: const Text('Anexar Imagem'),
                      onPressed: () => _pickImage(form),
                    ),
                  const SizedBox(width: AppSpacing.normal),
                  Expanded(
                      child: Text(form.pickedFile?.name ?? 'Nenhum arquivo.',
                          style: TextStyle(
                              color: AppColors.grey700,
                              fontStyle: FontStyle.italic),
                          overflow: TextOverflow.ellipsis)),
                  if (form.pickedFile != null && !widget.isReadOnly)
                    IconButton(
                        tooltip: "Remover imagem",
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () =>
                            setState(() => form.pickedFile = null)),
                ],
              ),
              if (form.problem.imageBase64 != null && form.pickedFile == null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.normal),
                  child: Image.memory(
                      base64Decode(form.problem.imageBase64!),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover),
                ),
              if (form.pickedFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.normal),
                  child: FutureBuilder<Uint8List>(
                    future: form.pickedFile!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(snapshot.data!,
                            height: 100, width: 100, fit: BoxFit.cover);
                      }
                      return const SizedBox(
                          height: 100,
                          width: 100,
                          child: Center(child: CircularProgressIndicator()));
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}