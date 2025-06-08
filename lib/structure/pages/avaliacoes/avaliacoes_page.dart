import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_event.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_state.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/modal/avaliacoes_detalhes_modal.dart';
import 'package:flutter_pandyzer/structure/widgets/app_container.dart';
import 'package:flutter_pandyzer/structure/widgets/app_error.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart';
import 'package:flutter_pandyzer/structure/widgets/avaliacao_card.dart';
import 'cadastro/cadastro_avaliacoes_page.dart';

class AvaliacoesPage extends StatefulWidget {
  const AvaliacoesPage({super.key});

  @override
  State<AvaliacoesPage> createState() => _AvaliacoesPageState();
}

class _AvaliacoesPageState extends State<AvaliacoesPage> {
  final AvaliacoesBloc _bloc = AvaliacoesBloc();

  @override
  void initState() {
    super.initState();
    _bloc.add(LoadAvaliacoesEvent());
  }

  void _onChangeState(AvaliacoesState state) {
    if (state is EvaluationDetailsLoaded) {
      _showDetailsModal(
          context, state.evaluation!, state.objectives, state.evaluators ?? []);
    }

    if (state is AvaliacaoDeleted) {
      showAppToast(context: context, message: "Avaliação excluída com sucesso!");
    }

    if (state is AvaliacoesError) {
      showAppToast(context: context, message: state.message ?? "Ocorreu um erro", isError: true);
    }
  }

  void _addAvaliacao() {
    NavigationManager().goTo(CadastroAvaliacoesPage(bloc: _bloc));
  }

  void _editAvaliacao(int evaluationId) {
    NavigationManager().goTo(CadastroAvaliacoesPage(
      bloc: _bloc,
      evaluationId: evaluationId,
    ));
  }

  void _viewAvaliacao(int evaluationId) {
    _bloc.add(LoadEvaluationDetailsEvent(evaluationId));
  }

  void _showDetailsModal(BuildContext context, Evaluation evaluation,
      List<Objective> objectives, List<Evaluator> evaluators) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AvaliacoesDetalhesModal(
          evaluation: evaluation,
          objectives: objectives,
          evaluators: evaluators,
        );
      },
    );
  }

  void _deleteAvaliacao(Evaluation evaluation) {
    if (evaluation.id == null) return;
    _showDeleteConfirmationDialog(evaluation);
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
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

  Widget header() {
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

  Widget filters() {
    return Row(
      children: [
        const Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Filtrar avaliações...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        appSizedBox(width: AppSpacing.big),
        AppTextButton(
          text: AppStrings.avaliacao,
          icon: AppIcons.add,
          width: AppSizes.s150,
          onPressed: () => _addAvaliacao(),
        ),
      ],
    );
  }

  Widget list(List<Evaluation> avaliacoes) {
    if (avaliacoes.isEmpty) {
      return Center(
        child: appText(
          text: 'Nenhuma avaliação disponível.',
          color: AppColors.black,
        ),
      );
    }
    return ListView.builder(
      itemCount: avaliacoes.length,
      itemBuilder: (context, index) {
        return AvaliacaoCard(
          evaluation: avaliacoes[index],
          onView: () => _viewAvaliacao(avaliacoes[index].id!),
          onEdit: () => _editAvaliacao(avaliacoes[index].id!),
          onDelete: () => _deleteAvaliacao(avaliacoes[index]),
        );
      },
    );
  }

  Widget body(List<Evaluation> avaliacoes) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.giant),
      child: appContainer(
        width: 1600,
        padding: const EdgeInsets.all(AppSpacing.big),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: AppColors.grey800,
          ),
          borderRadius: BorderRadius.circular(AppSizes.s10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header(),
            filters(),
            appSizedBox(height: 16),
            Expanded(child: list(avaliacoes)),
          ],
        ),
      ),
    );
  }

  Widget _blocConsumer() {
    return BlocConsumer<AvaliacoesBloc, AvaliacoesState>(
      bloc: _bloc,
      listener: (context, state) => _onChangeState(state),
      builder: (context, state) {
        switch (state) {
          case AvaliacoesLoading():
            return const AppLoading(color: AppColors.black);
          case EvaluationDetailsLoaded(avaliacoes: final avaliacoes):
          case AvaliacoesLoaded(avaliacoes: final avaliacoes):
          case AvaliacaoDeleted(avaliacoes: final avaliacoes):
            return body(avaliacoes);
          case AvaliacoesError():
            return AppError();
          default:
            return appSizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: _blocConsumer(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}