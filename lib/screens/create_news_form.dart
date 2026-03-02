import 'package:flutter/material.dart';

import '../state/app_state.dart';

class CreateNewsForm extends StatefulWidget {
  const CreateNewsForm({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<CreateNewsForm> createState() => _CreateNewsFormState();
}

class _CreateNewsFormState extends State<CreateNewsForm> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  String? _groupId;
  bool _publico = true;
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final allowedGroups = widget.appState.groups
        .where((g) => widget.appState.canCreateNewsForGroup(g.id))
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
            'Nova noticia',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Titulo'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentCtrl,
            decoration: const InputDecoration(labelText: 'Conteudo'),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            initialValue: _groupId,
            decoration: const InputDecoration(
              labelText: 'Grupo (opcional)',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Publicacao geral')),
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
          const SizedBox(height: 6),
          Text(
            'Imagens sao exibidas mantendo proporcao e com compressao visual suave no cliente.',
            style: Theme.of(context).textTheme.bodySmall,
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
      await widget.appState.createNewsItem(
        titulo: _titleCtrl.text.trim(),
        conteudo: _contentCtrl.text.trim(),
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
        _error = 'Não foi possível salvar notícia.';
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
