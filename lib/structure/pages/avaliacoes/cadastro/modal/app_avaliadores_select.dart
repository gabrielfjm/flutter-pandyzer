import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/structure/widgets/app_modal.dart';

class AppAvaliadoresSelector extends StatefulWidget {
  final List<String> avaliadores;
  final Function(List<String>) onSelected;

  const AppAvaliadoresSelector({super.key, required this.avaliadores, required this.onSelected});

  @override
  State<AppAvaliadoresSelector> createState() => _AppAvaliadoresSelectorState();
}

class _AppAvaliadoresSelectorState extends State<AppAvaliadoresSelector> {
  final List<String> _selected = [];

  void _openModal() {
    showDialog(
      context: context,
      builder: (ctx) => AppModal(
        title: 'Selecionar Avaliadores',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.avaliadores.map((e) {
            return CheckboxListTile(
              title: Text(e),
              value: _selected.contains(e),
              onChanged: (v) {
                setState(() {
                  v! ? _selected.add(e) : _selected.remove(e);
                  widget.onSelected(_selected);
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.person_add),
          label: const Text('Adicionar Avaliadores'),
          onPressed: _openModal,
        ),
        Wrap(
          children: _selected.map((e) => CircleAvatar(child: Text(e[0]))).toList(),
        )
      ],
    );
  }
}
