import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_convert.dart';

// MODELS
import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/EvaluationViewData.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Status.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';

// REPOSITORY
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'avaliacoes_event.dart';
import 'avaliacoes_state.dart';

class AvaliacoesBloc extends Bloc<AvaliacoesEvent, AvaliacoesState> {
  AvaliacoesBloc() : super(AvaliacoesInitial()) {
    on<LoadAvaliacoesEvent>((event, emit) async {
      emit(AvaliacoesLoading(oldState: state));
      try {
        final prefs = await SharedPreferences.getInstance();
        final userIdStr = prefs.getString('userId');
        if (userIdStr == null) throw Exception('Usuário não logado');
        final userId = int.parse(userIdStr);

        // 1) pega tudo que me interessa
        final results = await Future.wait([
          AvaliacoesRepository.getByCreator(userId),          // criei
          AvaliacoesRepository.getByEvaluatorUser(userId),    // sou avaliador (N O V O)
          AvaliacoesRepository.getCommunityEvaluations(userId), // públicas de outros
        ]);

        // 2) une criadas + onde sou avaliador (sem duplicar)
        final created = results[0] as List<Evaluation>;
        final asEvaluator = results[1] as List<Evaluation>;
        final communityRaw = results[2] as List<Evaluation>;

        final Map<int, Evaluation> mineMap = {};
        for (final e in [...created, ...asEvaluator]) {
          if (e.id != null) mineMap[e.id!] = e;
        }
        final mineList = mineMap.values.toList();

        // 3) processa (descobrindo se sou avaliador e se tenho problemas etc.)
        final myProcessed = await Future.wait(
          mineList.map((e) => _processEvaluation(e, userIdStr)),
        );
        final communityProcessed = await Future.wait(
          communityRaw.map((e) => _processEvaluation(e, userIdStr)),
        );

        // 4) guarda “minhas” (tudo que criei OU onde sou avaliador)
        final myEvaluations = myProcessed;

        // 5) comunidade = públicas que não estão em “minhas”
        final myIds = myEvaluations.map((v) => v.evaluation.id).toSet();
        final communityEvaluations = communityProcessed
            .where((v) =>
        v.evaluation.isPublic == true && !myIds.contains(v.evaluation.id))
            .toList();

        emit(AvaliacoesLoaded(
          myEvaluations: myEvaluations,
          communityEvaluations: communityEvaluations,
        ));
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    on<LoadCamposCadastroAvaliacao>((event, emit) async {
      emit(AvaliacoesLoading(oldState: state));
      try {
        final results = await Future.wait([
          AvaliacoesRepository.getApplicationTypes(),
          AvaliacoesRepository.getUsuariosAvaliadores(0),
        ]);

        emit(AvaliacaoCamposLoaded(
          dominios: results[0] as List<ApplicationType>,
          availableEvaluators: results[1] as List<User>,
        ));
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    on<CadastrarAvaliacaoEvent>((event, emit) async {
      emit(AvaliacoesLoading(oldState: state));
      try {
        final prefs = await SharedPreferences.getInstance();
        final userIdStr = prefs.getString('userId');
        if (userIdStr == null) {
          emit(AvaliacoesError(message: 'Usuário não autenticado.'));
          return;
        }

        final creator =
        await AvaliacoesRepository.getUsuarioById(int.parse(userIdStr));
        final nowIso = DateTime.now().toIso8601String();

        final avaliadores = List<User>.from(event.avaliadores);
        if (avaliadores.isEmpty && (creator.userType?.description == 'Avaliador')) {
          avaliadores.add(creator);
        }

        final avaliacao = Evaluation(
          description: event.descricao,
          link: event.link,
          startDate: AppConvert.convertDateToIso(event.dataInicio),
          finalDate: AppConvert.convertDateToIso(event.dataFim),
          applicationType: event.tipoAplicacao,
          user: creator,
          register: nowIso,
          isPublic: event.isPublic,
          evaluatorsLimit: event.limit,
        );

        final created = await AvaliacoesRepository.insertAvaliacao(avaliacao);

        for (final desc in event.objetivos) {
          await AvaliacoesRepository.insertObjetivo(
            Objective(description: desc, evaluation: created, register: nowIso),
          );
        }

        final Status statusNaoIniciada =
        await AvaliacoesRepository.getStatusById(3);

        for (final u in avaliadores) {
          await AvaliacoesRepository.insertAvaliador(
            Evaluator(
              user: u,
              evaluation: created,
              register: nowIso,
              status: statusNaoIniciada,
            ),
          );
        }

        emit(AvaliacaoCadastrada());
        add(LoadAvaliacoesEvent());
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    on<ApplyFiltersEvent>((event, emit) async {
      try {
        emit(AvaliacoesLoading(oldState: state));

        // chama o /evaluations/filter com title/status/creatorId
        final filtered = await AvaliacoesRepository.filter(
          description: event.description,
          statusId: event.status?.id,
          creatorId: event.creatorId,
        );

        final prefs = await SharedPreferences.getInstance();
        final userIdStr = prefs.getString('userId') ?? '';
        final userId = int.tryParse(userIdStr);

        // processa para descobrir relação do usuário
        final processed = await Future.wait(
          filtered.map((e) => _processEvaluation(e, userIdStr)),
        );

        // separa como o “carregamento padrão”:
        final myEvaluations = processed.where((v) {
          final isOwner = (v.evaluation.user?.id == userId);
          final isEvaluator = (v.evaluation.isCurrentUserAnEvaluator == true);
          return isOwner || isEvaluator;
        }).toList();

        final myIds = myEvaluations.map((v) => v.evaluation.id).toSet();
        final communityEvaluations = processed
            .where((v) =>
        v.evaluation.isPublic == true && !myIds.contains(v.evaluation.id))
            .toList();

        emit(AvaliacoesLoaded(
          myEvaluations: myEvaluations,
          communityEvaluations: communityEvaluations,
        ));
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    on<LoadEvaluationDetailsEvent>((event, emit) async {
      final s = state;
      emit(AvaliacoesLoading(oldState: s));
      try {
        final results = await Future.wait([
          AvaliacoesRepository.getEvaluationById(event.evaluationId),
          AvaliacoesRepository.getObjectivesByEvaluationId(event.evaluationId),
          AvaliacoesRepository.getApplicationTypes(),
          AvaliacoesRepository.getEvaluatorsByIdEvaluation(event.evaluationId),
          AvaliacoesRepository.getUsuariosAvaliadores(event.evaluationId),
        ]);

        emit(EvaluationDetailsLoaded(
          myEvaluations: s.myEvaluations,
          communityEvaluations: s.communityEvaluations,
          evaluation: results[0] as Evaluation,
          objectives: results[1] as List<Objective>,
          dominios: results[2] as List<ApplicationType>,
          evaluators: results[3] as List<Evaluator>,
          availableEvaluators: results[4] as List<User>,
        ));
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    on<UpdateAvaliacaoEvent>((event, emit) async {
      emit(AvaliacoesLoading(oldState: state));
      try {
        final prefs = await SharedPreferences.getInstance();
        final userIdStr = prefs.getString('userId');
        if (userIdStr == null) {
          emit(AvaliacoesError(message: 'Usuário não autenticado.'));
          return;
        }

        final creator =
        await AvaliacoesRepository.getUsuarioById(int.parse(userIdStr));
        final nowIso = DateTime.now().toIso8601String();

        await AvaliacoesRepository.updateAvaliacao(
          Evaluation(
            id: event.id,
            description: event.descricao,
            link: event.link,
            startDate: AppConvert.convertDateToIso(event.dataInicio),
            finalDate: AppConvert.convertDateToIso(event.dataFim),
            applicationType: event.tipoAplicacao,
            user: creator,
            register: nowIso,
            isPublic: event.isPublic,
            evaluatorsLimit: event.limit,
          ),
        );

        final antigosObjs =
        await AvaliacoesRepository.getObjectivesByEvaluationId(event.id);
        final antigosAvs =
        await AvaliacoesRepository.getEvaluatorsByIdEvaluation(event.id);

        final oldObjDesc = antigosObjs.map((o) => o.description).toSet();
        final newObjDesc = event.objetivos.toSet();

        final oldEvalUsers = antigosAvs.map((e) => e.user?.id).toSet();
        final newEvalUsers = event.avaliadores.map((u) => u.id).toSet();

        final toDeleteObj =
        antigosObjs.where((o) => !newObjDesc.contains(o.description));
        final toAddObj = newObjDesc.where((d) => !oldObjDesc.contains(d));

        final toDeleteEval =
        antigosAvs.where((ev) => !newEvalUsers.contains(ev.user?.id));
        final toAddUsers =
        event.avaliadores.where((u) => !oldEvalUsers.contains(u.id));

        final Status statusNaoIniciada =
        await AvaliacoesRepository.getStatusById(3);

        await Future.wait([
          ...toDeleteObj.map((o) => AvaliacoesRepository.deleteObjetivo(o.id!)),
          ...toDeleteEval.map((ev) => AvaliacoesRepository.deleteAvaliador(ev.id!)),
          ...toAddObj.map((desc) => AvaliacoesRepository.insertObjetivo(
            Objective(
              description: desc,
              evaluation: Evaluation(id: event.id),
              register: nowIso,
            ),
          )),
          ...toAddUsers.map((u) => AvaliacoesRepository.insertAvaliador(
            Evaluator(
              user: u,
              evaluation: Evaluation(id: event.id),
              register: nowIso,
              status: statusNaoIniciada,
            ),
          )),
        ]);

        emit(AvaliacaoUpdated());
        add(LoadAvaliacoesEvent());
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    on<DeleteAvaliacaoEvent>((event, emit) async {
      final s = state;
      emit(AvaliacoesLoading(oldState: s));
      try {
        final evaluators =
        await AvaliacoesRepository.getEvaluatorsByIdEvaluation(event.evaluationId);
        final objectives =
        await AvaliacoesRepository.getObjectivesByEvaluationId(event.evaluationId);

        await Future.wait([
          ...evaluators.map((e) => AvaliacoesRepository.deleteAvaliador(e.id!)),
          ...objectives.map((o) => AvaliacoesRepository.deleteObjetivo(o.id!)),
        ]);

        await AvaliacoesRepository.deleteAvaliacao(event.evaluationId);

        emit(AvaliacaoDeleted(
          myEvaluations: s.myEvaluations,
          communityEvaluations: s.communityEvaluations,
        ));

        add(LoadAvaliacoesEvent());
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    on<DeleteEvaluatorAndProblems>((event, emit) async {
      try {
        final objectives =
        await AvaliacoesRepository.getObjectivesByEvaluationId(event.evaluationId);

        await Future.forEach(objectives, (Objective o) async {
          if (o.id != null) {
            final problems =
            await AvaliacoesRepository.getProblemsByIdObjetivoAndIdEvaluator(
              o.id!,
              event.evaluatorUserId,
            );
            await Future.wait(
              problems
                  .where((p) => p.id != null)
                  .map((p) => AvaliacoesRepository.deleteProblem(p.id!)),
            );
          }
        });

        await AvaliacoesRepository.deleteAvaliador(event.evaluatorRecordId);

        add(LoadEvaluationDetailsEvent(event.evaluationId));
        add(LoadAvaliacoesEvent());
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    // >>>>> Correção 1: usar 'evaluatorId:' <<<<<
    on<StartEvaluationEvent>((event, emit) async {
      final previousState = state;
      emit(StartEvaluationLoading(oldState: previousState));
      try {
        await AvaliacoesRepository.startEvaluation(
          evaluatorId: event.evaluatorUserId,
          evaluationId: event.evaluationId,
        );
        emit(
          StartEvaluationSuccess(
            evaluatorUserId: event.evaluatorUserId,
            evaluationId: event.evaluationId,
            oldState: previousState,
          ),
        );
        add(LoadEvaluationDetailsEvent(event.evaluationId));
        add(LoadAvaliacoesEvent());
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    // >>>>> Correção 2: dois posicionais (userId, statusId) <<<<<
    on<FinalizeEvaluation>((event, emit) async {
      try {
        await AvaliacoesRepository.updateEvaluatorStatus(
          event.evaluatorUserId,
          event.statusId,
          evaluationId: event.evaluationId,
        );
        add(LoadEvaluationDetailsEvent(event.evaluationId));
        add(LoadAvaliacoesEvent());
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });
  }

  Future<EvaluationViewData> _processEvaluation(
      Evaluation e,
      String currentUserId,
      ) async {
    if (e.id == null) return EvaluationViewData(evaluation: e);

    final evaluators = await AvaliacoesRepository.getEvaluatorsByIdEvaluation(e.id!);

    // ▼▼▼ ADICIONE estas 4 linhas ▼▼▼
    final total = evaluators.length;
    final completed = evaluators.where((x) => x.status?.id == 2).length; // 2 = Concluída
    final notStarted = evaluators.where((x) => x.status?.id == 3).length; // 3 = Não iniciada
    e
      ..totalEvaluatorsCount = total
      ..completedEvaluationsCount = completed  // você já tinha essa linha; mantenha!
      ..notStartedEvaluationsCount = notStarted;
    // ▲▲▲ ADICIONE estas 4 linhas ▲▲▲

    // (resto do método continua igual)
    e.completedEvaluationsCount =
        evaluators.where((x) => x.status?.id == 2).length;

    Evaluator? me;
    try {
      me = evaluators.firstWhere((x) => x.user?.id.toString() == currentUserId);
      e.isCurrentUserAnEvaluator = true;
    } catch (_) {
      e.isCurrentUserAnEvaluator = false;
    }

    if (e.isCurrentUserAnEvaluator) {
      final objectives = await AvaliacoesRepository.getObjectivesByEvaluationId(e.id!);
      var myProblems = 0;
      await Future.forEach(objectives, (Objective o) async {
        if (o.id != null) {
          final probs = await AvaliacoesRepository
              .getProblemsByIdObjetivoAndIdEvaluator(
            o.id!,
            int.parse(currentUserId),
          );
          myProblems += probs.length;
        }
      });
      e.currentUserHasProblems = myProblems > 0;
    }

    return EvaluationViewData(evaluation: e, currentUserAsEvaluator: me);
  }

}
