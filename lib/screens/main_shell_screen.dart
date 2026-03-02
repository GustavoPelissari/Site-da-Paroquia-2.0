import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'create_event_form.dart';
import 'create_news_form.dart';
import 'events_screen.dart';
import 'groups_screen.dart';
import 'home_screen.dart';
import 'horarios_screen.dart';
import 'profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  static const String _logoAssetPath =
      'web-next/public/img/IMAGEM DE SÃO PAULO APOSTOLO MONOCROMATICA.png';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.appState.landingTabIndexForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final screens = [
          HomeScreen(appState: widget.appState),
          HorariosScreen(appState: widget.appState),
          GroupsScreen(appState: widget.appState),
          EventsScreen(appState: widget.appState),
          ProfileScreen(appState: widget.appState),
        ];

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: _InstitutionalHeader(
              logoAssetPath: _logoAssetPath,
              appState: widget.appState,
              onCreateNews: () => _openCreateNews(context),
              onCreateEvent: () => _openCreateEvent(context),
            ),
          ),
          body: SafeArea(
            top: false,
            bottom: false,
            child: screens[_currentIndex],
          ),
          bottomNavigationBar: _BottomShellBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        );
      },
    );
  }

  void _openCreateNews(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CreateNewsForm(appState: widget.appState),
    );
  }

  void _openCreateEvent(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CreateEventForm(appState: widget.appState),
    );
  }
}

class _InstitutionalHeader extends StatelessWidget {
  const _InstitutionalHeader({
    required this.logoAssetPath,
    required this.appState,
    required this.onCreateNews,
    required this.onCreateEvent,
  });

  final String logoAssetPath;
  final AppState appState;
  final VoidCallback onCreateNews;
  final VoidCallback onCreateEvent;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                logoAssetPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.church_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paróquia São Paulo Apóstolo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 19,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Diocese de Umuarama',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              color: Colors.white,
              onSelected: (value) {
                if (value == 'news') {
                  onCreateNews();
                } else if (value == 'event') {
                  onCreateEvent();
                } else if (value == 'users') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gestão de usuários em implementação.')),
                  );
                } else if (value == 'logout') {
                  appState.logout();
                }
              },
              itemBuilder: (_) {
                final items = <PopupMenuEntry<String>>[];
                if (appState.canCreateNews) {
                  items.add(const PopupMenuItem(value: 'news', child: Text('Nova notícia')));
                }
                if (appState.canCreateEvents) {
                  items.add(const PopupMenuItem(value: 'event', child: Text('Novo evento')));
                }
                if (appState.canManageUsers) {
                  items.add(
                    const PopupMenuItem(value: 'users', child: Text('Gerenciar usuários')),
                  );
                }
                items.add(const PopupMenuItem(value: 'logout', child: Text('Sair')));
                return items;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomShellBar extends StatelessWidget {
  const _BottomShellBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BottomAppBar(
        elevation: 8,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Container(
          height: 72,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE8E2E2))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Início',
                  selected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.schedule_rounded,
                  label: 'Horários',
                  selected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.groups_rounded,
                  label: 'Grupos',
                  selected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.event_note_rounded,
                  label: 'Eventos',
                  selected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  selected: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppTheme.vinhoParoquial;
    final inactiveColor = const Color(0xFF8A7D81);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7ECEE) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? activeColor : inactiveColor,
              size: 21,
            ),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    height: 1.0,
                    color: selected ? activeColor : inactiveColor,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
