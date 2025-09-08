import 'package:flutter/material.dart';

import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/pages/profile/profile_repository.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart'; // showAppToast

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _loadingUser = true;
  bool _saving = false;

  final _editFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loadingUser = true);
    try {
      final u = await ProfileRepository.fetchCurrentUser();
      setState(() {
        _user = u;
        _nameCtrl.text = u.name ?? '';
        _emailCtrl.text = u.email ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      showAppToast(
        context: context,
        message: 'Falha ao carregar perfil: $e',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _loadingUser = false);
    }
  }

  String _firstLetter(String? s) {
    if (s == null || s.isEmpty) return 'U';
    return s.characters.first.toUpperCase();
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  Future<void> _openEditDialog() async {
    _passwordCtrl.clear();
    _passwordConfirmCtrl.clear();

    await showGeneralDialog(
      context: context,
      barrierLabel: 'Editar perfil',
      barrierColor: Colors.black54,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, anim1, anim2) {
        final width = MediaQuery.of(ctx).size.width;
        final maxW = width.clamp(0, 720).toDouble();
        final dialogWidth = maxW > 560 ? 560.0 : maxW - 40;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _editFormKey,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Cabeçalho do diálogo
                        Row(
                          children: [
                            const Icon(Icons.edit, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Atualizar dados cadastrais',
                              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'Fechar',
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Campos
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameCtrl,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Nome',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Informe seu nome';
                                  }
                                  if (v.trim().length < 3) {
                                    return 'Nome muito curto';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _emailCtrl,
                                enabled: false, // e-mail não editável
                                decoration: const InputDecoration(
                                  labelText: 'E-mail (não editável)',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Tooltip(
                                    message:
                                    'O e-mail não pode ser alterado nesta versão.',
                                    child: Icon(Icons.lock_outline),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Senha (opcional)
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding:
                          const EdgeInsets.only(bottom: 4, top: 4),
                          title: const Text('Alterar senha (opcional)'),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _passwordCtrl,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Nova senha',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) {
                                      if (v != null &&
                                          v.isNotEmpty &&
                                          v.length < 6) {
                                        return 'Mínimo 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _passwordConfirmCtrl,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Confirmar nova senha',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) {
                                      if ((_passwordCtrl.text.isNotEmpty ||
                                          (v?.isNotEmpty ?? false)) &&
                                          v != _passwordCtrl.text) {
                                        return 'As senhas não coincidem';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Dica: deixe em branco se não quiser alterar a senha.',
                                style: Theme.of(ctx)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Theme.of(ctx).hintColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Ações
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _saving
                                    ? null
                                    : () async {
                                  if (!(_editFormKey.currentState
                                      ?.validate() ??
                                      false)) return;

                                  if (_user == null || _user!.id == null) {
                                    showAppToast(
                                      context: context,
                                      message: 'Usuário inválido',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  final newPass =
                                  _passwordCtrl.text.trim();
                                  setState(() => _saving = true);
                                  try {
                                    final updated =
                                    await ProfileRepository.updateUser(
                                      userId: _user!.id!,
                                      name: _nameCtrl.text.trim(),
                                      email: _emailCtrl.text.trim(),
                                      newPassword: newPass.isNotEmpty
                                          ? newPass
                                          : null,
                                    );
                                    setState(() => _user = updated);
                                    if (mounted) Navigator.pop(ctx);
                                    showAppToast(
                                      context: context,
                                      message:
                                      'Perfil atualizado com sucesso!',
                                    );
                                  } catch (e) {
                                    showAppToast(
                                      context: context,
                                      message: 'Erro ao salvar: $e',
                                      isError: true,
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => _saving = false);
                                    }
                                  }
                                },
                                icon: _saving
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                    AlwaysStoppedAnimation(
                                        Colors.white),
                                  ),
                                )
                                    : const Icon(Icons.save),
                                label: const Text('Salvar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: .98, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildCover(BuildContext context) {
    final name = _user?.name ?? 'Usuário';
    final email = _user?.email ?? '';
    final initial = _firstLetter(_user?.name);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Capa
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.85),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
        // Avatar sobreposto
        Positioned(
          left: 16,
          bottom: -36,
          child: CircleAvatar(
            radius: 48,
            backgroundColor: Colors.black,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Nome + e-mail
        Positioned(
          left: 120,
          bottom: 8,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sobre',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.alternate_email_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _user?.email ?? '—',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.badge_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _user?.name ?? '—',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Página embutida na MainPage (sem Scaffold aqui).
    return RefreshIndicator(
      onRefresh: _loadUser,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_loadingUser)
                    Container(
                      height: 220,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    )
                  else ...[
                    _buildCover(context),
                    const SizedBox(height: 48), // espaço do avatar
                    // Botão de editar perfil — destaque
                    SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _openEditDialog,
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar perfil'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAboutCard(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
