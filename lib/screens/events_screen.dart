import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_view.dart';
import 'content_detail_page.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  EventType? _filter;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final bottomInset = 104.0;
    final query = _searchCtrl.text.trim().toLowerCase();
    final events = _filter == null
        ? widget.appState.events
        : widget.appState.events.where((e) => e.tipo == _filter).toList();
    final filteredEvents = query.isEmpty
        ? events
        : events
            .where((e) =>
                e.nome.toLowerCase().contains(query) ||
                e.local.toLowerCase().contains(query) ||
                (e.descricao ?? '').toLowerCase().contains(query))
            .toList();
    final hasLocalContent = widget.appState.events.isNotEmpty;
    final shouldShowBlockingLoading =
        widget.appState.isLoadingRemoteData && !hasLocalContent;
    final shouldShowNonBlockingWarning =
        widget.appState.remoteError != null;

    return SafeArea(
      top: false,
      bottom: false,
      child: shouldShowBlockingLoading
          ? const AppLoadingView(message: 'Carregando eventos...')
          : ListView(
        padding: EdgeInsets.fromLTRB(16, 14, 16, bottomInset + safeBottom),
        children: [
          if (shouldShowNonBlockingWarning) ...[
            _InlineWarning(
              message: 'Sem conexao com servidor. Exibindo dados locais.',
              onRetry: widget.appState.retryLoadData,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Eventos',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Programacao liturgica e atividades pastorais.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6A6361),
                ),
          ),
          const SizedBox(height: 16),
          _FilterCard(
            value: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar eventos...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => setState(() => _searchCtrl.clear()),
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          if (filteredEvents.isEmpty)
            const AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Nenhum evento encontrado',
              subtitle: 'Tente outro filtro ou aguarde novos eventos.',
            ),
          ...filteredEvents.map(
            (event) => _EventCard(
              title: event.nome,
              type: _eventLabel(event.tipo),
              detail: _formatDate(event.dataHora),
              local: event.local,
              icon: _eventIcon(event.tipo),
              imageUrl: event.imagemUrl,
              heroTag: 'event-${event.id}',
              externalLink: event.linkExterno,
              onTap: () => _openEventDetail(context, event),
            ),
          ),
        ],
      ),
    );
  }

  void _openEventDetail(BuildContext context, EventModel event) {
    final description = (event.descricao != null && event.descricao!.trim().isNotEmpty)
        ? event.descricao!
        : 'Evento sem descricao detalhada cadastrada no momento.';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContentDetailPage(
          title: event.nome,
          description: description,
          imageUrl: event.imagemUrl,
          heroTag: 'event-${event.id}',
          metadata: [
            _eventLabel(event.tipo),
            _formatDate(event.dataHora),
            event.local,
          ],
          externalLink: event.linkExterno,
          externalLinkLabel: 'Abrir link externo',
          onEdit: widget.appState.canCreateEvents
              ? () => _editEvent(context, event)
              : null,
          onDelete: widget.appState.canCreateEvents
              ? () => _deleteEvent(context, event)
              : null,
        ),
      ),
    );
  }

  Future<void> _editEvent(BuildContext context, EventModel event) async {
    final nomeCtrl = TextEditingController(text: event.nome);
    final localCtrl = TextEditingController(text: event.local);
    final descCtrl = TextEditingController(text: event.descricao ?? '');
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar evento'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => (value == null || value.trim().length < 3) ? 'Nome invalido' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: localCtrl,
                decoration: const InputDecoration(labelText: 'Local'),
                validator: (value) => (value == null || value.trim().length < 2) ? 'Local invalido' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descricao'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.pop(context, true);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await widget.appState.updateEventItem(
        id: event.id,
        nome: nomeCtrl.text.trim(),
        local: localCtrl.text.trim(),
        descricao: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento atualizado com sucesso.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao atualizar evento.')),
      );
    }
  }

  Future<void> _deleteEvent(BuildContext context, EventModel event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir evento'),
        content: Text('Deseja excluir "${event.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await widget.appState.deleteEventItem(id: event.id);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento excluido com sucesso.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao excluir evento.')),
      );
    }
  }
}

class _InlineWarning extends StatelessWidget {
  const _InlineWarning({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD5D5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 18,
            color: Color(0xFFB42318),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF912018),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              minimumSize: const Size(56, 32),
              foregroundColor: AppTheme.vinhoParoquial,
              textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            child: const Text('Tentar'),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}  '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

String _eventLabel(EventType type) {
  switch (type) {
    case EventType.missa:
      return 'Missa';
    case EventType.reuniao:
      return 'Reuniao';
    case EventType.festa:
      return 'Festa';
  }
}

IconData _eventIcon(EventType type) {
  switch (type) {
    case EventType.missa:
      return Icons.church_outlined;
    case EventType.reuniao:
      return Icons.groups_2_outlined;
    case EventType.festa:
      return Icons.celebration_outlined;
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.value,
    required this.onChanged,
  });

  final EventType? value;
  final ValueChanged<EventType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E2E2)),
      ),
      child: DropdownButtonFormField<EventType?>(
        initialValue: value,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          labelText: 'Filtrar por tipo',
        ),
        items: const [
          DropdownMenuItem(value: null, child: Text('Todos')),
          DropdownMenuItem(value: EventType.missa, child: Text('Missa')),
          DropdownMenuItem(value: EventType.reuniao, child: Text('Reuniao')),
          DropdownMenuItem(value: EventType.festa, child: Text('Festa')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.title,
    required this.type,
    required this.detail,
    required this.local,
    required this.icon,
    required this.imageUrl,
    required this.heroTag,
    required this.externalLink,
    required this.onTap,
  });

  final String title;
  final String type;
  final String detail;
  final String local;
  final IconData icon;
  final String? imageUrl;
  final String heroTag;
  final String? externalLink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E2E2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF6ECEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.vinhoParoquial, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.vinhoParoquial,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6A6361),
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F3F4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    local,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.vinhoParoquial,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (externalLink != null && externalLink!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    externalLink!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.vinhoParoquial,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 36),
              foregroundColor: AppTheme.vinhoParoquial,
              textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            child: const Text('Ver mais'),
          ),
        ],
      ),
    );
  }
}

