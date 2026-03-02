import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/parish_info_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  static const String _logoAssetPath =
      'web-next/public/img/IMAGEM DE SÃO PAULO APOSTOLO MONOCROMATICA.png';
  static const String _paroquiaPhotoAssetPath = 'web-next/public/img/IMAGEM DA PAROQUIA.jpeg';
  static const String _address =
      'Av. Gen. Mascarenhas Moraes, 4969 - Zona V, Umuarama - PR, 87504-090';
  static const String _mapUrl =
      'https://www.google.com/maps?q=Av.+Gen.+Mascarenhas+Moraes,+4969+-+Zona+V,+Umuarama+-+PR,+87504-090';

  Future<_HorariosData>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HorariosData> _load({bool forceRefresh = false}) async {
    final massSchedules = await widget.appState.fetchMassSchedules(
      forceRefresh: forceRefresh,
    );
    final officeHours = await widget.appState.fetchOfficeHours(
      forceRefresh: forceRefresh,
    );
    final nextMass = await widget.appState.fetchNextMass(
      forceRefresh: forceRefresh,
    );
    return _HorariosData(
      massSchedules: massSchedules,
      officeHours: officeHours,
      nextMass: nextMass,
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final bottomInset = 104.0;

    return SafeArea(
      top: false,
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load(forceRefresh: true));
          await _future;
        },
        child: FutureBuilder<_HorariosData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 14, 16, bottomInset + safeBottom),
                children: [
                  Text(
                    'Horários',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD5D5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Não foi possível carregar os horários.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF912018),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() => _future = _load(forceRefresh: true)),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final data = snapshot.data!;
            final groupedMasses = _groupMassByDay(data.massSchedules);
            final groupedOffice = _groupOfficeByDay(data.officeHours);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 14, 16, bottomInset + safeBottom),
              children: [
                Text(
                  'Horários',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Missa, secretaria e localização da paróquia.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6A6361),
                      ),
                ),
                const SizedBox(height: 14),
                _buildHeroImage(),
                const SizedBox(height: 12),
                _AddressCard(
                  address: _address,
                  mapUrl: _mapUrl,
                  logoAssetPath: _logoAssetPath,
                ),
                const SizedBox(height: 12),
                _NextMassCard(nextMass: data.nextMass.nextMass),
                const SizedBox(height: 12),
                _MassScheduleCard(groupedMasses: groupedMasses),
                const SizedBox(height: 12),
                _OfficeHoursCard(groupedOffice: groupedOffice),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 8,
        child: Image.asset(
          _paroquiaPhotoAssetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFF2E7E9),
            alignment: Alignment.center,
            child: const Icon(
              Icons.photo_outlined,
              color: AppTheme.vinhoParoquial,
              size: 42,
            ),
          ),
        ),
      ),
    );
  }

  List<_DayGroup> _groupMassByDay(List<MassScheduleModel> items) {
    final map = <int, List<MassScheduleModel>>{};
    for (final item in items.where((e) => e.isActive)) {
      map.putIfAbsent(item.weekday, () => <MassScheduleModel>[]).add(item);
    }
    final entries = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .map(
          (entry) => _DayGroup(
            weekdayLabel: entry.value.first.weekdayLabel,
            items: entry.value..sort((a, b) => a.time.compareTo(b.time)),
          ),
        )
        .toList();
  }

  List<_DayOfficeGroup> _groupOfficeByDay(List<OfficeHourModel> items) {
    final map = <int, List<OfficeHourModel>>{};
    for (final item in items.where((e) => e.isActive)) {
      map.putIfAbsent(item.weekday, () => <OfficeHourModel>[]).add(item);
    }
    final entries = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .map(
          (entry) => _DayOfficeGroup(
            weekdayLabel: entry.value.first.weekdayLabel,
            items: entry.value..sort((a, b) => a.openTime.compareTo(b.openTime)),
          ),
        )
        .toList();
  }
}

class _HorariosData {
  _HorariosData({
    required this.massSchedules,
    required this.officeHours,
    required this.nextMass,
  });

  final List<MassScheduleModel> massSchedules;
  final List<OfficeHourModel> officeHours;
  final NextMassModel nextMass;
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.mapUrl,
    required this.logoAssetPath,
  });

  final String address;
  final String mapUrl;
  final String logoAssetPath;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Endereço da Paróquia',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF6ECEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              logoAssetPath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.church_outlined,
                color: AppTheme.vinhoParoquial,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(address, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(mapUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Ver no mapa'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextMassCard extends StatelessWidget {
  const _NextMassCard({required this.nextMass});

  final NextMassItemModel? nextMass;

  @override
  Widget build(BuildContext context) {
    final label = nextMass == null
        ? 'Sem horários ativos no momento.'
        : '${nextMass!.weekdayLabel}, ${nextMass!.time} - ${nextMass!.locationName}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.vinhoParoquial,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próxima Missa',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MassScheduleCard extends StatelessWidget {
  const _MassScheduleCard({required this.groupedMasses});

  final List<_DayGroup> groupedMasses;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Horários de Missa',
      child: groupedMasses.isEmpty
          ? Text(
              'Sem horários cadastrados.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : Column(
              children: groupedMasses
                  .map(
                    (group) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              group.weekdayLabel,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.vinhoParoquial,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              group.items.map((e) => '${e.time} (${e.locationName})').join('; '),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _OfficeHoursCard extends StatelessWidget {
  const _OfficeHoursCard({required this.groupedOffice});

  final List<_DayOfficeGroup> groupedOffice;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Horários da Secretaria',
      child: groupedOffice.isEmpty
          ? Text(
              'Em atualização.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : Column(
              children: groupedOffice
                  .map(
                    (group) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              group.weekdayLabel,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.vinhoParoquial,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              group.items
                                  .map((e) => e.closeTime == null
                                      ? e.openTime
                                      : '${e.openTime} - ${e.closeTime}')
                                  .join('; '),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E2E2)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DayGroup {
  _DayGroup({required this.weekdayLabel, required this.items});

  final String weekdayLabel;
  final List<MassScheduleModel> items;
}

class _DayOfficeGroup {
  _DayOfficeGroup({required this.weekdayLabel, required this.items});

  final String weekdayLabel;
  final List<OfficeHourModel> items;
}
