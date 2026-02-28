import 'package:flutter/material.dart';

import '../state/app_state.dart';
import 'home_screen.dart';
import 'groups_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';
import 'create_news_form.dart';
import 'create_event_form.dart';

class MainShellScreen extends StatefulWidget {
  final AppState appState;

  const MainShellScreen({
    super.key,
    required this.appState,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  static const Color vinho = Color(0xFF80152B);

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(appState: widget.appState),
      GroupsScreen(appState: widget.appState),
      EventsScreen(appState: widget.appState),
      ProfileScreen(appState: widget.appState),
    ];

    final titles = ['Início', 'Grupos', 'Eventos', 'Perfil'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
      ),
      body: screens[_currentIndex],
      floatingActionButton: widget.appState.isAdmin
          ? FloatingActionButton(
              backgroundColor: vinho,
              child: const Icon(Icons.add),
              onPressed: () => _openAdminSheet(context),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: vinho,
        unselectedItemColor: vinho.withOpacity(0.5),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            label: 'Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  void _openAdminSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _AdminSheet(appState: widget.appState),
    );
  }
}

class _AdminSheet extends StatelessWidget {
  final AppState appState;

  const _AdminSheet({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ações administrativas',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Criar notícia'),
            onTap: () {
              Navigator.pop(context);
              _openCreateNews(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_outlined),
            title: const Text('Criar evento'),
            onTap: () {
              Navigator.pop(context);
              _openCreateEvent(context);
            },
          ),
        ],
      ),
    );
  }

  void _openCreateNews(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => CreateNewsForm(appState: appState),
  );
}

void _openCreateEvent(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => CreateEventForm(appState: appState),
  );
}
}