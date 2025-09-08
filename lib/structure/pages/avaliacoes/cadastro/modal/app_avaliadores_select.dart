import 'package:flutter/material.dart';

// CORE
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';

// MODELS
import 'package:flutter_pandyzer/structure/http/models/User.dart';

// WIDGETS CORE
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_container.dart';

/// Selector com botão + chips e um modal com busca/checkboxes
class AppAvaliadoresSelector extends StatefulWidget {
  final List<User> availableEvaluators;
  final List<User> selectedEvaluators;
  final ValueChanged<List<User>> onSelectionChanged;

  const AppAvaliadoresSelector({
    super.key,
    required this.availableEvaluators,
    required this.selectedEvaluators,
    required this.onSelectionChanged,
  });

  @override
  State<AppAvaliadoresSelector> createState() => _AppAvaliadoresSelectorState();
}

class _AppAvaliadoresSelectorState extends State<AppAvaliadoresSelector> {
  late List<User> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<User>.from(widget.selectedEvaluators);
  }

  @override
  void didUpdateWidget(covariant AppAvaliadoresSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // mantém sincronizado caso mudança venha de fora
    if (oldWidget.selectedEvaluators != widget.selectedEvaluators) {
      _selected = List<User>.from(widget.selectedEvaluators);
    }
  }

  String _displayUser(User u) {
    final maybe = [
      // tente diversos campos comuns
      // ignore: deprecated_member_use_from_same_package
      _safe(u, ['name', 'fullName', 'username', 'userName']),
      _safe(u, ['email']),
      u.id?.toString()
    ].where((e) => e != null && e!.trim().isNotEmpty).first;
    return maybe ?? 'Usuário';
  }

  String? _safe(User u, List<String> keys) {
    // tenta acessar propriedades comuns por reflexão básica via toJson quando disponível
    try {
      final map = (u as dynamic).toJson?.call() as Map<String, dynamic>?;
      if (map != null) {
        for (final k in keys) {
          final v = map[k];
          if (v is String && v.trim().isNotEmpty) return v;
        }
      }
    } catch (_) {}
    // fallback por getters mais prováveis
    for (final k in keys) {
      try {
        final v = (u as dynamic)?.toJson == null
            ? (u as dynamic)
            : null; // preferimos map — mas manter estrutura
      } catch (_) {}
    }
    // tentativas diretas
    try {
      final v = (u as dynamic).name as String?;
      if (v != null && v.trim().isNotEmpty) return v;
    } catch (_) {}
    try {
      final v = (u as dynamic).userName as String?;
      if (v != null && v.trim().isNotEmpty) return v;
    } catch (_) {}
    try {
      final v = (u as dynamic).email as String?;
      if (v != null && v.trim().isNotEmpty) return v;
    } catch (_) {}
    return null;
  }

  void _openModal() async {
    final updated = await showDialog<List<User>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AvaliadoresModal(
        all: widget.availableEvaluators,
        initiallySelected: _selected,
        displayFn: _displayUser,
      ),
    );

    if (updated != null) {
      setState(() => _selected = updated);
      widget.onSelectionChanged(_selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return appContainer(
      padding: const EdgeInsets.all(AppSpacing.big),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.s10),
        border: Border.all(color: AppColors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            children: [
              Icon(AppIcons.users, size: 18, color: AppColors.black),
              const SizedBox(width: 6),
              appText(
                text: 'Avaliadores selecionados',
                fontWeight: FontWeight.w600,
                fontSize: AppFontSize.fs16,
                color: AppColors.black,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _openModal,
                icon: const Icon(Icons.add),
                label: const Text('Selecionar avaliadores'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 20, thickness: 1, color: Colors.black12),
          const SizedBox(height: 6),

          // chips dos selecionados
          if (_selected.isEmpty)
            appText(text: 'Nenhum avaliador selecionado.', color: AppColors.grey800)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selected
                  .map(
                    (u) => Chip(
                  label: Text(_displayUser(u)),
                  onDeleted: () {
                    setState(() => _selected.remove(u));
                    widget.onSelectionChanged(_selected);
                  },
                  shape: StadiumBorder(side: BorderSide(color: AppColors.black, width: 1)),
                  backgroundColor: AppColors.white,
                  deleteIconColor: AppColors.black,
                ),
              )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

/// Modal estilizado com busca e seleção múltipla
class _AvaliadoresModal extends StatefulWidget {
  final List<User> all;
  final List<User> initiallySelected;
  final String Function(User) displayFn;

  const _AvaliadoresModal({
    required this.all,
    required this.initiallySelected,
    required this.displayFn,
  });

  @override
  State<_AvaliadoresModal> createState() => _AvaliadoresModalState();
}

class _AvaliadoresModalState extends State<_AvaliadoresModal> {
  final _searchCtrl = TextEditingController();
  late List<User> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = List<User>.from(widget.initiallySelected);
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _contains(User u, String q) {
    if (q.isEmpty) return true;
    String acc = '';
    // tenta map
    try {
      final map = (u as dynamic).toJson?.call() as Map<String, dynamic>?;
      if (map != null) {
        final candidates = [
          map['name'],
          map['fullName'],
          map['username'],
          map['userName'],
          map['email'],
          map['id']?.toString(),
        ];
        acc = candidates.whereType<String>().join(' ').toLowerCase();
      }
    } catch (_) {}
    // fallbacks
    if (acc.isEmpty) {
      final parts = <String>[];
      try {
        final v = (u as dynamic).name as String?;
        if (v != null) parts.add(v);
      } catch (_) {}
      try {
        final v = (u as dynamic).userName as String?;
        if (v != null) parts.add(v);
      } catch (_) {}
      try {
        final v = (u as dynamic).email as String?;
        if (v != null) parts.add(v);
      } catch (_) {}
      try {
        final v = u.id?.toString();
        if (v != null) parts.add(v);
      } catch (_) {}
      acc = parts.join(' ').toLowerCase();
    }
    return acc.contains(q);
  }

  List<User> get _filtered =>
      widget.all.where((u) => _contains(u, _query)).toList()
        ..sort((a, b) => widget.displayFn(a).toLowerCase().compareTo(widget.displayFn(b).toLowerCase()));

  bool _isSelected(User u) => _selected.any((s) => s.id == u.id);

  void _toggle(User u) {
    setState(() {
      final idx = _selected.indexWhere((s) => s.id == u.id);
      if (idx >= 0) {
        _selected.removeAt(idx);
      } else {
        _selected.add(u);
      }
    });
  }

  void _selectAllFiltered() {
    final filtered = _filtered;
    setState(() {
      for (final u in filtered) {
        if (!_isSelected(u)) _selected.add(u);
      }
    });
  }

  void _clearFiltered() {
    final ids = _filtered.map((e) => e.id).toSet();
    setState(() {
      _selected.removeWhere((u) => ids.contains(u.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: appContainer(
        width: 900,
        padding: const EdgeInsets.all(AppSpacing.big),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.s10),
          border: Border.all(color: AppColors.black, width: 1),
        ),
        child: SizedBox(
          height: 600,
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(AppIcons.users, size: 18, color: AppColors.black),
                  const SizedBox(width: 8),
                  appText(
                    text: 'Selecionar avaliadores',
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSize.fs20,
                  ),
                  const Spacer(),
                  Tooltip(
                    message: 'Selecionados',
                    child: Chip(
                      label: Text('${_selected.length} selecionado(s)'),
                      shape: StadiumBorder(side: BorderSide(color: AppColors.black, width: 1)),
                      backgroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 20, thickness: 1, color: Colors.black12),

              // Barra de busca + ações rápidas
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.black, width: 1),
                        borderRadius: BorderRadius.circular(AppSizes.s10),
                        color: AppColors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Filtrar por nome, e-mail ou ID...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              tooltip: 'Limpar',
                              onPressed: () => _searchCtrl.clear(),
                            )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: filtered.isEmpty ? null : _selectAllFiltered,
                    icon: const Icon(Icons.done_all),
                    label: const Text('Selecionar tudo (filtro)'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: filtered.isEmpty ? null : _clearFiltered,
                    icon: const Icon(Icons.remove_done),
                    label: const Text('Limpar seleção (filtro)'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lista
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.s10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.black, width: 1),
                      borderRadius: BorderRadius.circular(AppSizes.s10),
                    ),
                    child: filtered.isEmpty
                        ? Center(
                      child: appText(
                        text: 'Nenhum avaliador encontrado.',
                        color: AppColors.grey800,
                      ),
                    )
                        : Scrollbar(
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final u = filtered[i];
                          final name = widget.displayFn(u);
                          final email = _tryEmail(u);
                          final selected = _isSelected(u);

                          return ListTile(
                            onTap: () => _toggle(u),
                            leading: Checkbox(
                              value: selected,
                              onChanged: (_) => _toggle(u),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: email == null ? null : Text(email),
                            trailing: selected
                                ? Icon(Icons.check_circle, color: AppColors.black)
                                : const SizedBox.shrink(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Footer
              SafeArea(
                top: false,
                child: Container(
                  margin: const EdgeInsets.only(top: AppSpacing.big),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.big,
                    vertical: AppSpacing.medium,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.black12, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Botão Voltar (outlined)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(120, 48),
                          side: const BorderSide(color: Colors.black, width: 1.5),
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () => Navigator.of(context).pop(widget.initiallySelected),
                        child: const Text('Voltar'),
                      ),
                      const SizedBox(width: 16),
                      // Botão Salvar (preto filled)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 48),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(_selected),
                        child: const Text('Salvar'),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  String? _tryEmail(User u) {
    try {
      final map = (u as dynamic).toJson?.call() as Map<String, dynamic>?;
      if (map != null) {
        final e = map['email'];
        if (e is String && e.trim().isNotEmpty) return e;
      }
    } catch (_) {}
    try {
      final e = (u as dynamic).email as String?;
      if (e != null && e.trim().isNotEmpty) return e;
    } catch (_) {}
    return null;
  }
}
