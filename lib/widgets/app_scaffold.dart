import 'package:flutter/material.dart';

import '../state/app_state.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final AppState appState;
  final VoidCallback? onAdminAction;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.appState,
    this.onAdminAction,
  });

  static const String _logoAssetPath =
      'img/IMAGEM DE SÃO PAULO APOSTOLO MONOCROMATICA.png';

  @override
  Widget build(BuildContext context) {
    final onDark = Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            SizedBox(
              width: 34,
              height: 34,
              child: Image.asset(
                _logoAssetPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.church,
                  size: 26,
                  color: onDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Paróquia São Paulo Apóstolo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    'Diocese de Umuarama',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onDark.withValues(alpha: 0.85),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
      body: body,
      floatingActionButton: appState.isAdmin && onAdminAction != null
          ? FloatingActionButton(
              onPressed: onAdminAction,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
