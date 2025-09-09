import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';

import 'package:flutter_pandyzer/structure/pages/cadastro_usuario/cadastro_usuario_page.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_event.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_state.dart';
import 'package:flutter_pandyzer/structure/pages/main_page.dart';

import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_field.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Caminho da logo (mesmo usado na AppBar)
const String _logoAssetPath = 'assets/images/logo_app_bar.png';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginBloc _bloc = LoginBloc();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _obscure = true;

  // medidas do cartão
  static const double _shellMaxWidth = 1100;
  static const double _shellMinHeight = 680;
  static const double _formWidth = 460;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _bloc.close();
    super.dispose();
  }

  Future<void> _onChangeState(LoginState state) async {
    if (state is LoginSuccesState) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', state.usuario!.id.toString());
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainPage()),
            (route) => false,
      );
    }
    if (state is LoginError) {
      showAppToast(
        context: context,
        message: state.message ?? 'Erro ao entrar',
        isError: true,
      );
    }
  }

  void _logar() {
    if (_emailController.text.isEmpty) {
      showAppToast(context: context, message: AppStrings.mensagemEmailEstaVazio, isError: true);
      return;
    }
    if (_senhaController.text.isEmpty) {
      showAppToast(context: context, message: AppStrings.mensagemSenhaEstaVazia, isError: true);
      return;
    }
    _bloc.add(LogarEvent(email: _emailController.text, senha: _senhaController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<LoginBloc, LoginState>(
        bloc: _bloc,
        listener: (context, state) => _onChangeState(state),
        builder: (context, state) {
          if (state is LoginLoading) return const AppLoading();

          return LayoutBuilder(
            builder: (context, c) {
              final media = MediaQuery.of(context);
              final safe = media.padding.top + media.padding.bottom;

              const outerPadding = 24.0;
              final availH = media.size.height - safe - (outerPadding * 2);
              final double cardHeight = availH.clamp(560.0, 760.0);

              final card = Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _shellMaxWidth),
                  child: _Shell(
                    height: cardHeight,
                    left: const _LeftPanel(),
                    right: _RightPanel(
                      emailController: _emailController,
                      senhaController: _senhaController,
                      obscure: _obscure,
                      onToggleObscure: () => setState(() => _obscure = !_obscure),
                      onSubmit: _logar,
                    ),
                  ),
                ),
              );

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(outerPadding),
                  child: card,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Shell extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double height;
  const _Shell({required this.left, required this.right, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Expanded(child: Container(color: AppColors.black, child: left)),
              Container(width: 1, color: Colors.black12),
              Expanded(child: right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painel esquerdo (título no topo + LOGO centralizada)
class _LeftPanel extends StatelessWidget {
  const _LeftPanel();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Tamanho da logo proporcional à altura
        final double side = (c.maxHeight * 0.5).clamp(220.0, 420.0);

        return Stack(
          children: [
            // Título e subtítulo no topo
            Positioned(
              left: 40,
              right: 40,
              top: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appText(
                    text: 'Boas-vindas',
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 8),
                  appText(
                    text: 'Acesse sua conta e continue suas avaliações.',
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            // Logo no centro do painel preto
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: side,
                  height: side,
                  child: Image.asset(
                    _logoAssetPath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Painel direito (form) — com Enter/NumpadEnter para enviar
class _RightPanel extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _RightPanel({
    super.key,
    required this.emailController,
    required this.senhaController,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  static const double _formWidth = 460;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.numpadEnter): const ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (intent) {
            onSubmit();
            return null;
          }),
        },
        child: Focus(
          autofocus: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _formWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        appText(text: 'Entrar', fontWeight: FontWeight.w800, fontSize: 18),
                      ],
                    ),
                    const SizedBox(height: 6),
                    appText(text: 'Use seu e-mail e senha para acessar.', color: Colors.black54),
                    const SizedBox(height: 20),

                    AppTextField(label: AppStrings.email, controller: emailController, width: _formWidth),
                    const SizedBox(height: 12),

                    AppTextField(
                      label: AppStrings.senha,
                      controller: senhaController,
                      obscureText: obscure,
                      width: _formWidth,
                      suffixIcon: IconButton(
                        tooltip: obscure ? 'Mostrar senha' : 'Ocultar senha',
                        icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: onToggleObscure,
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: _formWidth,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: onSubmit,
                        icon: const Icon(AppIcons.login, size: 16),
                        label: const Text('Entrar'),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastroUsuarioPage()));
                        },
                        child: const Text(
                          'Não tem uma conta? Cadastre-se aqui.',
                          style: TextStyle(decoration: TextDecoration.underline, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
