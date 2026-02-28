import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/card_section.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatelessWidget {
  final AppState appState;

  const GroupsScreen({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...appState.groups.map(
          (g) => InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GroupDetailScreen(
                    appState: appState,
                    group: g,
                  ),
                ),
              );
            },
            child: CardSection(
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF80152B),
                    foregroundColor: Colors.white,
                    child: Icon(Icons.groups),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          g.descricao,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}