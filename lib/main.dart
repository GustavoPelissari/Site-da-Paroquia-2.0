import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/main_shell_screen.dart';

void main() {
  runApp(const ParoquiaApp());
}

class ParoquiaApp extends StatefulWidget {
  const ParoquiaApp({super.key});

  @override
  State<ParoquiaApp> createState() => _ParoquiaAppState();
}

class _ParoquiaAppState extends State<ParoquiaApp> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    // Regra crítica do PDF: sincronizar o relógio com o servidor
    // pra calcular "Próxima Missa" corretamente.
    _appState.syncServerClock();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paróquia MVP',
      theme: AppTheme.lightTheme,
      home: MainShellScreen(appState: _appState),
    );
  }
}