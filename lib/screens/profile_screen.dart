import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/card_section.dart';

class ProfileScreen extends StatefulWidget {
  final AppState appState;

  const ProfileScreen({
    super.key,
    required this.appState,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onStateChange);
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.user;

    return ListView(
      children: [
        CardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.nome,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        CardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Permissão de acesso (teste)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButton<int>(
                value: user.nivelAcesso,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Nível 0')),
                  DropdownMenuItem(value: 1, child: Text('Nível 1')),
                  DropdownMenuItem(value: 2, child: Text('Nível 2')),
                  DropdownMenuItem(value: 3, child: Text('Nível 3')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    widget.appState.setNivelAcesso(value);
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                widget.appState.isAdmin
                    ? 'Você tem permissões administrativas.'
                    : 'Conta padrão de usuário.',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}