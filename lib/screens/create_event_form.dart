import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _pickedImage;
  EventType _tipo = EventType.missa;
  String? _groupId;
  bool _publico = true;
  bool _saving = false;
  bool _uploadingImage = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _localCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

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
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Descricao (opcional)'),
            minLines: 3,
            maxLines: 6,
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
              DropdownMenuItem(value: EventType.retiro, child: Text('Retiro')),
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
            enabled: !_saving && _pickedImage == null,
            decoration: const InputDecoration(
              labelText: 'URL da imagem (opcional)',
              hintText: 'https://...',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: (_saving || _uploadingImage) ? null : _pickImage,
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(_pickedImage == null ? 'Upload PNG/JPEG' : 'Trocar imagem'),
              ),
              if (_pickedImage != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _saving
                      ? null
                      : () {
                          setState(() => _pickedImage = null);
                        },
                  child: const Text('Remover'),
                ),
              ],
            ],
          ),
          if (_pickedImage != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _pickedImage!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
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
      String? imageUrl = _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim();
      if (_pickedImage != null) {
        setState(() => _uploadingImage = true);
        imageUrl = await widget.appState.uploadImageFile(file: _pickedImage!);
      }

      await widget.appState.createEventItem(
        nome: _nameCtrl.text.trim(),
        local: _localCtrl.text.trim(),
        tipo: _tipo,
        descricao: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        groupId: _groupId,
        imagemUrl: imageUrl,
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
        setState(() {
          _saving = false;
          _uploadingImage = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final source = await _chooseImageSource();
      if (source == null) return;

      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (picked == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhuma imagem selecionada.')),
        );
        return;
      }

      final path = picked.path.toLowerCase();
      if (!(path.endsWith('.png') || path.endsWith('.jpg') || path.endsWith('.jpeg'))) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione imagem PNG, JPG ou JPEG.')),
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _pickedImage = File(picked.path);
        _imageCtrl.clear();
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao abrir seletor de imagem: ${e.message ?? e.code}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao selecionar imagem.')),
      );
    }
  }

  Future<ImageSource?> _chooseImageSource() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}
