import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_repository.dart';
import 'avaliacoes_event.dart';
import 'avaliacoes_state.dart';

class AvaliacoesBloc extends Bloc<AvaliacoesEvent, AvaliacoesState> {

  AvaliacoesBloc() : super(AvaliacoesInitial()) {
    on<LoadAvaliacoesEvent>((event, emit) async {
      emit(AvaliacoesLoading());
      try{
        List<Evaluation> avaliacoes = await AvaliacoesRepository.getAvaliacoes();
        return emit(AvaliacoesLoaded(avaliacoes));
      } catch (e) {
        emit(AvaliacoesError('Erro ao carregar avaliações'));
      }
    });

    on<LoadCamposCadastroAvaliacao>((event, emit) async {
      //emit(AvaliacoesLoading());
      try{
        List<ApplicationType> dominios = await AvaliacoesRepository.getDominios();

        return emit(AvaliacaoCamposLoaded(dominios));
      }catch (e){
        emit(AvaliacoesError('Erro ao carregar avaliações'));
      }
    });

    on<CadastrarAvaliacaoEvent>((event, emit) async {
      emit(AvaliacoesLoading());
      try {

        Evaluation avaliacao = new Evaluation(
          description: event.descricao,
          link: event.link,
          startDate: event.dataInicio,
          finalDate: event.dataFim,
        );

        AvaliacoesRepository.createAvaliacao(avaliacao);

        emit(AvaliacaoCadastrada());
      } catch (e) {
        emit(AvaliacoesError('Erro ao carregar avaliações'));
      }
    });
  }
}
