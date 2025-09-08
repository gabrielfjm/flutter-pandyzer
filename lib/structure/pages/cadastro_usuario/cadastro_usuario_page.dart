import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';

import 'package:flutter_pandyzer/structure/pages/cadastro_usuario/cadastro_usuario_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/cadastro_usuario/cadastro_usuario_event.dart';
import 'package:flutter_pandyzer/structure/pages/cadastro_usuario/cadastro_usuario_state.dart';

import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_field.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

enum _Role { cliente, avaliador }

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final CadastroUsuarioBloc _bloc = CadastroUsuarioBloc();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  _Role? _selectedRole;

  bool _obscureSenha = true;
  bool _obscureConfirma = true;

  static const double _shellMaxWidth = 1100;
  static const double _shellMinHeight = 680;
  static const double _formWidth = 460;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _voltar() => Navigator.of(context).pop();

  void _cadastrar() {
    if (_nomeController.text.isEmpty) {
      showAppToast(context: context, message: AppStrings.mensagemNomeEstaVazio, isError: true);
      return;
    }
    if (_emailController.text.isEmpty) {
      showAppToast(context: context, message: AppStrings.mensagemEmailEstaVazio, isError: true);
      return;
    }
    if (_senhaController.text.isEmpty) {
      showAppToast(context: context, message: AppStrings.mensagemSenhaEstaVazia, isError: true);
      return;
    }
    if (_confirmarSenhaController.text.isEmpty) {
      showAppToast(context: context, message: AppStrings.mensagemConfirmarSenhaEstaVazio, isError: true);
      return;
    }
    if (_senhaController.text != _confirmarSenhaController.text) {
      showAppToast(context: context, message: AppStrings.mensagemSenhasInformadasNaoCoincidem, isError: true);
      return;
    }
    if (_selectedRole == null) {
      showAppToast(context: context, message: AppStrings.mensagemSelecioneOTipoDeUsuario, isError: true);
      return;
    }

    _bloc.add(
      CadastrarEvent(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        isAvaliador: _selectedRole == _Role.avaliador,
      ),
    );
  }

  Future<void> _onChangeState(CadastroUsuarioState state) async {
    if (state is CadastroUsuarioSuccesState) _voltar();
    if (state is CadastroUsuarioError) {
      showAppToast(context: context, message: state.message ?? 'Erro ao cadastrar', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<CadastroUsuarioBloc, CadastroUsuarioState>(
        bloc: _bloc,
        listener: (context, state) => _onChangeState(state),
        builder: (context, state) {
          if (state is CadastroUsuarioLoadingState) return const AppLoading();

          return Center(
            child: LayoutBuilder(builder: (context, c) {
              final h = MediaQuery.of(context).size.height;
              final shellHeight = h < _shellMinHeight + 80 ? _shellMinHeight : (h - 80);

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _shellMaxWidth,
                  minHeight: _shellMinHeight,
                  maxHeight: shellHeight,
                ),
                child: _Shell(
                  left: const _LeftPanel(),
                  right: _RightPanel(
                    nomeController: _nomeController,
                    emailController: _emailController,
                    senhaController: _senhaController,
                    confirmarSenhaController: _confirmarSenhaController,
                    obscureSenha: _obscureSenha,
                    obscureConfirma: _obscureConfirma,
                    onToggleSenha: () => setState(() => _obscureSenha = !_obscureSenha),
                    onToggleConfirma: () => setState(() => _obscureConfirma = !_obscureConfirma),
                    selectedRole: _selectedRole,
                    onChangeRole: (r) => setState(() => _selectedRole = r),
                    onSubmit: _cadastrar,
                    onBack: _voltar,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// ——— Shell com borda contínua ———
class _Shell extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _Shell({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(16),
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
    );
  }
}

/// ——— Lado esquerdo ———
class _LeftPanel extends StatelessWidget {
  const _LeftPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 40, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(text: 'Crie sua conta', fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.white),
          const SizedBox(height: 8),
          appText(text: 'Registre-se para começar a avaliar e criar projetos.', color: Colors.white70),
          const Spacer(),
          appText(text: 'Preto & Branco. Sem ruído.\nFoco total no seu trabalho.', color: Colors.white54),
        ],
      ),
    );
  }
}

/// ——— Lado direito ———
class _RightPanel extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final TextEditingController confirmarSenhaController;

  final bool obscureSenha;
  final bool obscureConfirma;
  final VoidCallback onToggleSenha;
  final VoidCallback onToggleConfirma;

  final _Role? selectedRole;
  final ValueChanged<_Role?> onChangeRole;

  final VoidCallback onSubmit;
  final VoidCallback onBack;

  static const double _formWidth = _CadastroUsuarioPageState._formWidth;

  const _RightPanel({
    super.key,
    required this.nomeController,
    required this.emailController,
    required this.senhaController,
    required this.confirmarSenhaController,
    required this.obscureSenha,
    required this.obscureConfirma,
    required this.onToggleSenha,
    required this.onToggleConfirma,
    required this.selectedRole,
    required this.onChangeRole,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              onSubmit();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _formWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho com Voltar
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Voltar',
                          onPressed: onBack,
                          icon: const Icon(AppIcons.arrowBack, size: 18),
                        ),
                        const SizedBox(width: 8),
                        appText(text: AppStrings.cadastro, fontWeight: FontWeight.w800, fontSize: 18),
                      ],
                    ),
                    const SizedBox(height: 6),
                    appText(text: 'Preencha seus dados para criar a conta.', color: Colors.black54),
                    const SizedBox(height: 20),

                    AppTextField(label: AppStrings.nomeDoUsuario, controller: nomeController, width: _formWidth),
                    const SizedBox(height: 12),
                    AppTextField(label: AppStrings.email, controller: emailController, width: _formWidth),
                    const SizedBox(height: 12),

                    AppTextField(
                      label: AppStrings.senha,
                      controller: senhaController,
                      obscureText: obscureSenha,
                      width: _formWidth,
                      suffixIcon: IconButton(
                        tooltip: obscureSenha ? 'Mostrar senha' : 'Ocultar senha',
                        icon: Icon(obscureSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: onToggleSenha,
                      ),
                    ),
                    const SizedBox(height: 12),

                    AppTextField(
                      label: AppStrings.confirmarSenha,
                      controller: confirmarSenhaController,
                      obscureText: obscureConfirma,
                      width: _formWidth,
                      suffixIcon: IconButton(
                        tooltip: obscureConfirma ? 'Mostrar senha' : 'Ocultar senha',
                        icon: Icon(obscureConfirma ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: onToggleConfirma,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ===== TIPO DE USUÁRIO (Radios estilizados) =====
                    appText(
                      text: AppStrings.selecioneOTipoDeUsuario,
                      fontSize: AppFontSize.fs15,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 8),
                    _RoleTile(
                      title: 'Gerente de Produto',
                      subtitle: 'Cria avaliações e gerencia os resultados.',
                      icon: Icons.business_center_outlined,
                      value: _Role.cliente,
                      groupValue: selectedRole,
                      onChanged: onChangeRole,
                    ),
                    const SizedBox(height: 8),
                    _RoleTile(
                      title: 'Avaliador',
                      subtitle: 'Participa realizando as avaliações.',
                      icon: Icons.verified_user_outlined,
                      value: _Role.avaliador,
                      groupValue: selectedRole,
                      onChanged: onChangeRole,
                    ),

                    const SizedBox(height: 20),

                    // Botão Cadastrar (mesma largura)
                    SizedBox(
                      width: _formWidth,
                      height: 44,
                      child: AppTextButton(
                        text: AppStrings.cadastrar,
                        onPressed: onSubmit,
                        icon: AppIcons.check,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
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

/// Tile de papel com Radio estilizado
class _RoleTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final _Role value;
  final _Role? groupValue;
  final ValueChanged<_Role?> onChanged;

  const _RoleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  State<_RoleTile> createState() => _RoleTileState();
}

class _RoleTileState extends State<_RoleTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.groupValue == widget.value;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => widget.onChanged(widget.value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.grey100 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.black : (_hover ? AppColors.grey700 : AppColors.grey600),
              width: 1.2,
            ),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]
                : const [],
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 20, color: AppColors.black),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appText(text: widget.title, fontWeight: FontWeight.w700),
                    const SizedBox(height: 2),
                    Text(widget.subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ),
              Radio<_Role>(
                value: widget.value,
                groupValue: widget.groupValue,
                onChanged: widget.onChanged,
                activeColor: AppColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
