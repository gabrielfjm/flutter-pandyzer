import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_convert.dart';
import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'avaliacoes_event.dart';
import 'avaliacoes_state.dart';

class AvaliacoesBloc extends Bloc<AvaliacoesEvent, AvaliacoesState> {

  AvaliacoesBloc() : super(AvaliacoesInitial()) {
    on<LoadAvaliacoesEvent>((event, emit) async {
      emit(AvaliacoesLoading());
      try{
        List<Evaluation> avaliacoes = await AvaliacoesRepository.getAvaliacoes();
        emit(AvaliacoesLoaded(avaliacoes: avaliacoes));
      } catch (e) {
        emit(AvaliacoesError());
      }
    });

    on<LoadCamposCadastroAvaliacao>((event, emit) async {
      emit(AvaliacoesLoading());
      try{
        List<ApplicationType> dominios = await AvaliacoesRepository.getDominios();

        emit(AvaliacaoCamposLoaded(dominios: dominios));
      }catch (e){
        emit(AvaliacoesError());
      }
    });

    on<CadastrarAvaliacaoEvent>((event, emit) async {
      emit(AvaliacoesLoading());
      try {

        final prefs = await SharedPreferences.getInstance();
        int idUsuario = int.parse(prefs.getString('userId')!);

        User user = await AvaliacoesRepository.getUsuarioById(idUsuario);

        // Pega a data e hora atual uma única vez no formato ISO 8601
        final String now = DateTime.now().toIso8601String();

        Evaluation avaliacao = new Evaluation(
          description: event.descricao,
          link: event.link,
          startDate: AppConvert.convertDateToIso(event.dataInicio),
          finalDate: AppConvert.convertDateToIso(event.dataFim),
          applicationType: event.tipoAplicacao,
          user: user,
          register: now,
        );

        Evaluation avaliacaoCadastrada = await AvaliacoesRepository.createAvaliacao(avaliacao);

        for(final objetivo in event.objetivos){

          Objective obj = new Objective(
            id: null,
            description: objetivo,
            evaluation: avaliacaoCadastrada,
            register: now,
          );

          await AvaliacoesRepository.createObjetivo(obj);
        }

        emit(AvaliacaoCadastrada());
      } catch (e) {
        emit(AvaliacoesError());
      }
    });

    on<LoadEvaluationDetailsEvent>((event, emit) async {
      try {
        final results = await Future.wait([
          AvaliacoesRepository.getAvaliacoesById(event.evaluationId),
          AvaliacoesRepository.getObjectivesByEvaluationId(event.evaluationId),
          AvaliacoesRepository.getDominios(),
          AvaliacoesRepository.getEvaluatorsByIdEvaluation(event.evaluationId),
          AvaliacoesRepository.getAvaliacoes(),
        ]);

        final evaluation = results[0] as Evaluation;
        final objectives = results[1] as List<Objective>;
        final dominios = results[2] as List<ApplicationType>;
        final evaluators = results[3] as List<Evaluator>;
        final avaliacoes = results[4] as List<Evaluation>;

        emit(EvaluationDetailsLoaded(
          avaliacoes: avaliacoes,
          evaluation: evaluation,
          objectives: objectives,
          dominios: dominios,
          evaluators: evaluators,
        ));
      } catch (e) {
        emit(AvaliacoesError());
      }
    });

    on<UpdateAvaliacaoEvent>((event, emit) async {
      emit(AvaliacoesLoading());
      try {

        final objetivosAntigos = await AvaliacoesRepository.getObjectivesByEvaluationId(event.id);
        final descricoesAntigas = objetivosAntigos.map((o) => o.description).toSet();
        final descricoesNovas = event.objetivos.toSet();

        final objetivosParaDeletar = objetivosAntigos
            .where((obj) => !descricoesNovas.contains(obj.description));
        final descricoesParaAdicionar = descricoesNovas
            .where((desc) => !descricoesAntigas.contains(desc));

        await Future.wait([
          ...objetivosParaDeletar
              .map((obj) => AvaliacoesRepository.deleteObjetivo(obj.id!)),
          ...descricoesParaAdicionar.map((desc) {
            final novoObjetivo = Objective(
              description: desc,
              evaluation: Evaluation(id: event.id),
              register: DateTime.now().toIso8601String(),
            );
            return AvaliacoesRepository.createObjetivo(novoObjetivo);
          }),
        ]);

        emit(AvaliacaoUpdated());
      } catch (e) {
        emit(AvaliacoesError());
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
  }
}
