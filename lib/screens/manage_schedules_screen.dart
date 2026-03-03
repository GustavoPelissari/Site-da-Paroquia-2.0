import 'package:flutter/material.dart';

import '../models/parish_info_model.dart';
import '../state/app_state.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_view.dart';

class ManageSchedulesScreen extends StatefulWidget {
  const ManageSchedulesScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<ManageSchedulesScreen> createState() => _ManageSchedulesScreenState();
}

class _ManageSchedulesScreenState extends State<ManageSchedulesScreen> {
  bool _loading = true;
  String? _error;
  List<MassScheduleModel> _masses = <MassScheduleModel>[];
  List<OfficeHourModel> _offices = <OfficeHourModel>[];
  String? _busyKey;

  static const List<_WeekdayOption> _weekdayOptions = [
    _WeekdayOption(value: 0, label: 'Domingo'),
    _WeekdayOption(value: 1, label: 'Segunda'),
    _WeekdayOption(value: 2, label: 'Terca'),
    _WeekdayOption(value: 3, label: 'Quarta'),
    _WeekdayOption(value: 4, label: 'Quinta'),
    _WeekdayOption(value: 5, label: 'Sexta'),
    _WeekdayOption(value: 6, label: 'Sabado'),
  ];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final masses = await widget.appState.fetchMassSchedules(forceRefresh: true);
      final offices = await widget.appState.fetchOfficeHours(forceRefresh: true);
      masses.sort((a, b) {
        final byDay = a.weekday.compareTo(b.weekday);
        if (byDay != 0) return byDay;
        return a.time.compareTo(b.time);
      });
      offices.sort((a, b) {
        final byDay = a.weekday.compareTo(b.weekday);
        if (byDay != 0) return byDay;
        return a.openTime.compareTo(b.openTime);
      });
      setState(() {
        _masses = masses;
        _offices = offices;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.appState.canManageMassSchedules) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gerenciar horarios')),
        body: const SafeArea(
          child: AppEmptyState(
            icon: Icons.lock_outline_rounded,
            title: 'Acesso negado',
            subtitle: 'Somente perfis administrativos podem alterar horarios.',
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gerenciar horarios'),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFFD8C4CA),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Missas'),
              Tab(text: 'Secretaria'),
            ],
          ),
        ),
        body: SafeArea(
          child: _loading && _masses.isEmpty && _offices.isEmpty
              ? const AppLoadingView(message: 'Carregando horarios...')
              : Column(
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: _InlineWarning(message: _error!, onRetry: _reload),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _reload,
                        child: TabBarView(
                          children: [
                            _buildMassTab(),
                            _buildOfficeTab(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMassTab() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _openCreateMassForm,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Novo horario de missa'),
          ),
        ),
        const SizedBox(height: 14),
        if (_masses.isEmpty)
          const AppEmptyState(
            icon: Icons.event_busy_outlined,
            title: 'Sem horarios de missa',
            subtitle: 'Crie um horario para aparecer aqui.',
          ),
        ..._masses.map(_buildMassCard),
      ],
    );
  }

  Widget _buildOfficeTab() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _openCreateOfficeForm,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Novo horario da secretaria'),
          ),
        ),
        const SizedBox(height: 14),
        if (_offices.isEmpty)
          const AppEmptyState(
            icon: Icons.schedule_outlined,
            title: 'Sem horarios da secretaria',
            subtitle: 'Crie um horario para aparecer aqui.',
          ),
        ..._offices.map(_buildOfficeCard),
      ],
    );
  }

  Widget _buildMassCard(MassScheduleModel item) {
    final busy = _busyKey == 'mass:${item.id}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.weekdayLabel} - ${item.time}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(item.locationName),
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(item.notes!, style: const TextStyle(color: Color(0xFF6A6361))),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: busy ? null : () => _openEditMassForm(item),
                child: const Text('Editar'),
              ),
              TextButton(
                onPressed: busy ? null : () => _deactivateMass(item),
                child: const Text('Desativar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeCard(OfficeHourModel item) {
    final busy = _busyKey == 'office:${item.id}';
    final timeLabel =
        item.closeTime == null || item.closeTime!.isEmpty ? item.openTime : '${item.openTime} - ${item.closeTime}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.weekdayLabel} - $timeLabel',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(item.label),
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(item.notes!, style: const TextStyle(color: Color(0xFF6A6361))),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: busy ? null : () => _openEditOfficeForm(item),
                child: const Text('Editar'),
              ),
              TextButton(
                onPressed: busy ? null : () => _deactivateOffice(item),
                child: const Text('Desativar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openCreateMassForm() async {
    await _openMassForm();
  }

  Future<void> _openEditMassForm(MassScheduleModel item) async {
    await _openMassForm(existing: item);
  }

  Future<void> _openMassForm({MassScheduleModel? existing}) async {
    final form = await showModalBottomSheet<_MassFormData>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MassFormSheet(
        options: _weekdayOptions,
        existing: existing,
      ),
    );
    if (form == null) return;

    final key = 'mass:${existing?.id ?? 'new'}';
    setState(() => _busyKey = key);
    try {
      if (existing == null) {
        await widget.appState.createMassSchedule(
          weekday: form.weekday,
          time: form.time,
          locationName: form.locationName,
          notes: form.notes,
        );
      } else {
        await widget.appState.updateMassSchedule(
          id: existing.id,
          weekday: form.weekday,
          time: form.time,
          locationName: form.locationName,
          notes: form.notes,
        );
      }
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(existing == null ? 'Horario criado com sucesso.' : 'Horario atualizado com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao salvar horario: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Future<void> _deactivateMass(MassScheduleModel item) async {
    final ok = await _confirmAction('Desativar horario de missa?');
    if (!ok) return;

    setState(() => _busyKey = 'mass:${item.id}');
    try {
      await widget.appState.deactivateMassSchedule(id: item.id);
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horario desativado.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao desativar horario: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Future<void> _openCreateOfficeForm() async {
    await _openOfficeForm();
  }

  Future<void> _openEditOfficeForm(OfficeHourModel item) async {
    await _openOfficeForm(existing: item);
  }

  Future<void> _openOfficeForm({OfficeHourModel? existing}) async {
    final form = await showModalBottomSheet<_OfficeFormData>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _OfficeFormSheet(
        options: _weekdayOptions,
        existing: existing,
      ),
    );
    if (form == null) return;

    final key = 'office:${existing?.id ?? 'new'}';
    setState(() => _busyKey = key);
    try {
      if (existing == null) {
        await widget.appState.createOfficeHour(
          weekday: form.weekday,
          openTime: form.openTime,
          closeTime: form.closeTime,
          label: form.label,
          notes: form.notes,
        );
      } else {
        await widget.appState.updateOfficeHour(
          id: existing.id,
          weekday: form.weekday,
          openTime: form.openTime,
          closeTime: form.closeTime,
          label: form.label,
          notes: form.notes,
        );
      }
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(existing == null ? 'Horario criado com sucesso.' : 'Horario atualizado com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao salvar horario: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Future<void> _deactivateOffice(OfficeHourModel item) async {
    final ok = await _confirmAction('Desativar horario da secretaria?');
    if (!ok) return;

    setState(() => _busyKey = 'office:${item.id}');
    try {
      await widget.appState.deactivateOfficeHour(id: item.id);
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horario desativado.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao desativar horario: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Future<bool> _confirmAction(String title) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );
    return result ?? false;
  }
}

class _InlineWarning extends StatelessWidget {
  const _InlineWarning({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

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
          const Icon(Icons.wifi_off_rounded, size: 18, color: Color(0xFFB42318)),
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

class _WeekdayOption {
  const _WeekdayOption({
    required this.value,
    required this.label,
  });

  final int value;
  final String label;
}

class _MassFormData {
  const _MassFormData({
    required this.weekday,
    required this.time,
    required this.locationName,
    this.notes,
  });

  final int weekday;
  final String time;
  final String locationName;
  final String? notes;
}

class _MassFormSheet extends StatefulWidget {
  const _MassFormSheet({
    required this.options,
    this.existing,
  });

  final List<_WeekdayOption> options;
  final MassScheduleModel? existing;

  @override
  State<_MassFormSheet> createState() => _MassFormSheetState();
}

class _MassFormSheetState extends State<_MassFormSheet> {
  late int _weekday;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _weekday = widget.existing?.weekday ?? 0;
    _timeCtrl = TextEditingController(text: widget.existing?.time ?? '');
    _locationCtrl = TextEditingController(text: widget.existing?.locationName ?? '');
    _notesCtrl = TextEditingController(text: widget.existing?.notes ?? '');
  }

  @override
  void dispose() {
    _timeCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.existing == null ? 'Novo horario de missa' : 'Editar horario de missa',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            initialValue: _weekday,
            decoration: const InputDecoration(labelText: 'Dia da semana', border: OutlineInputBorder()),
            items: widget.options
                .map((opt) => DropdownMenuItem(value: opt.value, child: Text(opt.label)))
                .toList(),
            onChanged: (value) => setState(() => _weekday = value ?? 0),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _timeCtrl,
            decoration: const InputDecoration(labelText: 'Horario (HH:mm)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _locationCtrl,
            decoration: const InputDecoration(labelText: 'Local', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(labelText: 'Observacoes (opcional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final time = _timeCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    final validTime = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').hasMatch(time);
    if (!validTime) {
      _showError('Informe horario valido no formato HH:mm.');
      return;
    }
    if (location.length < 2) {
      _showError('Informe um local valido.');
      return;
    }
    Navigator.pop(
      context,
      _MassFormData(
        weekday: _weekday,
        time: time,
        locationName: location,
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OfficeFormData {
  const _OfficeFormData({
    required this.weekday,
    required this.openTime,
    this.closeTime,
    required this.label,
    this.notes,
  });

  final int weekday;
  final String openTime;
  final String? closeTime;
  final String label;
  final String? notes;
}

class _OfficeFormSheet extends StatefulWidget {
  const _OfficeFormSheet({
    required this.options,
    this.existing,
  });

  final List<_WeekdayOption> options;
  final OfficeHourModel? existing;

  @override
  State<_OfficeFormSheet> createState() => _OfficeFormSheetState();
}

class _OfficeFormSheetState extends State<_OfficeFormSheet> {
  late int _weekday;
  late final TextEditingController _openTimeCtrl;
  late final TextEditingController _closeTimeCtrl;
  late final TextEditingController _labelCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _weekday = widget.existing?.weekday ?? 1;
    _openTimeCtrl = TextEditingController(text: widget.existing?.openTime ?? '');
    _closeTimeCtrl = TextEditingController(text: widget.existing?.closeTime ?? '');
    _labelCtrl = TextEditingController(text: widget.existing?.label ?? 'Secretaria');
    _notesCtrl = TextEditingController(text: widget.existing?.notes ?? '');
  }

  @override
  void dispose() {
    _openTimeCtrl.dispose();
    _closeTimeCtrl.dispose();
    _labelCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.existing == null ? 'Novo horario da secretaria' : 'Editar horario da secretaria',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            initialValue: _weekday,
            decoration: const InputDecoration(labelText: 'Dia da semana', border: OutlineInputBorder()),
            items: widget.options
                .map((opt) => DropdownMenuItem(value: opt.value, child: Text(opt.label)))
                .toList(),
            onChanged: (value) => setState(() => _weekday = value ?? 1),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _openTimeCtrl,
            decoration: const InputDecoration(labelText: 'Abertura (HH:mm)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _closeTimeCtrl,
            decoration: const InputDecoration(
              labelText: 'Fechamento (HH:mm - opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _labelCtrl,
            decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(labelText: 'Observacoes (opcional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final openTime = _openTimeCtrl.text.trim();
    final closeTime = _closeTimeCtrl.text.trim();
    final label = _labelCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    final validTime = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

    if (!validTime.hasMatch(openTime)) {
      _showError('Informe abertura valida no formato HH:mm.');
      return;
    }
    if (closeTime.isNotEmpty && !validTime.hasMatch(closeTime)) {
      _showError('Informe fechamento valido no formato HH:mm.');
      return;
    }
    if (label.length < 2) {
      _showError('Informe um nome valido para o horario.');
      return;
    }

    Navigator.pop(
      context,
      _OfficeFormData(
        weekday: _weekday,
        openTime: openTime,
        closeTime: closeTime.isEmpty ? null : closeTime,
        label: label,
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
