import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_repository.dart';
import 'avaliacoes_event.dart';
import 'avaliacoes_state.dart';

class AvaliacoesBloc extends Bloc<AvaliacoesEvent, AvaliacoesState> {

  AvaliacoesBloc() : super(AvaliacoesInitial()) {
    on<LoadAvaliacoesEvent>((event, emit) async {
      emit(AvaliacoesLoading());
      try {
        List<Evaluation> avaliacoes = await AvaliacoesRepository.getAvaliacoes();
        emit(AvaliacoesLoaded(avaliacoes));
      } catch (e) {
        emit(AvaliacoesError('Erro ao carregar avaliações'));
      }
    });
  }
}
