import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/pages/home/home_page.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_event.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_state.dart';
import 'package:flutter_pandyzer/structure/pages/perfil/perfil_page.dart';
import 'package:flutter_pandyzer/structure/widgets/app_error.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_field.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart';

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

  _onChangeState(LoginState state) {
    if(state is LoginSuccesState){
      NavigationManager().goTo(const HomePage());
    }

    if(state is LoginError){
      showAppToast(
        context: context,
        message: state.message,
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
    return Container(
      width: AppSizes.s200, // Largura do card/container do formulário
      padding: EdgeInsets.all(AppSizes.s24), // Padding interno para o card
      decoration: BoxDecoration( // Para dar a aparência de card como na imagem
        color: Theme.of(context).cardColor, // Ou AppColors.white se preferir
        borderRadius: BorderRadius.circular(AppSizes.s12), // Bordas arredondadas para o card
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente dentro do SizedBox
        crossAxisAlignment: CrossAxisAlignment.stretch, // Estica os botões
        mainAxisSize: MainAxisSize.min, // Para a Column interna se ajustar ao conteúdo
        children: [
          // 1. Logo e Título/Subtítulo
          // Substitua 'assets/logo.png' pelo caminho do seu logo
          // Image.asset('assets/logo_uxhub.png', height: AppSizes.s60), // Ajuste o tamanho
          // appSizedBox(height: AppSizes.s8),
          // appText(
          //   text: AppStrings.nielsenHeuristics, // Crie esta string
          //   textAlign: TextAlign.center,
          //   fontSize: AppSizes.s16, // Ajuste
          //   color: AppColors.grey, // Ajuste
          // ),
          // OU, se você tiver um widget de cabeçalho específico:
          // AppHeader(),

          // Se o título "Login" for como o da imagem ("UxHub"),
          // você pode usar um widget de imagem para o logo e um Text para o subtítulo.
          // Por ora, vou manter seu "appText(text: AppStrings.login)" e você ajusta.

          // Título principal do formulário (se for diferente do logo/header)
          appText(
            text: AppStrings.login, // Ou "Acesse sua conta"
            textAlign: TextAlign.center,
            fontSize: AppSizes.s24, // Tamanho maior para o título
            fontWeight: FontWeight.bold,
          ),
          appSizedBox(height: AppSizes.s32), // Espaço maior após o título
          emailField,
          appSizedBox(height: AppSizes.s16),
          senhaField,
          appSizedBox(height: AppSizes.s8),
          Align(
            alignment: Alignment.centerRight,
            child: AppTextButton(
              width: 175,
              text: AppStrings.esqueciMinhaSenha, // Crie esta string
              onPressed: () {
                print("Esqueci minha senha clicado");
                showAppToast(context: context, message: "Funcionalidade 'Esqueci minha senha' não implementada.", isError: false);
              },
              // Estilo para parecer um link (sem ícone, cor de texto primária)
              // Se AppTextButton não permitir customização fina, use TextButton:
              // TextButton(
              //   onPressed: () {},
              //   child: appText(text: AppStrings.esqueciMinhaSenha, color: Theme.of(context).primaryColor),
              // ),
              fontSize: AppFontSize.fs15, // Tamanho menor para o link
              // Se AppTextButton não tiver 'color' direto, ajuste dentro do seu widget
            ),
          ),
          appSizedBox(height: AppSizes.s24), // Espaço antes do botão principal

          // 5. Botão "ENTRAR"
          // Seu AppTextButton já tem 'icon'. Verifique se AppIcons.login é uma seta ->
          // Se não, crie AppIcons.arrowForward ou use um Icon(Icons.arrow_forward)
          AppTextButton(
            text: AppStrings.entrar.toUpperCase(), // ENTRAR em maiúsculas como na imagem
            onPressed: _logar,
            icon: AppIcons.login, // Ou AppIcons.arrowForward
            // Para o botão principal ser mais destacado (se AppTextButton for só texto):
            // Considere usar ElevatedButton para o botão principal
            // ElevatedButton(
            //   onPressed: _logar,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       appText(text: AppStrings.entrar.toUpperCase(), color: AppColors.white),
            //       appSizedBox(width: AppSizes.s8),
            //       Icon(AppIcons.arrowForward, color: AppColors.white),
            //     ],
            //   ),
            //   style: ElevatedButton.styleFrom(
            //      backgroundColor: Theme.of(context).primaryColor, // Cor de fundo
            //      padding: EdgeInsets.symmetric(vertical: AppSizes.s16),
            //   ),
            // ),
          ),
          appSizedBox(height: AppSizes.s24), // Espaço antes do link de cadastro

          // 6. Texto e Link de Cadastro
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              appText(
                text: AppStrings.naoPossuiConta, // "Não possui conta? "
                fontSize: AppFontSize.fs15,
              ),
              AppTextButton(
                width: 115,// Ou TextButton
                text: AppStrings.cliqueAqui, // "Clique Aqui"
                onPressed: _criarConta, // Sua função _criarConta
                fontSize: AppFontSize.fs15,
                //fontWeight: FontWeight.bold, // Para destacar o "Clique Aqui"
                // color: Theme.of(context).primaryColor, // Cor do link
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget body(){
    return formLogin();
  }

  Widget _blocListener() {
    return BlocListener<LoginBloc, LoginState>(
      bloc: _bloc,
      listener: (context, state) => _onChangeState(state),
      child: BlocBuilder<LoginBloc, LoginState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is LoginLoading) {
            return const AppLoading();
          } else if (state is LoginInitial) {
            return body();
          } else if (state is LoginError) {
            return body();
          } else {
            return appSizedBox();
          }
        },
      ),
    );
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _blocListener(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}
