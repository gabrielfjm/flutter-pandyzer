import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/EvaluationViewData.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_repository.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import '../../../widgets/avaliacao_card.dart';

class ComunidadeAvaliacoesTab extends StatefulWidget {
  final String? currentUserId;
  final void Function(EvaluationViewData) onPerform;
  final void Function(int evaluationId) onView;
  final void Function(int evaluationId) onEdit;
  final void Function(EvaluationViewData) onDelete;
  final void Function(Evaluation evaluation) onJoin;

  const ComunidadeAvaliacoesTab({
    super.key,
    required this.currentUserId,
    required this.onPerform,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onJoin,
  });

  @override
  State<ComunidadeAvaliacoesTab> createState() => _ComunidadeAvaliacoesTabState();
}

class _ComunidadeAvaliacoesTabState extends State<ComunidadeAvaliacoesTab> {
  bool _loading = true;
  final List<Evaluation> _items = [];
  final Map<int, _EvalMeta> _meta = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items.clear();
      _meta.clear();

      final uid = int.tryParse(widget.currentUserId ?? '');
      final list = await AvaliacoesRepository.getCommunityEvaluations(uid ?? 0);

      for (final e in list) {
        if (e.id == null || e.isPublic != true) continue;

        int currentCount = 0;
        List<Evaluator> evaluators = const [];
        try {
          evaluators = await AvaliacoesRepository.getEvaluatorsByIdEvaluation(e.id!);
          currentCount = evaluators.length;
        } catch (_) {}

        final limit = e.evaluatorsLimit ?? 0;
        final hasSlots = limit <= 0 ? true : currentCount < limit;
        if (!hasSlots) continue;

        final isOwner = (e.user?.id != null && e.user!.id == uid);

        Evaluator? me;
        bool isCurrentUserEvaluator = false;
        bool currentUserHasStarted = false;

        if (uid != null) {
          me = evaluators.firstWhere(
                (ev) => ev.user?.id == uid,
            orElse: () => Evaluator(),
          );
          if (me.id != null) {
            isCurrentUserEvaluator = true;
            currentUserHasStarted = (me.status?.id != 3); // 3 = Não iniciada
          }
        }

        _items.add(e);
        _meta[e.id!] = _EvalMeta(
          isOwner: isOwner,
          isCurrentUserEvaluator: isCurrentUserEvaluator,
          currentUserHasStarted: currentUserHasStarted,
          currentUserEvaluator: (me?.id != null) ? me : null,
          hasSlots: hasSlots,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: AppLoading(color: AppColors.black));
    }

    // ✅ Sempre rolável e sem overflow, mesmo com filtros abertos
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_items.isEmpty) {
          // Estado vazio rolável (para evitar overflow quando a área útil fica pequena)
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: _emptyState(
                  title: 'Sem atividades públicas',
                  message:
                  'No momento não há avaliações públicas disponíveis para ingressar.\n'
                      'Tente novamente mais tarde ou crie uma nova avaliação.',
                  onRefresh: _load,
                ),
              ),
            ),
          );
        }

        // Lista rolável (com pull-to-refresh opcional)
        return RefreshIndicator(
          color: AppColors.black,
          onRefresh: _load,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final e = _items[i];
              final meta = _meta[e.id] ?? _EvalMeta.empty();

              final showJoinButton =
                  e.isPublic == true && !meta.isCurrentUserEvaluator && meta.hasSlots;

              final viewData = EvaluationViewData(
                evaluation: e,
                currentUserAsEvaluator: meta.currentUserEvaluator,
              );

              return AvaliacaoCard(
                evaluation: e,
                isOwner: meta.isOwner,
                isCurrentUserAnEvaluator: meta.isCurrentUserEvaluator,
                currentUserHasStarted: meta.currentUserHasStarted,
                onPerform: () => widget.onPerform(viewData),
                onView: () => widget.onView(e.id!),
                onEdit: () => widget.onEdit(e.id!),
                onDelete: () => widget.onDelete(viewData),
                showJoinButton: showJoinButton,
                onJoin: showJoinButton ? () => widget.onJoin(e) : null,
              );
            },
          ),
        );
      },
    );
  }

  Widget _emptyState({
    required String title,
    required String message,
    VoidCallback? onRefresh,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.black, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.public_off, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.black54, height: 1.35),
            textAlign: TextAlign.center,
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Atualizar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.black, width: 1),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EvalMeta {
  final bool isOwner;
  final bool isCurrentUserEvaluator;
  final bool currentUserHasStarted;
  final Evaluator? currentUserEvaluator;
  final bool hasSlots;

  const _EvalMeta({
    required this.isOwner,
    required this.isCurrentUserEvaluator,
    required this.currentUserHasStarted,
    required this.currentUserEvaluator,
    required this.hasSlots,
  });

  factory _EvalMeta.empty() => const _EvalMeta(
    isOwner: false,
    isCurrentUserEvaluator: false,
    currentUserHasStarted: false,
    currentUserEvaluator: null,
    hasSlots: false,
  );
}
