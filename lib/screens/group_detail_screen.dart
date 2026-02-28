import 'package:flutter/material.dart';

import '../models/group_model.dart';
import '../state/app_state.dart';
import '../widgets/card_section.dart';

class GroupDetailScreen extends StatefulWidget {
  final AppState appState;
  final GroupModel group;

  const GroupDetailScreen({
    super.key,
    required this.appState,
    required this.group,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final docs = widget.appState.schedulesByGroup(widget.group.id);
    final groupNews = widget.appState.newsByGroup(widget.group.id);

    final tabs = [
      _DocsTab(docs: docs),
      _NewsTab(news: groupNews),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.nome),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Docs')),
                ButtonSegment(value: 1, label: Text('Notícias')),
              ],
              selected: {_tabIndex},
              onSelectionChanged: (set) {
                setState(() => _tabIndex = set.first);
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: tabs[_tabIndex]),
        ],
      ),
    );
  }
}

class _DocsTab extends StatelessWidget {
  final List docs;

  const _DocsTab({required this.docs});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return const Center(child: Text('Nenhum documento disponível.'));
    }

    return ListView(
      children: [
        ...docs.map(
          (d) => CardSection(
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    d.pdfLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Text('PDF disponível'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsTab extends StatelessWidget {
  final List news;

  const _NewsTab({required this.news});

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) {
      return const Center(child: Text('Sem notícias desse grupo ainda.'));
    }

    return ListView(
      children: [
        ...news.map(
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
                const SizedBox(height: 6),
                Text(n.conteudo),
              ],
            ),
          ),
        ),
      ],
    );
  }
}