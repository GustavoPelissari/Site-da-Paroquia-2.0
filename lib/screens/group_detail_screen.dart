import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/form_model.dart';
import '../models/group_model.dart';
import '../models/news_model.dart';
import '../models/schedule_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_empty_state.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({
    super.key,
    required this.appState,
    required this.group,
  });

  final AppState appState;
  final GroupModel group;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    final isMember = widget.appState.isMemberOfGroup(widget.group.id);
    _tabIndex = isMember ? 0 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final isMember = widget.appState.isMemberOfGroup(widget.group.id);
    final canViewPrivate = widget.appState.canViewGroupPrivateContent(widget.group.id);
    final canSeeDocs = canViewPrivate && widget.group.permitePdfUpload;
    final canSeeNews = widget.group.permiteNoticias;
    final canSeeForms = widget.group.permiteFormularios;

    final tabs = <({String label, Widget body})>[
      if (canSeeNews)
        (
          label: 'Noticias',
          body: _NewsTab(news: widget.appState.newsByGroup(widget.group.id), isMember: isMember),
        ),
      if (canSeeDocs)
        (
          label: 'Docs',
          body: _DocsTab(
            schedules: widget.appState.schedulesByGroup(widget.group.id),
            canDownload: canViewPrivate,
          ),
        ),
      if (canSeeForms)
        (
          label: 'Formularios',
          body: _FormsTab(
            forms: widget.appState.formsByGroup(widget.group.id),
            appState: widget.appState,
            group: widget.group,
          ),
        ),
    ];

    if (_tabIndex >= tabs.length) _tabIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.nome),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            Text(
              widget.group.nome,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              isMember ? 'Voce e membro deste grupo.' : 'Acesso restrito aos membros.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isMember ? AppTheme.vinhoParoquial : const Color(0xFF6A6361),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _TabSelector(
              labels: tabs.map((t) => t.label).toList(),
              selectedIndex: _tabIndex,
              onChanged: (index) => setState(() => _tabIndex = index),
            ),
            const SizedBox(height: 14),
            if (tabs.isEmpty)
              const AppEmptyState(
                icon: Icons.lock_outline_rounded,
                title: 'Voce nao tem acesso a isso.',
                subtitle: 'Nao ha conteudo disponivel para seu perfil neste grupo.',
              )
            else
              tabs[_tabIndex].body,
          ],
        ),
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E2E2)),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == selectedIndex;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFF6ECEE) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selected ? AppTheme.vinhoParoquial : const Color(0xFF6A6361),
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DocsTab extends StatelessWidget {
  const _DocsTab({
    required this.schedules,
    required this.canDownload,
  });

  final List<ScheduleModel> schedules;
  final bool canDownload;

  @override
  Widget build(BuildContext context) {
    if (!canDownload) {
      return const AppEmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Voce nao tem acesso a isso.',
        subtitle: 'Somente membros autorizados podem abrir as escalas.',
      );
    }
    if (schedules.isEmpty) {
      return const AppEmptyState(
        icon: Icons.picture_as_pdf_outlined,
        title: 'Nenhum documento disponivel',
        subtitle: 'Novas escalas em PDF aparecerao aqui.',
      );
    }

    return Column(
      children: schedules
          .map(
            (s) => Container(
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
                    child: const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: AppTheme.vinhoParoquial,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.pdfLabel,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (s.descricao != null) ...[
                          const SizedBox(height: 4),
                          Text(s.descricao!, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      TextButton(
                        onPressed: () => _openPdf(context, s.pdfUrl, openOnly: true),
                        child: const Text('Abrir PDF'),
                      ),
                      TextButton(
                        onPressed: () => _openPdf(context, s.pdfUrl, openOnly: false),
                        child: const Text('Baixar PDF'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _openPdf(BuildContext context, String url, {required bool openOnly}) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Link de PDF invalido.')),
      );
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Falha de rede ao abrir arquivo.')),
      );
      return;
    }
    if (!openOnly) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Download iniciado no navegador.')),
      );
    }
  }
}

class _NewsTab extends StatelessWidget {
  const _NewsTab({
    required this.news,
    required this.isMember,
  });

  final List<NewsModel> news;
  final bool isMember;

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) {
      return AppEmptyState(
        icon: Icons.campaign_outlined,
        title: 'Sem noticias ainda',
        subtitle: isMember
            ? 'As noticias do grupo aparecerao aqui.'
            : 'Nenhuma noticia publica disponivel no momento.',
      );
    }
    return Column(
      children: news
          .map(
            (n) => Container(
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
                  Text(
                    n.titulo,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(n.conteudo, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FormsTab extends StatelessWidget {
  const _FormsTab({
    required this.forms,
    required this.appState,
    required this.group,
  });

  final List<FormModel> forms;
  final AppState appState;
  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    if (forms.isEmpty) {
      return const AppEmptyState(
        icon: Icons.assignment_outlined,
        title: 'Nenhum formulario disponivel',
        subtitle: 'Quando houver formularios ativos, eles aparecerao aqui.',
      );
    }

    return Column(
      children: forms
          .map(
            (form) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE8E2E2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.assignment_outlined, color: AppTheme.vinhoParoquial),
                  const SizedBox(width: 10),
                  Expanded(child: Text(form.titulo)),
                  TextButton(
                    onPressed: appState.hasResponded(form.id)
                        ? null
                        : () => _respond(context, form),
                    child: Text(appState.hasResponded(form.id) ? 'Respondido' : 'Responder'),
                  ),
                  if (appState.canManageGroup(group.id) || appState.canManageUsers)
                    TextButton(
                      onPressed: () {
                        final count =
                            appState.responsesCount(form.id, groupId: group.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Respostas registradas: $count')),
                        );
                      },
                      child: const Text('Resultados'),
                    ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _respond(BuildContext context, FormModel form) async {
    final ctrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(form.titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Sua resposta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                appState.submitFormResponse(formId: form.id, resposta: ctrl.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Enviar resposta'),
            ),
          ],
        ),
      ),
    );
  }
}
