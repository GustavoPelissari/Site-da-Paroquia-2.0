import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_view.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String? _updatingUserId;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.appState.loadUsersManagement(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.appState.canManageUsers) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gerenciar usuarios')),
        body: const SafeArea(
          child: AppEmptyState(
            icon: Icons.lock_outline_rounded,
            title: 'Acesso negado',
            subtitle: 'Somente administradores podem gerenciar usuarios.',
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final users = widget.appState.usersManagement;
        final normalizedQuery = _query.trim().toLowerCase();
        final filteredUsers = normalizedQuery.isEmpty
            ? users
            : users.where((user) {
                final nome = user.nome.toLowerCase();
                final email = user.email.toLowerCase();
                return nome.contains(normalizedQuery) || email.contains(normalizedQuery);
              }).toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Gerenciar usuarios')),
          body: SafeArea(
            child: widget.appState.usersManagementLoading && users.isEmpty
                ? const AppLoadingView(message: 'Carregando usuarios...')
                : RefreshIndicator(
                    onRefresh: () => widget.appState.loadUsersManagement(forceRefresh: true),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      children: [
                        Text(
                          'Controle de acesso',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Busque um usuario e altere o nivel de permissao.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF6A6361),
                              ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _searchCtrl,
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                            hintText: 'Pesquisar por nome ou email',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _query.trim().isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() => _query = '');
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        if (widget.appState.usersManagementError != null) ...[
                          const SizedBox(height: 12),
                          _InlineWarning(
                            message: widget.appState.usersManagementError!,
                            onRetry: () => widget.appState.loadUsersManagement(forceRefresh: true),
                          ),
                        ],
                        const SizedBox(height: 14),
                        if (users.isEmpty)
                          const AppEmptyState(
                            icon: Icons.group_off_outlined,
                            title: 'Nenhum usuario encontrado',
                            subtitle: 'Os usuarios cadastrados aparecerao aqui.',
                          ),
                        if (users.isNotEmpty && filteredUsers.isEmpty)
                          const AppEmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'Nenhum resultado',
                            subtitle: 'Tente buscar por outro nome ou email.',
                          ),
                        ...filteredUsers.map(_buildUserCard),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    final isSelf = widget.appState.user.id == user.id;
    final canSelfEdit = isSelf && widget.appState.canSelfChangeAccessLevel;
    final isUpdating = _updatingUserId == user.id;
    final canChangeLevel = !isUpdating && (!isSelf || canSelfEdit);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E2E2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF6ECEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
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
                  user.nome,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6A6361),
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: user.nivelAcesso,
                  decoration: InputDecoration(
                    labelText: isSelf ? 'Seu nivel de acesso' : 'Nivel de acesso',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('0 - Usuario padrao')),
                    DropdownMenuItem(value: 1, child: Text('1 - Membro pastoral')),
                    DropdownMenuItem(value: 2, child: Text('2 - Coordenador')),
                    DropdownMenuItem(value: 3, child: Text('3 - Administrativo / Padre')),
                  ],
                  onChanged: canChangeLevel
                      ? (value) => _onLevelChanged(
                            userId: user.id,
                            currentLevel: user.nivelAcesso,
                            nextLevel: value,
                          )
                      : null,
                ),
                if (isSelf) ...[
                  const SizedBox(height: 6),
                  Text(
                    canSelfEdit
                        ? 'Usuario de teste autorizado para autoalteracao de nivel.'
                        : 'Seu proprio nivel nao pode ser alterado por esta tela.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8A7D81),
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onLevelChanged({
    required String userId,
    required int currentLevel,
    required int? nextLevel,
  }) async {
    if (nextLevel == null || nextLevel == currentLevel || _updatingUserId != null) return;

    setState(() => _updatingUserId = userId);
    try {
      await widget.appState.setUserAccessLevel(userId: userId, nivelAcesso: nextLevel);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nivel de acesso atualizado com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao atualizar usuario: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingUserId = null);
      }
    }
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
          TextButton(onPressed: onRetry, child: const Text('Tentar')),
        ],
      ),
    );
  }
}
