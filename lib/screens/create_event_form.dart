import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../state/app_state.dart';

class CreateEventForm extends StatefulWidget {
  final AppState appState;

  const CreateEventForm({
    super.key,
    required this.appState,
  });

  @override
  State<CreateEventForm> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  final _nameCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  EventType _tipo = EventType.missa;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Novo evento',
            style: TextStyle(fontWeight: FontWeight.bold),
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
          DropdownButton<EventType>(
            value: _tipo,
            items: const [
              DropdownMenuItem(value: EventType.missa, child: Text('Missa')),
              DropdownMenuItem(value: EventType.reuniao, child: Text('Reunião')),
              DropdownMenuItem(value: EventType.festa, child: Text('Festa')),
            ],
            onChanged: (v) => setState(() => _tipo = v!),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.appState.addEvent(
                EventModel(
                  id: DateTime.now().toString(),
                  nome: _nameCtrl.text,
                  local: _localCtrl.text,
                  dataHora: DateTime.now().add(const Duration(days: 1)),
                  tipo: _tipo,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}