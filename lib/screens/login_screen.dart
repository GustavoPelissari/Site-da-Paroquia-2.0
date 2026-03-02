import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/app_state.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _logoAssetPath =
      'web-next/public/img/IMAGEM DE SÃO PAULO APOSTOLO MONOCROMATICA.png';

  final _emailCtrl = TextEditingController(text: 'maria.coordenadora@paroquia.local');
  final _senhaCtrl = TextEditingController(text: '123456');
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      width: 128,
                      height: 128,
                      child: ClipOval(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const ColoredBox(color: Color(0xFF80152B)),
                            Transform.translate(
                              offset: const Offset(0, 4),
                              child: Transform.scale(
                                scale: 1.08,
                                child: Image.asset(
                                  _logoAssetPath,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.church_outlined,
                                    color: Colors.white,
                                    size: 38,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Paróquia São Paulo Apóstolo',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Acesse com sua conta para continuar.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _emailCtrl,
                    enabled: !_loading,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _senhaCtrl,
                    enabled: !_loading,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEF9A9A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFFC62828),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RegisterScreen(appState: widget.appState),
                                  ),
                                );
                              },
                        child: const Text('Criar conta'),
                      ),
                      TextButton(
                        onPressed: _loading ? null : _onForgotPassword,
                        child: const Text('Esqueci minha senha'),
                      ),
                      TextButton(
                        onPressed: _loading ? null : _openPrivacyPolicy,
                        child: const Text('Política de Privacidade'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    bool ok = false;
    try {
      ok = await widget.appState
          .login(
            email: _emailCtrl.text.trim(),
            senha: _senhaCtrl.text,
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = ok
          ? null
          : (widget.appState.authError ??
              'Falha no login. Verifique servidor/API e tente novamente.');
    });
  }

  void _onForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar senha'),
        content: const Text(
          'Solicite redefinição de senha com a secretaria paroquial até o módulo de recuperação ser publicado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse('https://paroquia.local/politica-de-privacidade');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
