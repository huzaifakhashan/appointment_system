enum AppointmentStatus { pending, confirmed, rejected, cancelled }

class Service {
  const Service(this.id, this.name, this.minutes);
  final String id;
  final String name;
  final int minutes;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'minutes': minutes};

  factory Service.fromJson(Map<String, dynamic> j) => Service(
        j['id'] as String,
        j['name'] as String,
        (j['minutes'] as num).toInt(),
      );
}

class Appointment {
  const Appointment({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
    required this.serviceMinutes,
    required this.start,
    required this.status,
    this.note = '',
  });

  final String id;
  final String customerId;
  final String customerName;
  final String providerId;
  // The provider's and service's name/duration at booking time. Kept on the
  // appointment itself (not looked up live) so a provider renaming their
  // business or editing a service later never changes what past and pending
  // appointments say.
  final String providerName;
  final String serviceId;
  final String serviceName;
  final int serviceMinutes;
  final DateTime start;
  final AppointmentStatus status;
  final String note;

  DateTime get end => start.add(Duration(minutes: serviceMinutes));

  /// Pending and confirmed appointments block their time slot.
  bool get blocksSlot =>
      status == AppointmentStatus.pending ||
      status == AppointmentStatus.confirmed;

  bool overlaps(DateTime s, DateTime e) => start.isBefore(e) && end.isAfter(s);

  Appointment copyWith({AppointmentStatus? status}) => Appointment(
        id: id,
        customerId: customerId,
        customerName: customerName,
        providerId: providerId,
        providerName: providerName,
        serviceId: serviceId,
        serviceName: serviceName,
        serviceMinutes: serviceMinutes,
        start: start,
        status: status ?? this.status,
        note: note,
      );

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'customerName': customerName,
        'providerId': providerId,
        'providerName': providerName,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'serviceMinutes': serviceMinutes,
        'start': start.toIso8601String(),
        'status': status.name,
        'note': note,
      };

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
        id: j['id'] as String,
        customerId: j['customerId'] as String,
        customerName: j['customerName'] as String,
        providerId: (j['providerId'] as String?) ?? '',
        providerName: (j['providerName'] as String?) ?? '',
        serviceId: j['serviceId'] as String,
        serviceName: (j['serviceName'] as String?) ?? '',
        serviceMinutes: (j['serviceMinutes'] as num?)?.toInt() ?? 30,
        start: DateTime.parse(j['start'] as String),
        status: AppointmentStatus.values.byName(j['status'] as String),
        note: (j['note'] as String?) ?? '',
      );
}

/// Key of the 30-minute block starting at [t], e.g. `202609201430`.
String slotKey(DateTime t) {
  String p(int n) => n.toString().padLeft(2, '0');
  return '${t.year}${p(t.month)}${p(t.day)}${p(t.hour)}${p(t.minute)}';
}

/// Keys of every 30-minute block a [minutes]-long appointment covers.
List<String> slotKeys(DateTime start, int minutes) => [
      for (var m = 0; m < minutes; m += 30) slotKey(start.add(Duration(minutes: m))),
    ];
