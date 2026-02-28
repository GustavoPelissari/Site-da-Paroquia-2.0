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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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