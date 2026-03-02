import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_view.dart';

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

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final bottomInset = widget.appState.isAdmin ? 146.0 : 104.0;
    final events = _filter == null
        ? widget.appState.events
        : widget.appState.events.where((e) => e.tipo == _filter).toList();
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
          const SizedBox(height: 14),
          if (events.isEmpty)
            const AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Nenhum evento encontrado',
              subtitle: 'Tente outro filtro ou aguarde novos eventos.',
            ),
          ...events.map(
            (event) => _EventCard(
              title: event.nome,
              type: _eventLabel(event.tipo),
              detail: _formatDate(event.dataHora),
              local: event.local,
              icon: _eventIcon(event.tipo),
              imageUrl: event.imagemUrl,
              externalLink: event.linkExterno,
              onTap: () => _openEventDetail(context, event),
            ),
          ),
        ],
      ),
    );
  }

  void _openEventDetail(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EventDetailSheet(event: event),
    );
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
    required this.externalLink,
    required this.onTap,
  });

  final String title;
  final String type;
  final String detail;
  final String local;
  final IconData icon;
  final String? imageUrl;
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
                  ClipRRect(
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

class _EventDetailSheet extends StatelessWidget {
  const _EventDetailSheet({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.nome,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Tipo',
            value: _eventLabel(event.tipo),
          ),
          _DetailRow(
            label: 'Data e hora',
            value: _formatDate(event.dataHora),
          ),
          _DetailRow(
            label: 'Local',
            value: event.local,
          ),
          if (event.linkExterno != null && event.linkExterno!.isNotEmpty)
            _DetailRow(
              label: 'Link',
              value: event.linkExterno!,
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6A6361),
              ),
          children: [
            TextSpan(
              text: '$label: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.vinhoParoquial,
                  ),
            ),
            TextSpan(
              text: value,
            ),
          ],
        ),
      ),
    );
  }
}
