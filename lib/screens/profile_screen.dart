import 'package:flutter/material.dart';

import '../models/access_control_model.dart';
import '../models/mail_settings_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_loading_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onStateChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.appState.loadMailSettings();
    });
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.user;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final bottomInset = 104.0;
    final shouldShowBlockingLoading = widget.appState.isLoadingRemoteData;
    final shouldShowNonBlockingWarning = widget.appState.remoteError != null;

    return SafeArea(
      top: false,
      bottom: false,
      child: shouldShowBlockingLoading
          ? const AppLoadingView(message: 'Carregando perfil...')
          : ListView(
        padding: EdgeInsets.fromLTRB(16, 14, 16, bottomInset + safeBottom),
        children: [
          if (shouldShowNonBlockingWarning) ...[
            _InlineWarning(
              message: 'Sem conexao com servidor. Exibindo dados locais.',
              onRetry: widget.appState.retryLoadData,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Perfil',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dados da conta e nivel de permissao.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6A6361),
                ),
          ),
          const SizedBox(height: 20),
          _IdentityCard(
            name: user.nome,
            email: user.email,
            roleLabel: widget.appState.currentRoleLabel,
          ),
          _ProfileCard(
            icon: Icons.mail_outline_rounded,
            title: 'Contato',
            value: user.email,
          ),
          _PermissionCard(
            currentLevel: user.nivelAcesso,
            isAdmin: widget.appState.isAdmin,
          ),
          if (widget.appState.isAdmin)
            _MailSettingsCard(
              settingsConfigured: widget.appState.mailSettings.configured,
              settings: widget.appState.mailSettings,
              loading: widget.appState.mailSettingsLoading,
              onSave: ({
                required String host,
                required int port,
                required bool secure,
                String? username,
                String? password,
                required String fromEmail,
                String? fromName,
                String? resetBaseUrl,
              }) {
                return widget.appState.saveMailSettings(
                  host: host,
                  port: port,
                  secure: secure,
                  username: username,
                  password: password,
                  fromEmail: fromEmail,
                  fromName: fromName,
                  resetBaseUrl: resetBaseUrl,
                );
              },
            ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: widget.appState.logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sair da conta'),
          ),
        ],
      ),
    );
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
      margin: const EdgeInsets.only(bottom: 2),
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
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              minimumSize: const Size(56, 32),
              foregroundColor: AppTheme.vinhoParoquial,
              textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            child: const Text('Tentar'),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.name,
    required this.email,
    required this.roleLabel,
  });

  final String name;
  final String email;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF6ECEE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppTheme.vinhoParoquial,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6A6361),
                      ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F3F4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    roleLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.vinhoParoquial,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E2E2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF6ECEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.vinhoParoquial, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.vinhoParoquial,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.currentLevel,
    required this.isAdmin,
  });

  final int currentLevel;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6ECEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: AppTheme.vinhoParoquial,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Nivel de permissao',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Nivel de acesso definido pela administracao da plataforma.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6A6361),
                ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0D9DA)),
            ),
            child: Text(
              _roleLabelFromLevel(currentLevel),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isAdmin
                ? 'Conta com permissoes administrativas.'
                : 'Conta padrao de usuario.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6A6361),
                ),
          ),
        ],
      ),
    );
  }
}

class _MailSettingsCard extends StatelessWidget {
  const _MailSettingsCard({
    required this.settingsConfigured,
    required this.settings,
    required this.loading,
    required this.onSave,
  });

  final bool settingsConfigured;
  final MailSettingsModel settings;
  final bool loading;
  final Future<void> Function({
    required String host,
    required int port,
    required bool secure,
    String? username,
    String? password,
    required String fromEmail,
    String? fromName,
    String? resetBaseUrl,
  }) onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6ECEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.markunread_mailbox_outlined,
                  color: AppTheme.vinhoParoquial,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'E-mail de avisos do sistema',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            settingsConfigured
                ? 'Remetente atual: ${settings.fromEmail ?? '-'}'
                : 'Nenhum envio de e-mail configurado.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6A6361),
                ),
          ),
          if (settingsConfigured && settings.updatedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Atualizado em ${settings.updatedAt!.day.toString().padLeft(2, '0')}/${settings.updatedAt!.month.toString().padLeft(2, '0')}/${settings.updatedAt!.year}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8A7D81),
                  ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: loading
                  ? null
                  : () async {
                      await _openEditDialog(context);
                    },
              icon: loading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.edit_outlined),
              label: const Text('Configurar envio'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditDialog(BuildContext context) async {
    final hostCtrl = TextEditingController(text: settings.host ?? '');
    final portCtrl = TextEditingController(text: '${settings.port}');
    final usernameCtrl = TextEditingController(text: settings.username ?? '');
    final passwordCtrl = TextEditingController();
    final fromEmailCtrl = TextEditingController(text: settings.fromEmail ?? '');
    final fromNameCtrl = TextEditingController(text: settings.fromName ?? '');
    final resetBaseUrlCtrl = TextEditingController(text: settings.resetBaseUrl ?? '');
    bool secure = settings.secure;
    bool saving = false;
    String? error;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Configurar e-mail de avisos'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: hostCtrl,
                      decoration: const InputDecoration(labelText: 'SMTP host'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: portCtrl,
                      decoration: const InputDecoration(labelText: 'SMTP porta'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: secure,
                      onChanged: saving ? null : (value) => setStateDialog(() => secure = value),
                      title: const Text('Conexao segura (SSL/TLS)'),
                    ),
                    TextField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(labelText: 'Usuario SMTP (opcional)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Senha SMTP',
                        helperText: 'Deixe vazio para manter a senha atual.',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: fromEmailCtrl,
                      decoration: const InputDecoration(labelText: 'E-mail remetente'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: fromNameCtrl,
                      decoration: const InputDecoration(labelText: 'Nome remetente (opcional)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: resetBaseUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL base reset senha (opcional)',
                        hintText: 'https://...',
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFC62828),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final host = hostCtrl.text.trim();
                          final port = int.tryParse(portCtrl.text.trim());
                          final fromEmail = fromEmailCtrl.text.trim();
                          if (host.isEmpty || port == null || fromEmail.isEmpty) {
                            setStateDialog(() {
                              error = 'Preencha host, porta e e-mail remetente.';
                            });
                            return;
                          }

                          setStateDialog(() {
                            saving = true;
                            error = null;
                          });

                          try {
                            await onSave(
                              host: host,
                              port: port,
                              secure: secure,
                              username: usernameCtrl.text.trim().isEmpty
                                  ? null
                                  : usernameCtrl.text.trim(),
                              password: passwordCtrl.text.trim().isEmpty ? null : passwordCtrl.text,
                              fromEmail: fromEmail,
                              fromName: fromNameCtrl.text.trim().isEmpty
                                  ? null
                                  : fromNameCtrl.text.trim(),
                              resetBaseUrl: resetBaseUrlCtrl.text.trim().isEmpty
                                  ? null
                                  : resetBaseUrlCtrl.text.trim(),
                            );
                            if (!context.mounted) return;
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Configuracao de e-mail salva com sucesso.'),
                              ),
                            );
                          } catch (e) {
                            setStateDialog(() {
                              error = '$e';
                              saving = false;
                            });
                          }
                        },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    hostCtrl.dispose();
    portCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    fromEmailCtrl.dispose();
    fromNameCtrl.dispose();
    resetBaseUrlCtrl.dispose();
  }
}

String _roleLabelFromLevel(int level) {
  switch (level) {
    case 1:
      return AppRole.membroPastoral.label;
    case 2:
      return AppRole.coordenador.label;
    case 3:
      return 'Administrativo / Padre';
    default:
      return AppRole.usuarioPadrao.label;
  }
}
