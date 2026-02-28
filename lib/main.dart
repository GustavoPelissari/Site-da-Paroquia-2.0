import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/main_shell_screen.dart';

void main() {
  runApp(const ParoquiaApp());
}

class ParoquiaApp extends StatelessWidget {
  const ParoquiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paróquia MVP',
      theme: AppTheme.lightTheme,
      home: MainShellScreen(appState: AppState()),
    );
  }
}