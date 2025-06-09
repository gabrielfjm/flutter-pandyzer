import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
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

  const ProblemaPage({super.key, required this.evaluationId});

  @override
  State<ProblemaPage> createState() => _ProblemaPageState();
}

class _ProblemaPageState extends State<ProblemaPage> {
  late final ProblemaBloc _bloc;
  final Map<int, List<ProblemForm>> _reportedProblemForms = {};
  List<Heuristic> _heuristics = [];
  List<Severity> _severities = [];

  final Map<int, PageController> _pageControllers = {};

  @override
  void initState() {
    super.initState();
    _bloc = ProblemaBloc();
    _bloc.add(LoadProblemaPageData(widget.evaluationId));
  }

  void _onChangeState(BuildContext context, ProblemaState state) {
    if (state is ProblemaLoaded) {
      setState(() {
        _heuristics = state.heuristics;
        _severities = state.severities;
      });
    }
    if (state is ProblemaSaveSuccess) {
      showAppToast(context: context, message: 'Problemas salvos com sucesso!');
      NavigationManager().goTo(const AvaliacoesPage());
    }
    if (state is ProblemaError) {
      showAppToast(context: context, message: state.message, isError: true);
    }
  }

  void _addProblem(int objectiveId) {
    setState(() {
      _reportedProblemForms
          .putIfAbsent(objectiveId, () => [])
          .add(ProblemForm(Problem()));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _pageControllers[objectiveId];
      if (controller != null && controller.hasClients) {
        controller.animateToPage(
          _reportedProblemForms[objectiveId]!.length - 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _removeProblem(int objectiveId, ProblemForm form) {
    setState(() {
      final problemList = _reportedProblemForms[objectiveId];
      if (problemList != null) {
        final controller = _pageControllers[objectiveId];
        // Captura a página atual antes de remover
        final currentPage = controller?.page?.round() ?? 0;

        form.dispose();
        problemList.remove(form);

        // Se a página atual era a última e foi removida, volte uma página
        if (currentPage >= problemList.length && problemList.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller?.jumpToPage(problemList.length - 1);
          });
        }
      }
    });
  }

  Future<void> _pickImage(ProblemForm form) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        form.pickedFile = image;
      });
    }
  }

  void _handleCancel() {
    NavigationManager().goTo(const AvaliacoesPage());
  }

  Future<void> _handleSave() async {
    bool allFormsAreValid = true;

    // Se não há nenhum problema reportado, não há nada a salvar.
    if (_reportedProblemForms.values.every((list) => list.isEmpty)) {
      showAppToast(context: context, message: "Nenhum problema foi reportado para salvar.");
      return;
    }

    // Itera sobre todos os formulários de problemas criados
    for (var formList in _reportedProblemForms.values) {
      for (var form in formList) {
        if (form.problem.heuristic == null ||
            form.descriptionController.text.trim().isEmpty ||
            form.recommendationController.text.trim().isEmpty ||
            form.problem.severity == null) {
          allFormsAreValid = false;
          break; // Sai do loop interno se encontrar um formulário inválido
        }
      }
      if (!allFormsAreValid) {
        break; // Sai do loop externo também
      }
    }

    if (!allFormsAreValid) {
      showAppToast(
        context: context,
        message: "Revise os campos dos formulários! Todos devem ser preenchidos!",
        isError: true,
      );
      return;
    }

    // Se a validação passar, continua com a lógica de salvar
    final Map<int, List<Problem>> problemsToSave = {};
    for (var entry in _reportedProblemForms.entries) {
      final objectiveId = entry.key;
      final forms = entry.value;
      problemsToSave[objectiveId] = await Future.wait(forms.map((form) async {
        form.problem.description = form.descriptionController.text;
        form.problem.recomendation = form.recommendationController.text;
        if (form.pickedFile != null) {
          final imageBytes = await form.pickedFile!.readAsBytes();
          form.problem.imageBase64 = base64Encode(imageBytes);
        }
        return form.problem;
      }).toList());
    }
    _bloc.add(SaveProblemas(problemsToSave));
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.big),
      decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
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
              text: "Cancelar",
              backgroundColor: AppColors.white,
              textColor: AppColors.black,
              border: true,
              borderColor: AppColors.black),
          const SizedBox(width: AppSpacing.normal),
          AppTextButton(onPressed: _handleSave, text: "Salvar"),
        ],
      ),
    );
  }

  Widget _buildProblemCard(int objectiveId, ProblemForm form, int problemNumber) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.normal),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey300),
      ),
      child: SingleChildScrollView(
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
                  IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.red),
                      onPressed: () => _removeProblem(objectiveId, form)),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.medium),
              AppDropdown<Heuristic>(
                label: 'Heurística de Nielsen',
                value: form.problem.heuristic,
                items: _heuristics,
                itemLabelBuilder: (h) => h.description ?? 'Sem descrição',
                onChanged: (h) => setState(() => form.problem.heuristic = h),
              ),
              const SizedBox(height: AppSpacing.medium),
              AppTextField(
                label: 'Descrição do Problema',
                controller: form.descriptionController,
              ),
              const SizedBox(height: AppSpacing.medium),
              AppTextField(
                label: 'Recomendação de Melhoria',
                controller: form.recommendationController,
              ),
              const SizedBox(height: AppSpacing.medium),
              AppDropdown<Severity>(
                label: 'Severidade do Problema',
                value: form.problem.severity,
                items: _severities,
                itemLabelBuilder: (s) => s.description ?? 'Sem descrição',
                onChanged: (s) => setState(() => form.problem.severity = s),
              ),
              const SizedBox(height: AppSpacing.medium),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Evidência (Opcional)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppFontSize.fs15)),
                    const SizedBox(height: AppSpacing.small),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.attach_file, size: 18),
                          label: const Text('Anexar Imagem'),
                          onPressed: () => _pickImage(form),
                        ),
                        const SizedBox(width: AppSpacing.normal),
                        Expanded(
                          child: Text(
                            form.pickedFile?.name ?? 'Nenhum arquivo.',
                            style: TextStyle(
                                color: AppColors.grey700,
                                fontStyle: FontStyle.italic),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (form.pickedFile != null)
                          IconButton(
                            tooltip: "Remover imagem",
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => form.pickedFile = null),
                          ),
                      ],
                    ),
                    if (form.pickedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.normal),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FutureBuilder<Uint8List>(
                            future: form.pickedFile!.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done &&
                                  snapshot.data != null) {
                                return Image.memory(
                                  snapshot.data!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                );
                              }
                              return const SizedBox(
                                height: 100,
                                width: 100,
                                child:
                                Center(child: CircularProgressIndicator()),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectiveTabBody(Objective objective) {
    final objectiveId = objective.id;
    if (objectiveId == null) {
      return const Center(child: Text("Erro: Objetivo sem ID."));
    }
    final pageController = _pageControllers.putIfAbsent(objectiveId, () => PageController());
    final problemsForThisObjective = _reportedProblemForms.putIfAbsent(objectiveId, () => []);

    if (problemsForThisObjective.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 60, color: AppColors.green300),
            const SizedBox(height: AppSpacing.medium),
            Text(
              "Nenhum problema identificado para este objetivo",
              style: TextStyle(fontSize: AppFontSize.fs18, color: AppColors.grey700),
            ),
            const SizedBox(height: AppSpacing.big),
            AppTextButton(
              onPressed: () => _addProblem(objectiveId),
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
            controller: pageController,
            itemCount: problemsForThisObjective.length,
            itemBuilder: (context, index) {
              return _buildProblemCard(objectiveId, problemsForThisObjective[index], index + 1);
            },
            onPageChanged: (index) {
              setState(() {});
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                },
              ),
              Text(() {
                // Verifica se o controller já foi anexado a uma PageView
                if (pageController.hasClients) {
                  return "Problema ${(pageController.page?.round() ?? 0) + 1} de ${problemsForThisObjective.length}";
                }
                // Se não, exibe a última página (que é a que será exibida)
                return "Problema ${problemsForThisObjective.length} de ${problemsForThisObjective.length}";
              }(),
                style: const TextStyle(fontSize: AppFontSize.fs14),
              ),

              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                },
              ),

              const Spacer(),

              AppTextButton(
                onPressed: () => _addProblem(objectiveId),
                text: 'Adicionar Problema',
                icon: Icons.add,
                backgroundColor: AppColors.grey200,
                textColor: AppColors.black,
                width: 200,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _blocConsumer() {
    return BlocConsumer<ProblemaBloc, ProblemaState>(
      bloc: _bloc,
      listener: _onChangeState,
      builder: (context, state) {
        switch (state) {
          case ProblemaInitial():
          case ProblemaLoading():
            return const AppLoading(color: AppColors.black);

          case ProblemaError(message: final message):
            return AppError(message: message);

          case ProblemaLoaded(
          objectives: final objectives,
          evaluation: final evaluation):
            return Container(
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
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: DefaultTabController(
                  length: objectives.length,
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(evaluation?.description ?? 'Reportar Problemas'),
                      backgroundColor: AppColors.grey900,
                      foregroundColor: AppColors.white,
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(kToolbarHeight),
                        child: Container(
                          color: AppColors.grey200,
                          child: TabBar(
                            isScrollable: true,
                            labelColor: AppColors.black,
                            unselectedLabelColor: AppColors.grey700,
                            indicatorColor: AppColors.black,
                            tabs: objectives
                                .map((obj) =>
                                Tab(text: obj.description ?? 'Objetivo'))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    body: TabBarView(
                      children: objectives.map(_buildObjectiveTabBody).toList(),
                    ),
                    bottomNavigationBar: _buildFooter(),
                  ),
                ),
              ),
            );

          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: Center(
        child: _blocConsumer(),
      ),
    );
  }

  @override
  void dispose() {
    for (var formList in _reportedProblemForms.values) {
      for (var form in formList) {
        form.dispose();
      }
    }
    _bloc.close();
    super.dispose();
  }
}