import 'package:flutter/material.dart';

import '../models/news_model.dart';
import '../state/app_state.dart';

class CreateNewsForm extends StatefulWidget {
  final AppState appState;

  const CreateNewsForm({
    super.key,
    required this.appState,
  });

  @override
  State<CreateNewsForm> createState() => _CreateNewsFormState();
}

class _CreateNewsFormState extends State<CreateNewsForm> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

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
            'Nova notícia',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentCtrl,
            decoration: const InputDecoration(labelText: 'Conteúdo'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.appState.addNews(
                NewsModel(
                  id: DateTime.now().toString(),
                  titulo: _titleCtrl.text,
                  conteudo: _contentCtrl.text,
                  dataPublicacao: DateTime.now(),
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