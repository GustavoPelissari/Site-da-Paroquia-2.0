import 'package:flutter/material.dart';

import '../state/app_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarSenhaCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmarSenhaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomeCtrl,
                  enabled: !_loading,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.length < 2) return 'Informe seu nome completo.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  enabled: !_loading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final v = (value ?? '').trim();
                    const pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
                    if (!RegExp(pattern).hasMatch(v)) return 'Email inválido.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _senhaCtrl,
                  enabled: !_loading,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').length < 8) return 'Senha precisa ter ao menos 8 caracteres.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmarSenhaCtrl,
                  enabled: !_loading,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Senha',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != _senhaCtrl.text) return 'As senhas não conferem.';
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFC62828),
                        ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Criar conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await widget.appState.register(
      nome: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      senha: _senhaCtrl.text,
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = ok ? null : widget.appState.authError;
    });

    if (ok && mounted) {
      Navigator.pop(context);
    }
  }
}
