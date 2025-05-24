abstract class AvaliacoesState {}

class AvaliacoesInitial extends AvaliacoesState {}

class AvaliacoesLoading extends AvaliacoesState {}

class AvaliacoesLoaded extends AvaliacoesState {
  final List<String> avaliacoes;

  AvaliacoesLoaded(this.avaliacoes);
}

class AvaliacoesError extends AvaliacoesState {
  String message;

  AvaliacoesError(this.message);
}
