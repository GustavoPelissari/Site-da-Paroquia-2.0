import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../state/app_state.dart';

class CreateEventForm extends StatefulWidget {
  const CreateEventForm({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<CreateEventForm> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  final _nameCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  EventType _tipo = EventType.missa;
  String? _groupId;
  bool _publico = true;
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final allowedGroups = widget.appState.groups
        .where((g) => widget.appState.canCreateEventsForGroup(g.id))
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Novo evento',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _localCtrl,
            decoration: const InputDecoration(labelText: 'Local'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<EventType>(
            initialValue: _tipo,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: EventType.missa, child: Text('Missa')),
              DropdownMenuItem(value: EventType.reuniao, child: Text('Reuniao')),
              DropdownMenuItem(value: EventType.festa, child: Text('Festa')),
            ],
            onChanged: (value) => setState(() => _tipo = value ?? EventType.missa),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            initialValue: _groupId,
            decoration: const InputDecoration(
              labelText: 'Grupo (opcional)',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Evento geral')),
              ...allowedGroups.map(
                (group) => DropdownMenuItem(
                  value: group.id,
                  child: Text(group.nome),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _groupId = value),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Visibilidade publica'),
            subtitle: const Text('Desative para restringir ao grupo selecionado'),
            value: _publico,
            onChanged: (value) => setState(() => _publico = value),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _imageCtrl,
            decoration: const InputDecoration(
              labelText: 'URL da imagem (opcional)',
              hintText: 'https://...',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _linkCtrl,
            decoration: const InputDecoration(
              labelText: 'Link externo (opcional)',
              hintText: 'https://...',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFC62828),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.appState.createEventItem(
        nome: _nameCtrl.text.trim(),
        local: _localCtrl.text.trim(),
        tipo: _tipo,
        groupId: _groupId,
        imagemUrl: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
        linkExterno: _linkCtrl.text.trim().isEmpty ? null : _linkCtrl.text.trim(),
        publico: _publico || _groupId == null,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível salvar evento.';
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
