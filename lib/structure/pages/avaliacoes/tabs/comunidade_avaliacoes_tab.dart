import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/structure/http/models/EvaluationViewData.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_state.dart';
import 'package:flutter_pandyzer/structure/widgets/app_error.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/structure/widgets/avaliacao_card.dart';

class ComunidadeAvaliacoesTab extends StatelessWidget {
  final String? currentUserId;
  final Function(EvaluationViewData) onPerform;
  final Function(int) onView;
  final Function(int) onEdit;
  final Function(EvaluationViewData) onDelete;

  const ComunidadeAvaliacoesTab({
    super.key,
    required this.currentUserId,
    required this.onPerform,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvaliacoesBloc, AvaliacoesState>(
      builder: (context, state) {
        if (state is AvaliacoesLoading && state.communityEvaluations.isEmpty) {
          return const AppLoading(color: AppColors.black);
        }

        if (state is AvaliacoesError) {
          return const AppError();
        }

        if (state.communityEvaluations.isEmpty) {
          return Center(child: appText(text: 'Nenhuma avaliação pública encontrada.', color: AppColors.black));
        }

        return _buildList(state.communityEvaluations);
      },
    );
  }

  Widget _buildList(List<EvaluationViewData> evaluations) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.medium),
      itemCount: evaluations.length,
      itemBuilder: (context, index) {
        final viewData = evaluations[index];
        final evaluation = viewData.evaluation;
        final isOwner = currentUserId != null && currentUserId == evaluation.user?.id.toString();

        return AvaliacaoCard(
          evaluation: evaluation,
          isOwner: isOwner,
          isCurrentUserAnEvaluator: evaluation.isCurrentUserAnEvaluator,
          currentUserHasStarted: viewData.currentUserHasStarted,
          onPerform: () => onPerform(viewData),
          onView: () => onView(evaluation.id!),
          onEdit: () => onEdit(evaluation.id!),
          onDelete: () => onDelete(viewData),
        );
      },
    );
  }
}