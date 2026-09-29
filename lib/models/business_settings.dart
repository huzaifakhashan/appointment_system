import 'appointment.dart';

/// A provider's working hours, closed weekdays, and offered services.
class BusinessSettings {
  const BusinessSettings({
    required this.openHour,
    required this.closeHour,
    required this.closedWeekdays,
    required this.services,
  });

  /// Used for a provider who hasn't saved settings of their own yet.
  static const fallback = BusinessSettings(
    openHour: 9,
    closeHour: 17,
    closedWeekdays: {DateTime.friday},
    services: [
      Service('consult', 'Consultation', 30),
      Service('checkup', 'Check-up', 60),
      Service('followup', 'Follow-up', 30),
    ],
  );

  final int openHour;
  final int closeHour;
  /// [DateTime.monday]..[DateTime.sunday] values the business is closed on.
  final Set<int> closedWeekdays;
  final List<Service> services;

  /// Free start times on [day] for [service], every 30 minutes, given the
  /// set of already-busy slot keys (see [slotKey]) for this provider.
  List<DateTime> freeSlotsOn(DateTime day, Service service, Set<String> busy) {
    final slots = <DateTime>[];
    if (closedWeekdays.contains(day.weekday)) return slots;
    final now = DateTime.now();
    final close = DateTime(day.year, day.month, day.day, closeHour);
    var t = DateTime(day.year, day.month, day.day, openHour);
    while (!t.add(Duration(minutes: service.minutes)).isAfter(close)) {
      final taken = slotKeys(t, service.minutes).any(busy.contains);
      if (t.isAfter(now) && !taken) slots.add(t);
      t = t.add(const Duration(minutes: 30));
    }
    return slots;
  }

  BusinessSettings copyWith({
    int? openHour,
    int? closeHour,
    Set<int>? closedWeekdays,
    List<Service>? services,
  }) =>
      BusinessSettings(
        openHour: openHour ?? this.openHour,
        closeHour: closeHour ?? this.closeHour,
        closedWeekdays: closedWeekdays ?? this.closedWeekdays,
        services: services ?? this.services,
      );

  Map<String, dynamic> toJson() => {
        'openHour': openHour,
        'closeHour': closeHour,
        'closedWeekdays': closedWeekdays.toList(),
        'services': [for (final s in services) s.toJson()],
      };

  factory BusinessSettings.fromJson(Map<String, dynamic> j) {
    final rawServices = j['services'] as List?;
    final rawDays = j['closedWeekdays'] as List?;
    return BusinessSettings(
      openHour: (j['openHour'] as num?)?.toInt() ?? fallback.openHour,
      closeHour: (j['closeHour'] as num?)?.toInt() ?? fallback.closeHour,
      closedWeekdays: rawDays == null
          ? fallback.closedWeekdays
          : {for (final d in rawDays) (d as num).toInt()},
      services: rawServices == null
          ? fallback.services
          : [
              for (final s in rawServices)
                Service.fromJson(s as Map<String, dynamic>),
            ],
    );
  }
}
