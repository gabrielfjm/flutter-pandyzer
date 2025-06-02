import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';

abstract class AvaliacoesState {
  List<ApplicationType> dominios;
  List<Evaluation> avaliacoes;

  AvaliacoesState({required this.dominios, required this.avaliacoes});
}

class AvaliacoesInitial extends AvaliacoesState {
  AvaliacoesInitial() : super(
    dominios: [],
    avaliacoes: [],
  );
}

class AvaliacoesLoading extends AvaliacoesState {
  AvaliacoesLoading() : super(
    dominios: [],
    avaliacoes: [],
  );
}

class AvaliacaoCamposLoaded extends AvaliacoesState{
  AvaliacaoCamposLoaded({required super.dominios}) : super(
    avaliacoes: [],
  );
}

class AvaliacaoCadastrada extends AvaliacoesState{
  AvaliacaoCadastrada() : super(
    dominios: [],
    avaliacoes: [],
  );
}

class AvaliacoesLoaded extends AvaliacoesState {
  AvaliacoesLoaded({required super.avaliacoes}) : super(
    dominios: [],
  );
}

class AvaliacoesError extends AvaliacoesState {
  AvaliacoesError() : super(
    dominios: [],
    avaliacoes: [],
  );
}
