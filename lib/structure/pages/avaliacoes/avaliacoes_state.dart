import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';

abstract class AvaliacoesState {}

class AvaliacoesInitial extends AvaliacoesState {}

class AvaliacoesLoading extends AvaliacoesState {}

class AvaliacaoCamposLoaded extends AvaliacoesState{
  final List<ApplicationType> dominios;

  AvaliacaoCamposLoaded(this.dominios);
}

class AvaliacaoCadastrada extends AvaliacoesState{}

class AvaliacoesLoaded extends AvaliacoesState {
  final List<Evaluation> avaliacoes;

  AvaliacoesLoaded(this.avaliacoes);
}

class AvaliacoesError extends AvaliacoesState {
  String message;

  AvaliacoesError(this.message);
}
