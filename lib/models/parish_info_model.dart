class MassScheduleModel {
  MassScheduleModel({
    required this.id,
    required this.weekday,
    required this.weekdayLabel,
    required this.time,
    required this.locationName,
    required this.isActive,
    this.notes,
  });

  final String id;
  final int weekday;
  final String weekdayLabel;
  final String time;
  final String locationName;
  final bool isActive;
  final String? notes;
}

class OfficeHourModel {
  OfficeHourModel({
    required this.id,
    required this.weekday,
    required this.weekdayLabel,
    required this.openTime,
    required this.closeTime,
    required this.label,
    required this.isActive,
    this.notes,
  });

  final String id;
  final int weekday;
  final String weekdayLabel;
  final String openTime;
  final String? closeTime;
  final String label;
  final bool isActive;
  final String? notes;
}

class NextMassModel {
  NextMassModel({
    required this.serverNow,
    required this.nextMass,
  });

  final DateTime serverNow;
  final NextMassItemModel? nextMass;
}

class NextMassItemModel {
  NextMassItemModel({
    required this.id,
    required this.weekday,
    required this.weekdayLabel,
    required this.time,
    required this.locationName,
    required this.startsAt,
    this.notes,
  });

  final String id;
  final int weekday;
  final String weekdayLabel;
  final String time;
  final String locationName;
  final DateTime startsAt;
  final String? notes;
}
