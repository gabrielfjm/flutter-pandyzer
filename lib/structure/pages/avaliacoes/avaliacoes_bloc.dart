import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_repository.dart';
import 'avaliacoes_event.dart';
import 'avaliacoes_state.dart';

class AvaliacoesBloc extends Bloc<AvaliacoesEvent, AvaliacoesState> {

  AvaliacoesBloc() : super(AvaliacoesInitial()) {
    on<LoadAvaliacoesEvent>((event, emit) async {
      emit(AvaliacoesLoading());
      try {
        final avaliacoes = await AvaliacoesRepository.fetchAvaliacoes();
        emit(AvaliacoesLoaded(avaliacoes));
      } catch (e) {
        emit(AvaliacoesError('Erro ao carregar avaliações'));
      }
    });

    on<AddAvaliacaoEvent>((event, emit) async {
      if (state is AvaliacoesLoaded) {
        final current = (state as AvaliacoesLoaded).avaliacoes;
        final updated = List<String>.from(current)..add(event.avaliacao);
        emit(AvaliacoesLoaded(updated));
      }
    });
  }
}
