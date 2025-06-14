import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_convert.dart';
import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Status.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'avaliacoes_event.dart';
import 'avaliacoes_state.dart';

class AvaliacoesBloc extends Bloc<AvaliacoesEvent, AvaliacoesState> {

  AvaliacoesBloc() : super(AvaliacoesInitial()) {
    on<LoadAvaliacoesEvent>((event, emit) async {
      emit(AvaliacoesLoading(oldState: state));
      try {
        // 1. Busca a lista principal de avaliações
        List<Evaluation> avaliacoes = await AvaliacoesRepository.getAvaliacoes();

        // 2. Para cada avaliação, busca a contagem de avaliadores concluídos
        // Usamos Future.wait para fazer as chamadas em paralelo e melhorar a performance
        final countFutures = avaliacoes.map((avaliacao) async {
          if (avaliacao.id != null) {
            final evaluators = await AvaliacoesRepository.getEvaluatorsByIdEvaluation(avaliacao.id!);
            // Filtra e conta aqueles com status "Concluída" (assumindo ID 2)
            final completedCount = evaluators.where((e) => e.status?.id == 2).length;
            // Atribui a contagem ao objeto no Flutter
            avaliacao.completedEvaluationsCount = completedCount;
          }
        }).toList();

        // 3. Espera todas as chamadas de contagem terminarem
        await Future.wait(countFutures);

        // 4. Emite o estado com a lista de avaliações, agora com a contagem populada
        emit(AvaliacoesLoaded(avaliacoes: avaliacoes));
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    on<LoadCamposCadastroAvaliacao>((event, emit) async {
      emit(AvaliacoesLoading());
      try {
        final results = await Future.wait([
          AvaliacoesRepository.getDominios(),
          AvaliacoesRepository.getUsuariosAvaliadores(),
        ]);

        final dominios = results[0] as List<ApplicationType>;
        final avaliadores = results[1] as List<User>;

        emit(AvaliacaoCamposLoaded(
          dominios: dominios,
          availableEvaluators: avaliadores,
        ));
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    on<CadastrarAvaliacaoEvent>((event, emit) async {
      emit(AvaliacoesLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');
        if (userId == null) {
          emit(AvaliacoesError(message: "Usuário não autenticado."));
          return;
        }

        final creator = await AvaliacoesRepository.getUsuarioById(int.parse(userId));
        final now = DateTime.now().toIso8601String();

        List<User> finalAvaliadores = List.from(event.avaliadores);
        if (finalAvaliadores.isEmpty && creator.userType?.description == 'Avaliador') {
          finalAvaliadores.add(creator);
        }

        Evaluation avaliacao = Evaluation(
          description: event.descricao,
          link: event.link,
          startDate: AppConvert.convertDateToIso(event.dataInicio),
          finalDate: AppConvert.convertDateToIso(event.dataFim),
          applicationType: event.tipoAplicacao,
          user: creator,
          register: now,
        );

        Evaluation avaliacaoCadastrada = await AvaliacoesRepository.createAvaliacao(avaliacao);

        for (final objetivo in event.objetivos) {
          Objective obj = Objective(
            description: objetivo,
            evaluation: avaliacaoCadastrada,
            register: now,
          );
          await AvaliacoesRepository.createObjetivo(obj);
        }

        Status statusEmAndamento = await AvaliacoesRepository.getStatusById(1);

        for (final userAvaliador in finalAvaliadores) {
          final novoAvaliador = Evaluator(
            user: userAvaliador,
            evaluation: avaliacaoCadastrada,
            register: now,
            status: statusEmAndamento,
          );
          await AvaliacoesRepository.createAvaliador(novoAvaliador);
        }

        emit(AvaliacaoCadastrada());
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    on<LoadEvaluationDetailsEvent>((event, emit) async {
      final currentState = state;
      emit(AvaliacoesLoading(oldState: currentState));
      try {
        final results = await Future.wait([
          AvaliacoesRepository.getAvaliacoesById(event.evaluationId),
          AvaliacoesRepository.getObjectivesByEvaluationId(event.evaluationId),
          AvaliacoesRepository.getDominios(),
          AvaliacoesRepository.getEvaluatorsByIdEvaluation(event.evaluationId),
          AvaliacoesRepository.getAvaliacoes(),
          AvaliacoesRepository.getUsuariosAvaliadores(),
        ]);

        final evaluation = results[0] as Evaluation;
        final objectives = results[1] as List<Objective>;
        final dominios = results[2] as List<ApplicationType>;
        final selectedEvaluators = results[3] as List<Evaluator>;
        final allEvaluations = results[4] as List<Evaluation>;
        final availableEvaluators = results[5] as List<User>;

        emit(EvaluationDetailsLoaded(
          avaliacoes: allEvaluations,
          evaluation: evaluation,
          objectives: objectives,
          dominios: dominios,
          evaluators: selectedEvaluators,
          availableEvaluators: availableEvaluators,
        ));
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    on<UpdateAvaliacaoEvent>((event, emit) async {
      final currentState = state;
      emit(AvaliacoesLoading(oldState: currentState));
      try {

        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');
        if (userId == null) {
          emit(AvaliacoesError(message: "Usuário não autenticado."));
          return;
        }

        final creator = await AvaliacoesRepository.getUsuarioById(int.parse(userId));
        final now = DateTime.now().toIso8601String();

        final evaluationToUpdate = Evaluation(
          id: event.id,
          description: event.descricao,
          link: event.link,
          startDate: AppConvert.convertDateToIso(event.dataInicio),
          finalDate: AppConvert.convertDateToIso(event.dataFim),
          applicationType: event.tipoAplicacao,
          user: creator,
          register: now,
        );
        await AvaliacoesRepository.putAvaliacao(evaluationToUpdate);

        final objetivosAntigos = await AvaliacoesRepository.getObjectivesByEvaluationId(event.id);
        final avaliadoresAntigos = await AvaliacoesRepository.getEvaluatorsByIdEvaluation(event.id);

        final descricoesObjetivosAntigos = objetivosAntigos.map((o) => o.description).toSet();
        final idsAvaliadoresAntigos = avaliadoresAntigos.map((e) => e.user?.id).toSet();

        final descricoesObjetivosNovos = event.objetivos.toSet();
        final idsAvaliadoresNovos = event.avaliadores.map((u) => u.id).toSet();

        final objetivosParaDeletar = objetivosAntigos.where((obj) => !descricoesObjetivosNovos.contains(obj.description));
        final descricoesParaAdicionar = descricoesObjetivosNovos.where((desc) => !descricoesObjetivosAntigos.contains(desc));

        final avaliadoresParaDeletar = avaliadoresAntigos.where((ev) => !idsAvaliadoresNovos.contains(ev.user?.id));
        final usuariosParaAdicionar = event.avaliadores.where((user) => !idsAvaliadoresAntigos.contains(user.id));

        final statusEmAndamento = await AvaliacoesRepository.getStatusById(2);

        await Future.wait([
          ...objetivosParaDeletar.map((obj) => AvaliacoesRepository.deleteObjetivo(obj.id!)),
          ...avaliadoresParaDeletar.map((ev) => AvaliacoesRepository.deleteEvaluator(ev.id!)),

          ...descricoesParaAdicionar.map((desc) {
            final novoObjetivo = Objective(description: desc, evaluation: Evaluation(id: event.id), register: now);
            return AvaliacoesRepository.createObjetivo(novoObjetivo);
          }),

          ...usuariosParaAdicionar.map((user) {
            final novoAvaliador = Evaluator(user: user, evaluation: Evaluation(id: event.id), register: now, status: statusEmAndamento);
            return AvaliacoesRepository.createAvaliador(novoAvaliador);
          }),
        ]);

        emit(AvaliacaoUpdated());
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    on<DeleteAvaliacaoEvent>((event, emit) async {
      final currentState = state;
      emit(AvaliacoesLoading(oldState: currentState));
      try {
        final evaluatorsToDelete = await AvaliacoesRepository.getEvaluatorsByIdEvaluation(event.evaluationId);
        final objectivesToDelete = await AvaliacoesRepository.getObjectivesByEvaluationId(event.evaluationId);

        await Future.wait([
          ...evaluatorsToDelete.map((e) => AvaliacoesRepository.deleteEvaluator(e.id!)),
          ...objectivesToDelete.map((o) => AvaliacoesRepository.deleteObjetivo(o.id!)),
        ]);

        await AvaliacoesRepository.deleteAvaliacao(event.evaluationId);

        final updatedList = await AvaliacoesRepository.getAvaliacoes();

        emit(AvaliacaoDeleted(avaliacoes: updatedList));
      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });

    on<DeleteEvaluatorAndProblems>((event, emit) async {
      final currentState = state;
      emit(AvaliacoesLoading(oldState: currentState));
      try {
        // Busca todos os objetivos da avaliação para saber onde procurar os problemas
        final objectives = await AvaliacoesRepository.getObjectivesByEvaluationId(event.evaluationId);

        // Deleta todos os problemas feitos por este avaliador nesta avaliação
        await Future.forEach(objectives, (objective) async {
          if (objective.id != null) {
            // Pega os problemas do avaliador para este objetivo
            final problemsToDelete = await AvaliacoesRepository.getProblemsByIdObjetivoAndIdEvaluator(objective.id!, event.evaluatorId);
            // Deleta cada problema encontrado
            await Future.wait(problemsToDelete.map((p) => AvaliacoesRepository.deleteProblem(p.id!)));
          }
        });

        // Após deletar os problemas, deleta o registro do avaliador
        await AvaliacoesRepository.deleteEvaluator(event.evaluatorId);

        // Recarrega os dados da avaliação para refletir a remoção do avaliador
        add(LoadEvaluationDetailsEvent(event.evaluationId));

      } catch (e) {
        emit(AvaliacoesError(message: e.toString()));
      }
    });
  }
}
