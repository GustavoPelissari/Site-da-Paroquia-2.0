import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/main_shell_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'widgets/app_loading_view.dart';

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
    _appState.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Paroquia MVP',
          theme: AppTheme.lightTheme,
          home: _root(),
        );
      },
    );
  }

  Widget _root() {
    if (_appState.authLoading) {
      return const Scaffold(body: AppLoadingView(message: 'Validando sessao...'));
    }
    if (!_appState.isAuthenticated) {
      return LoginScreen(appState: _appState);
    }
    return MainShellScreen(appState: _appState);
  }
}
