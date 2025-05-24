abstract class AvaliacoesEvent {}

class LoadAvaliacoesEvent extends AvaliacoesEvent {}

class AddAvaliacaoEvent extends AvaliacoesEvent {
  final String avaliacao;

  AddAvaliacaoEvent(this.avaliacao);
}
