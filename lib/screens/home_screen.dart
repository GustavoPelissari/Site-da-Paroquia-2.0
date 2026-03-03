import 'dart:async';

import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../models/news_model.dart';
import 'content_detail_page.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  EventModel? _proximaMissa;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(_updateCountdown);
    });
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final missas =
        widget.appState.events.where((e) => e.tipo == EventType.missa).toList();

    if (missas.isEmpty) {
      _remaining = Duration.zero;
      _proximaMissa = null;
      return;
    }

    missas.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    final agora = widget.appState.serverNow;

    _proximaMissa = missas.firstWhere(
      (m) => m.dataHora.isAfter(agora),
      orElse: () => missas.last,
    );
    _remaining = _proximaMissa!.dataHora.difference(agora);
  }

  String _formatCountdown() {
    if (_proximaMissa == null) return '--:--:--';
    if (_remaining.isNegative) return 'Em andamento';

    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(_remaining.inHours)}:${two(_remaining.inMinutes % 60)}:${two(_remaining.inSeconds % 60)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}  '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
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

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final bottomInset = 104.0;
    final eventsFeed = widget.appState.events.take(4).toList();
    final newsFeed = widget.appState.news.take(3).toList();
    final hasLocalContent = eventsFeed.isNotEmpty || newsFeed.isNotEmpty;
    final shouldShowBlockingLoading =
        widget.appState.isLoadingRemoteData && !hasLocalContent;
    final shouldShowNonBlockingWarning =
        widget.appState.remoteError != null;

    return SafeArea(
      top: false,
      bottom: false,
      child: shouldShowBlockingLoading
          ? const AppLoadingView(message: 'Carregando Home...')
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
            'Vida Paroquial',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Agenda liturgica e avisos da comunidade.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6A6361),
                ),
          ),
          const SizedBox(height: 16),
        _NextMassCard(
          missa: _proximaMissa,
          countdown: _formatCountdown(),
          inProgress: _proximaMissa != null && _remaining.isNegative,
          dateLabel:
              _proximaMissa == null ? '--/--/----' : _formatDate(_proximaMissa!.dataHora),
          syncReady: widget.appState.serverClockReady,
          ),
          const SizedBox(height: 22),
          const _SectionHeader(
            title: 'Agenda e avisos',
            subtitle: 'Atualizacoes principais da semana',
          ),
          const SizedBox(height: 10),
          if (eventsFeed.isEmpty && newsFeed.isEmpty)
            const AppEmptyState(
              icon: Icons.inbox_outlined,
              title: 'Sem noticias ainda',
              subtitle: 'Assim que houver atualizacoes, elas aparecerao aqui.',
            ),
          ...eventsFeed.map(
            (event) => _AgendaCard(
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
          ...newsFeed.map(
            (news) => _AgendaCard(
              title: news.titulo,
              type: 'Aviso pastoral',
              detail: _shorten(news.conteudo),
              local: 'Comunicado',
              icon: Icons.campaign_outlined,
              imageUrl: news.imagemUrl,
              heroTag: 'news-${news.id}',
              externalLink: news.linkExterno,
              onTap: () => _openNewsDetail(context, news),
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
        ),
      ),
    );
  }

  void _openNewsDetail(BuildContext context, NewsModel news) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContentDetailPage(
          title: news.titulo,
          description: news.conteudo,
          imageUrl: news.imagemUrl,
          heroTag: 'news-${news.id}',
          metadata: [_formatDate(news.dataPublicacao), 'Noticia'],
          externalLink: news.linkExterno,
          externalLinkLabel: 'Abrir fonte',
        ),
      ),
    );
  }

  static String _shorten(String text) {
    const max = 82;
    if (text.length <= max) return text;
    return '${text.substring(0, max).trim()}...';
  }
}

class _NextMassCard extends StatelessWidget {
  const _NextMassCard({
    required this.missa,
    required this.countdown,
    required this.inProgress,
    required this.dateLabel,
    required this.syncReady,
  });

  final EventModel? missa;
  final String countdown;
  final bool inProgress;
  final String dateLabel;
  final bool syncReady;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.vinhoParoquial,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: 10,
            child: Icon(
              Icons.notifications_none_outlined,
              color: Colors.white.withValues(alpha: 0.06),
              size: 86,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Próxima Missa',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    syncReady ? Icons.cloud_done_outlined : Icons.cloud_sync_outlined,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.84),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (inProgress)
                Text(
                  'EM ANDAMENTO',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                )
              else
                Text(
                  countdown,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              const SizedBox(height: 18),
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                missa?.local ?? 'Local não informado',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6A6361),
              ),
        ),
      ],
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

class _AgendaCard extends StatelessWidget {
  const _AgendaCard({
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
