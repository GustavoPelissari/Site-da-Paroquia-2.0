import 'dart:async';
import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../state/app_state.dart';
import '../widgets/card_section.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;

  const HomeScreen({
    super.key,
    required this.appState,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(_updateCountdown);
    });
  }

  void _updateCountdown() {
    final missas =
        widget.appState.events.where((e) => e.tipo == EventType.missa).toList();

    if (missas.isEmpty) {
      _remaining = Duration.zero;
      return;
    }

    missas.sort((a, b) => a.dataHora.compareTo(b.dataHora));

    // Regra crítica do PDF: usar relógio do servidor (ou offset sincronizado),
    // não DateTime.now() direto.
    final agora = widget.appState.serverNow;

    _remaining = missas.first.dataHora.difference(agora);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    if (d.isNegative) return 'Em andamento';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        CardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Próxima Missa',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (!widget.appState.serverClockReady)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Tooltip(
                        message: 'Ainda sincronizando com o servidor...',
                        child: Icon(Icons.cloud_sync, size: 18),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _format(_remaining),
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Text(
                widget.appState.serverClockReady
                    ? 'Baseado no relógio do servidor'
                    : 'Usando relógio do celular (fallback)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        ...widget.appState.news.map(
          (n) => CardSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(n.conteudo),
              ],
            ),
          ),
        ),
      ],
    );
  }
}