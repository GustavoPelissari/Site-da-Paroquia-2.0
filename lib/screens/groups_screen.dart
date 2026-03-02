import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_view.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final bottomInset = 104.0;
    final hasLocalContent = appState.groups.isNotEmpty;
    final shouldShowBlockingLoading =
        appState.isLoadingRemoteData && !hasLocalContent;
    final shouldShowNonBlockingWarning =
        appState.remoteError != null;

    return SafeArea(
      top: false,
      bottom: false,
      child: shouldShowBlockingLoading
          ? const AppLoadingView(message: 'Carregando grupos...')
          : ListView(
        padding: EdgeInsets.fromLTRB(16, 14, 16, bottomInset + safeBottom),
        children: [
          if (shouldShowNonBlockingWarning) ...[
            _InlineWarning(
              message: 'Sem conexao com servidor. Exibindo dados locais.',
              onRetry: appState.retryLoadData,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Grupos',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pastorais e ministerios da comunidade.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6A6361),
                ),
          ),
          const SizedBox(height: 20),
          if (appState.groups.isEmpty)
            const AppEmptyState(
              icon: Icons.groups_2_outlined,
              title: 'Nenhum grupo encontrado',
              subtitle: 'Novos grupos aparecerao quando forem cadastrados.',
            ),
          ...appState.groups.map(
            (group) => _GroupCard(
              title: group.nome,
              subtitle: group.descricao,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GroupDetailScreen(
                      appState: appState,
                      group: group,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E2E2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6ECEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.groups_2_outlined,
                  color: AppTheme.vinhoParoquial,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6A6361),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8A7D81),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
