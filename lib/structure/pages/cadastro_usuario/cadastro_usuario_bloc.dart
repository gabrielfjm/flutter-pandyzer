import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/structure/http/models/UserType.dart';
import 'package:flutter_pandyzer/structure/pages/cadastro_usuario/cadastro_usuario_event.dart';
import 'package:flutter_pandyzer/structure/pages/cadastro_usuario/cadastro_usuario_repository.dart';
import 'package:flutter_pandyzer/structure/pages/cadastro_usuario/cadastro_usuario_state.dart';


class CadastroUsuarioBloc extends Bloc<CadastroUsuarioEvent, CadastroUsuarioState> {
  CadastroUsuarioBloc() : super(CadastroUsuarioInitialState()) {
    on<CadastrarEvent>((event, emit) async {
      emit(CadastroUsuarioLoadingState());
      try{

        UserType tipoUsuario;
        if(event.isAvaliador){
          tipoUsuario = await CadastroUsuarioRepository.getUserTypeById(1);
        } else{
          tipoUsuario = await CadastroUsuarioRepository.getUserTypeById(2);
        }

        await CadastroUsuarioRepository.postUsuario(event.nome, event.email, event.senha, tipoUsuario);
        return emit(CadastroUsuarioSuccesState());
      } catch (e) {
        emit(CadastroUsuarioError(message: e.toString()));
      }
    });

    on<LoadCamposEvent>((event, emit) async {
      emit(CadastroUsuarioLoadingState());
      try{
        List<UserType> tiposUsuario = await CadastroUsuarioRepository.getUsersTypes();

        return emit(CadastroUsuarioLoadSuccesState(tiposUsuario: tiposUsuario));
      } catch (e) {
        emit(CadastroUsuarioError(message: e.toString()));
      }
    });
  }
}