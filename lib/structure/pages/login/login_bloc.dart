import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_event.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_state.dart';

import 'login_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LogarEvent>((event, emit) async {
      emit(LoginLoading());
      try{
        User usuario = await LoginRepository.postLogin(event.email, event.senha);
        return emit(LoginSuccesState(usuario: usuario));
      } catch (e) {
        emit(LoginError(message: 'Erro ao verificar Login'));
      }
    });
  }
}