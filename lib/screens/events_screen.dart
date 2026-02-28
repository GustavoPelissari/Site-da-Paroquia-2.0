import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../state/app_state.dart';
import '../widgets/card_section.dart';

class EventsScreen extends StatefulWidget {
  final AppState appState;

  const EventsScreen({
    super.key,
    required this.appState,
  });

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  EventType? _filter;

  @override
  Widget build(BuildContext context) {
    final events = _filter == null
        ? widget.appState.events
        : widget.appState.events.where((e) => e.tipo == _filter).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<EventType?>(
            value: _filter,
            decoration: const InputDecoration(
              labelText: 'Filtrar por tipo',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Todos')),
              DropdownMenuItem(value: EventType.missa, child: Text('Missa')),
              DropdownMenuItem(value: EventType.reuniao, child: Text('Reunião')),
              DropdownMenuItem(value: EventType.festa, child: Text('Festa')),
            ],
            onChanged: (value) => setState(() => _filter = value),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ...events.map(
                (e) => CardSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.nome,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _EventBadge(tipo: e.tipo),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        e.local,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(e.dataHora),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year} • '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

class _EventBadge extends StatelessWidget {
  final EventType tipo;

  const _EventBadge({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final map = {
      EventType.missa: 'MISSA',
      EventType.reuniao: 'REUNIÃO',
      EventType.festa: 'FESTA',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF80152B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        map[tipo]!,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF80152B),
        ),
      ),
    );
  }
}