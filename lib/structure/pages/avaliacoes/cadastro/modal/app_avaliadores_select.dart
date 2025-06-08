import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';

class AppAvaliadoresSelector extends StatefulWidget {
  final List<User> availableEvaluators;
  final List<User> selectedEvaluators;
  final Function(List<User>) onSelectionChanged;

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
  void _openModal() {
    List<User> tempSelected = List.from(widget.selectedEvaluators);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Selecionar Avaliadores'),
              content: SizedBox(
                width: 400,
                height: 500,
                child: widget.availableEvaluators.isEmpty
                    ? const Center(child: Text('Nenhum avaliador disponível.'))
                    : ListView.builder(
                  itemCount: widget.availableEvaluators.length,
                  itemBuilder: (context, index) {
                    final user = widget.availableEvaluators[index];
                    final isSelected =
                    tempSelected.any((u) => u.id == user.id);
                    return CheckboxListTile(
                      title: Text(user.name ?? 'Usuário sem nome'),
                      value: isSelected,
                      onChanged: (selected) {
                        setModalState(() {
                          if (selected!) {
                            tempSelected.add(user);
                          } else {
                            tempSelected
                                .removeWhere((u) => u.id == user.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onSelectionChanged(tempSelected);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Função para remover um avaliador da lista
  void _removeEvaluator(User userToRemove) {
    final newList = List<User>.from(widget.selectedEvaluators);
    newList.removeWhere((user) => user.id == userToRemove.id);
    widget.onSelectionChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        appText(
          text: 'Avaliadores',
          fontSize: AppFontSize.fs15,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: AppSpacing.small),
        ElevatedButton.icon(
          onPressed: _openModal,
          icon: const Icon(Icons.group_add_outlined, size: 18),
          label: const Text('Selecionar Avaliadores'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.grey200,
            foregroundColor: AppColors.black,
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.normal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.grey400),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: AppSpacing.normal),
        if (widget.selectedEvaluators.isNotEmpty)
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: widget.selectedEvaluators.map((user) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: AppColors.grey800,
                  child: Text(
                    user.name != null && user.name!.isNotEmpty
                        ? user.name!.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                label: Text(user.name ?? 'Usuário sem nome'),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () => _removeEvaluator(user),
              );
            }).toList(),
          )
        else
          appText(
            text:
            'Nenhum avaliador selecionado. O criador será atribuído se for do tipo "Avaliador".',
            color: AppColors.grey700,
            fontSize: AppFontSize.fs12,
          ),
      ],
    );
  }
}