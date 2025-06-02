import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/pages/cadastro_usuario/cadastro_usuario_page.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_event.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_state.dart';
import 'package:flutter_pandyzer/structure/pages/main_page.dart';
import 'package:flutter_pandyzer/structure/pages/perfil/perfil_page.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_field.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginBloc _bloc = LoginBloc();

  late AppTextField emailField;
  late AppTextField senhaField;

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  _onChangeState(LoginState state) async {
    if(state is LoginSuccesState){
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', state.usuario!.id.toString());

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainPage()),
            (route) => false,
      );
    }

    if(state is LoginError){
      showAppToast(
        context: context,
        message: state.message!,
        isError: true,
      );
    }
  }

  @override
  void initState() {
    emailField = AppTextField(
      label: AppStrings.email,
      controller: _emailController,
    );

    senhaField = AppTextField(
      label: AppStrings.senha,
      controller: _senhaController,
    );

    super.initState();
  }

  void _criarConta() {
    NavigationManager().goTo(const PerfilPage());
  }

  void _logar() {
    if(_emailController.text == AppStrings.empty){
      showAppToast(
        context: context,
        message: AppStrings.mensagemEmailEstaVazio,
        isError: true,
      );
      return;
    }

    if(_senhaController.text == AppStrings.empty){
      showAppToast(
        context: context,
        message: AppStrings.mensagemSenhaEstaVazia,
        isError: true,
      );
      return;
    }

    _bloc.add(
      LogarEvent(
        email: _emailController.text,
        senha: _senhaController.text,
      ),
    );
  }

  Widget formLogin(){
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              spreadRadius: 3,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            appText(
              text: 'Login',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 75,
              child: AppTextField(
                controller: _emailController,
                label: AppStrings.email,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 75,
              child: AppTextField(
                controller: _senhaController,
                label: AppStrings.senha,
                obscureText: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  // AppTextButton(
                  //   width: 110,
                  //   text: AppStrings.criarConta,
                  //   onPressed: () => _criarConta(),
                  //   backgroundColor: AppColors.transparent,
                  //   textColor: AppColors.black,
                  // ),
                  // appSizedBox(width: 20),
                  AppTextButton(
                    width: 150,
                    text: AppStrings.entrar,
                    onPressed: () => _logar(),
                    icon: AppIcons.login,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CadastroUsuarioPage()),
                      );
                    },
                    child: Text(
                      'Não tem uma conta? Cadastre-se aqui.',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget body(){
    return Scaffold(
      backgroundColor: AppColors.grey900,
      body: Center(
        child: formLogin(),
      ),
    );
  }

  Widget _blocConsumer() {
    return BlocConsumer<LoginBloc, LoginState>(
      bloc: _bloc,
      listener: (context, state) => _onChangeState(state),
      builder: (context, state) {
        switch(state.runtimeType){
          case LoginLoading:
            return const AppLoading();
          case LoginInitial:
          case LoginError:
            return body();
          default:
            return appSizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _blocConsumer();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}
