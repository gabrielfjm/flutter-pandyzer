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

/// Caminho da logo (mesmo usado na AppBar)
const String _logoAssetPath = 'assets/images/logo_app_bar.png';

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

  const _Shell({
    required this.left,
    required this.right,
    required this.height,
  });

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
          clipBehavior: Clip.hardEdge,
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

/// Painel esquerdo: textos no topo + LOGO totalmente centralizada e grande
class _LeftPanel extends StatelessWidget {
  const _LeftPanel();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Tamanho da logo proporcional à altura do painel
        final double side = (c.maxHeight * 0.5).clamp(220.0, 420.0);

        return Stack(
          children: [
            // Título e subtítulo no topo com padding
            Positioned(
              left: 40,
              right: 40,
              top: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appText(
                    text: 'Crie sua conta',
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 8),
                  appText(
                    text: 'Registre-se para começar a avaliar e criar projetos.',
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            // Logo centralizada no painel inteiro
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
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (intent) {
            onSubmit();
            return null;
          }),
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
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Voltar',
                          onPressed: onBack,
                          icon: const Icon(AppIcons.arrowBack, size: 18),
                        ),
                        const SizedBox(width: 8),
                        appText(
                          text: AppStrings.cadastro,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    appText(
                      text: 'Preencha seus dados para criar a conta.',
                      color: Colors.black54,
                    ),
                    const SizedBox(height: 20),

                    AppTextField(
                      label: AppStrings.nomeDoUsuario,
                      controller: nomeController,
                      width: _formWidth,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: AppStrings.email,
                      controller: emailController,
                      width: _formWidth,
                    ),
                    const SizedBox(height: 12),

                    AppTextField(
                      label: AppStrings.senha,
                      controller: senhaController,
                      obscureText: obscureSenha,
                      width: _formWidth,
                      suffixIcon: IconButton(
                        tooltip: obscureSenha ? 'Mostrar senha' : 'Ocultar senha',
                        icon: Icon(
                          obscureSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                        ),
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
                        icon: Icon(
                          obscureConfirma ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: onToggleConfirma,
                      ),
                    ),

                    const SizedBox(height: 18),

                    appText(
                      text: AppStrings.selecioneOTipoDeUsuario,
                      fontSize: AppFontSize.fs15,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 8),

                    _RoleCard(
                      title: 'Gerente de Produto',
                      subtitle: 'Cria avaliações e gerencia os resultados.',
                      icon: Icons.business_center_outlined,
                      value: _Role.cliente,
                      groupValue: selectedRole,
                      onChanged: onChangeRole,
                    ),
                    _RoleCard(
                      title: 'Avaliador',
                      subtitle: 'Participa realizando as avaliações.',
                      icon: Icons.verified_user_outlined,
                      value: _Role.avaliador,
                      groupValue: selectedRole,
                      onChanged: onChangeRole,
                    ),

                    const SizedBox(height: 20),

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
                    const SizedBox(height: 24),
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

/// Card de seleção de perfil (clipado, sem sombra)
class _RoleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final _Role value;
  final _Role? groupValue;
  final ValueChanged<_Role?> onChanged;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.groupValue == widget.value;
    final borderColor =
    selected ? AppColors.black : (_hover ? AppColors.grey700 : AppColors.grey600);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () => widget.onChanged(widget.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? AppColors.grey100 : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: selected ? 1.8 : 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: AppColors.black, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      appText(text: widget.title, fontWeight: FontWeight.w700),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Radio<_Role>(
                  value: widget.value,
                  groupValue: widget.groupValue,
                  onChanged: widget.onChanged,
                  activeColor: AppColors.black,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
