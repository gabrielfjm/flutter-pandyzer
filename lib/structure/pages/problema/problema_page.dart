import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Heuristic.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';
import 'package:flutter_pandyzer/structure/http/models/Severity.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_event.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_state.dart';
import 'package:flutter_pandyzer/structure/widgets/app_dropdown.dart';
import 'package:flutter_pandyzer/structure/widgets/app_error.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_field.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_page.dart';
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
        recommendationController = TextEditingController(text: problem.recomendation);

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

class _ProblemaPageState extends State<ProblemaPage> with SingleTickerProviderStateMixin {
  late final ProblemaBloc _bloc;
  TabController? _tabController;
  int _currentTabIndex = 0;

  final Map<int, List<ProblemForm>> _reportedProblemForms = {};
  List<Heuristic> _heuristics = [];
  List<Severity> _severities = [];

  bool _isNewReport = false;

  bool get _isReadOnly => widget.mode == ProblemaPageMode.view;

  @override
  void initState() {
    super.initState();
    _bloc = ProblemaBloc();
    _bloc.add(LoadProblemaPageData(
        evaluationId: widget.evaluationId, evaluatorId: widget.evaluatorId));
  }

  void _onChangeState(BuildContext context, ProblemaState state) {
    if (state is ProblemaLoaded) {
      // Verifica se é um novo relatório (sem problemas iniciais)
      final isCreating = state.initialProblems.isEmpty;

      // Define o número de abas com base no modo e se é um novo relatório
      final tabCount = _isReadOnly || !isCreating ? state.objectives.length : state.objectives.length + 1;

      // Reinicializa o TabController se o número de abas mudar
      if (_tabController?.length != tabCount) {
        _tabController?.removeListener(_handleTabSelection);
        _tabController = TabController(length: tabCount, vsync: this);
        _tabController!.addListener(_handleTabSelection);
      }

      setState(() {
        _isNewReport = isCreating;
        _heuristics = state.heuristics;
        _severities = state.severities;
        _reportedProblemForms.clear();
        for (var problem in state.initialProblems) {
          final objectiveId = problem.objective?.id;
          if (objectiveId != null) {
            _reportedProblemForms
                .putIfAbsent(objectiveId, () => [])
                .add(ProblemForm(problem));
          }
        }
      });
    }
    if (state is ProblemaSaveSuccess || state is ProblemaFinalizeSuccess) {
      showAppToast(context: context, message: 'Operação realizada com sucesso!');
      NavigationManager().goTo(const AvaliacoesPage());
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
    _bloc.add(FinalizeEvaluation(evaluatorId: widget.evaluatorId, statusId: 2, evaluationId: widget.evaluationId));
  }

  void _handleCancel() {
    NavigationManager().goTo(
      const AvaliacoesPage(),
    );
  }

  Future<void> _handleSave() async {
    final Map<int, List<Problem>> problemsToSave = {};
    _reportedProblemForms.forEach((objectiveId, forms) {
      // Filtra para não enviar problemas vazios para o backend
      problemsToSave[objectiveId] = forms
          .map((form) {
        form.problem.description = form.descriptionController.text;
        form.problem.recomendation = form.recommendationController.text;
        return form.problem;
      })
          .where((problem) =>
      problem.description?.isNotEmpty ?? false)
          .toList();
    });
    _bloc.add(SaveProblemas(problemsToSave));
  }

  Widget _buildFinalizarTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Finalizar Avaliação", style: TextStyle(fontSize: AppFontSize.fs24, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.normal),
          Text("Ao finalizar, você não poderá mais editar os problemas reportados.", style: TextStyle(color: AppColors.grey700)),
          const SizedBox(height: AppSpacing.big),
          AppTextButton(
            onPressed: _handleFinalize,
            text: "Confirmar Finalização",
            width: 250,
          ),
          const SizedBox(height: AppSpacing.normal),
          AppTextButton(
            onPressed: () => _tabController?.animateTo(0),
            text: "Cancelar",
            backgroundColor: AppColors.white,
            textColor: AppColors.black,
            border: true,
            borderColor: AppColors.black,
          ),
        ],
      ),
    );
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
              text: _isReadOnly ? "Voltar" : "Cancelar",
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<ProblemaBloc, ProblemaState>(
        listener: _onChangeState,
        child: BlocBuilder<ProblemaBloc, ProblemaState>(
          builder: (context, state) {
            if (state is! ProblemaLoaded) {
              return Scaffold(
                  body: state is ProblemaError
                      ? AppError(message: state.message)
                      : const AppLoading());
            }

            final objectives = state.objectives;
            final evaluation = state.evaluation;

            if (_tabController == null) {
              return const Scaffold(body: AppLoading());
            }

            // Condição para mostrar a aba "Finalizar"
            final bool showFinalizarTab = !_isReadOnly && _isNewReport;
            bool isFinalizarTabActive = showFinalizarTab && _currentTabIndex == objectives.length;

            return Container(
              width: 1600,
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.black),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 4))]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(evaluation?.description ?? 'Reportar Problemas'),
                    backgroundColor: AppColors.grey900,
                    foregroundColor: AppColors.white,
                    leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handleCancel),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(kToolbarHeight),
                      child: Container(
                        color: AppColors.grey200,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabs: [
                            ...objectives.map((obj) => Tab(text: obj.description ?? 'Objetivo')),
                            if (showFinalizarTab) const Tab(text: 'Finalizar'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      ...objectives.map((obj) {
                        final objectiveId = obj.id;
                        if (objectiveId == null) {
                          return const Center(child: Text("Erro: Objetivo sem ID."));
                        }
                        return _ObjectiveTabView(
                          key: ValueKey(objectiveId),
                          objectiveId: objectiveId,
                          problemForms: _reportedProblemForms.putIfAbsent(objectiveId, () => []),
                          heuristics: _heuristics,
                          severities: _severities,
                          isReadOnly: _isReadOnly,
                          onAddProblem: () => setState(() => _reportedProblemForms
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
                  bottomNavigationBar: isFinalizarTabActive ? null : _buildFooter(),
                ),
              ),
            );
          },
        ),
      ),
    );
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
}

// =======================================================
// WIDGET INTERNO STATEFUL PARA CADA ABA
// Solução para o bug da paginação e estado das abas
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

class __ObjectiveTabViewState extends State<_ObjectiveTabView> with AutomaticKeepAliveClientMixin {
  late final PageController _pageController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() => setState(() {}));
    if (widget.problemForms.isEmpty && !widget.isReadOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onAddProblem());
    }
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
            Icon(Icons.check_circle_outline, size: 60, color: AppColors.green300),
            const SizedBox(height: AppSpacing.medium),
            Text("Nenhum problema identificado para este objetivo", style: TextStyle(fontSize: AppFontSize.fs18, color: AppColors.grey700)),
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
    final int currentPage = _pageController.hasClients ? (_pageController.page?.round() ?? 0) : 0;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease)),
          Text("Problema ${currentPage + 1} de ${widget.problemForms.length}"),
          IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease)),
          const Spacer(),
          if (!widget.isReadOnly)
            AppTextButton(
              onPressed: () {
                widget.onAddProblem();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_pageController.hasClients) {
                    _pageController.animateToPage(widget.problemForms.length, duration: const Duration(milliseconds: 400), curve: Curves.ease);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.grey300)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Reportar Problema $problemNumber", style: const TextStyle(fontSize: AppFontSize.fs18, fontWeight: FontWeight.bold)),
                  if (!widget.isReadOnly)
                    IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.red), onPressed: () => widget.onRemoveProblem(form)),
                ],
              ),
              const Divider(),
              AppDropdown<Heuristic>(
                label: 'Heurística de Nielsen',
                value: form.problem.heuristic,
                items: widget.heuristics,
                itemLabelBuilder: (h) => h.description ?? '',
                onChanged: widget.isReadOnly ? null : (h) => setState(() => form.problem.heuristic = h),
                enabled: !widget.isReadOnly,
              ),
              const SizedBox(height: AppSpacing.medium),
              AppTextField(label: 'Descrição do Problema', controller: form.descriptionController, enabled: !widget.isReadOnly),
              const SizedBox(height: AppSpacing.medium),
              AppTextField(label: 'Recomendação de Melhoria', controller: form.recommendationController, enabled: !widget.isReadOnly),
              const SizedBox(height: AppSpacing.medium),
              AppDropdown<Severity>(
                label: 'Severidade do Problema',
                value: form.problem.severity,
                items: widget.severities,
                itemLabelBuilder: (s) => s.description ?? '',
                onChanged: widget.isReadOnly ? null : (s) => setState(() => form.problem.severity = s),
                enabled: !widget.isReadOnly,
              ),
              const Divider(height: AppSpacing.big),
              const Text('Evidência', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppFontSize.fs15)),
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
                  Expanded(child: Text(form.pickedFile?.name ?? 'Nenhum arquivo.', style: TextStyle(color: AppColors.grey700, fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis)),
                  if (form.pickedFile != null && !widget.isReadOnly)
                    IconButton(tooltip: "Remover imagem", icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => form.pickedFile = null)),
                ],
              ),
              if (form.problem.imageBase64 != null && form.pickedFile == null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.normal),
                  child: Image.memory(base64Decode(form.problem.imageBase64!), height: 100, width: 100, fit: BoxFit.cover),
                ),
              if (form.pickedFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.normal),
                  child: FutureBuilder<Uint8List>(
                    future: form.pickedFile!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(snapshot.data!, height: 100, width: 100, fit: BoxFit.cover);
                      }
                      return const SizedBox(height: 100, width: 100, child: Center(child: CircularProgressIndicator()));
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