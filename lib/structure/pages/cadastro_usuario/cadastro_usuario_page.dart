import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/pages/cadastro_usuario/cadastro_usuario_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/cadastro_usuario/cadastro_usuario_event.dart';
import 'package:flutter_pandyzer/structure/pages/cadastro_usuario/cadastro_usuario_state.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_event.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_state.dart';
import 'package:flutter_pandyzer/structure/pages/main_page.dart';
import 'package:flutter_pandyzer/structure/pages/perfil/perfil_page.dart';
import 'package:flutter_pandyzer/structure/widgets/app_icon_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_field.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPage();
}

class _CadastroUsuarioPage extends State<CadastroUsuarioPage> {
  final CadastroUsuarioBloc _bloc = CadastroUsuarioBloc();

  late AppTextField nomeField;
  late AppTextField emailField;
  late AppTextField senhaField;
  late AppTextField confirmarSenhaField;

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _isCliente = false;
  bool _isAvaliador = false;

  _onChangeState(CadastroUsuarioState state) async {
    if(state is CadastroUsuarioSuccesState){
      _voltar();
    }

    if(state is CadastroUsuarioError){
      showAppToast(context: context, message: state.message!, isError: true);
    }
  }

  @override
  void initState() {
    nomeField = AppTextField(
      label: AppStrings.nomeDoUsuario,
      controller: _nomeController,
    );

    emailField = AppTextField(
      label: AppStrings.email,
      controller: _emailController,
    );

    senhaField = AppTextField(
      label: AppStrings.senha,
      controller: _senhaController,
    );

    confirmarSenhaField = AppTextField(
      label: AppStrings.confirmarSenha,
      controller: _confirmarSenhaController,
    );

    super.initState();
  }

  void _voltar() {
    Navigator.of(context).pop();
  }

  void _cadastrar() {
    if(_nomeController.text == AppStrings.empty){
      showAppToast(
        context: context,
        message: AppStrings.mensagemNomeEstaVazio,
        isError: true,
      );
      return;
    }

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

    if(_confirmarSenhaController.text == AppStrings.empty){
      showAppToast(
        context: context,
        message: AppStrings.mensagemConfirmarSenhaEstaVazio,
        isError: true,
      );
      return;
    }

    if(_senhaController.text != _confirmarSenhaController.text){
      showAppToast(
        context: context,
        message: AppStrings.mensagemSenhasInformadasNaoCoincidem,
        isError: true,
      );
      return;
    }

    if(!_isAvaliador && !_isCliente){
      showAppToast(
        context: context,
        message: AppStrings.mensagemSelecioneOTipoDeUsuario,
        isError: true,
      );
      return;
    }

    _bloc.add(
      CadastrarEvent(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        isAvaliador: _isAvaliador,
      ),
    );
  }

  Widget _buildCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('Cliente'),
          value: _isCliente,
          onChanged: (value) {
            setState(() {
              _isCliente = value!;
              if (value) _isAvaliador = false;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Avaliador'),
          value: _isAvaliador,
          onChanged: (value) {
            setState(() {
              _isAvaliador = value!;
              if (value) _isCliente = false;
            });
          },
        ),
      ],
    );
  }

  Widget formLogin(){
    return Scaffold(
      backgroundColor: AppColors.grey900,
      body: Center(
        child: Material(
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
                Row(
                  children: [
                    AppIconButton(
                      onPressed: _voltar,
                      icon: AppIcons.arrowBack,
                      iconColor: AppColors.black,
                    ),
                    const SizedBox(width: AppSpacing.small),
                    appText(
                      text: AppStrings.cadastro,
                      fontSize: AppFontSize.fs20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _nomeController,
                  label: AppStrings.nomeDoUsuario,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _senhaController,
                  label: AppStrings.senha,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmarSenhaController,
                  label: AppStrings.confirmarSenha,
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    appText(text: AppStrings.selecioneOTipoDeUsuario, fontSize: AppFontSize.fs15, fontWeight: FontWeight.bold),
                    _buildCheckboxes(),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: AppTextButton(
                    text: AppStrings.cadastrar,
                    onPressed: _cadastrar,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget body(){
    return formLogin();
  }

  Widget _blocConsumer() {
    return BlocConsumer<CadastroUsuarioBloc, CadastroUsuarioState>(
      bloc: _bloc,
      listener: (context, state) => _onChangeState(state),
      builder: (context, state) {
        switch(state.runtimeType){
          case CadastroUsuarioLoadingState:
            return const AppLoading();
          case CadastroUsuarioInitialState:
          case CadastroUsuarioError:
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
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }
}
