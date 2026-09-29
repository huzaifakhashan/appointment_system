import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment.dart';
import 'appointment_repository.dart';

class FirebaseAppointmentRepository implements AppointmentRepository {
  FirebaseAppointmentRepository([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _db.collection('appointments');
  CollectionReference<Map<String, dynamic>> get _slots => _db.collection('slots');

  List<Appointment> _parse(QuerySnapshot<Map<String, dynamic>> snap) => [
        for (final d in snap.docs) Appointment.fromJson({...d.data(), 'id': d.id}),
      ];

  @override
  Stream<List<Appointment>> watchMine(String customerId) => _appointments
      .where('customerId', isEqualTo: customerId)
      .snapshots()
      .map(_parse);

  @override
  Stream<List<Appointment>> watchForProvider(String providerId) => _appointments
      .where('providerId', isEqualTo: providerId)
      .snapshots()
      .map(_parse);

  // Slot doc ids are "<providerId>_<slotKey>" so different providers never
  // collide, and a range query on the id scopes to one provider from today.
  String _slotId(String providerId, String key) => '${providerId}_$key';

  @override
  Stream<Set<String>> watchBusySlots(String providerId) => _slots
      .where(FieldPath.documentId,
          isGreaterThanOrEqualTo: _slotId(providerId, slotKey(_today())))
      .where(FieldPath.documentId, isLessThan: '${providerId}_z')
      .snapshots()
      .map((s) => {for (final d in s.docs) d.id.substring(providerId.length + 1)});

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  Future<void> book(Appointment a) {
    final ref = _appointments.doc();
    final batch = _db.batch()..set(ref, a.toJson());
    for (final key in slotKeys(a.start, a.serviceMinutes)) {
      batch.set(_slots.doc(_slotId(a.providerId, key)),
          {'owner': a.customerId, 'providerId': a.providerId});
    }
    return batch.commit();
  }

  @override
  Future<void> setStatus(Appointment a, AppointmentStatus status) {
    final batch = _db.batch()
      ..update(_appointments.doc(a.id), {'status': status.name});
    if (status == AppointmentStatus.rejected ||
        status == AppointmentStatus.cancelled) {
      for (final key in slotKeys(a.start, a.serviceMinutes)) {
        batch.delete(_slots.doc(_slotId(a.providerId, key)));
      }
    }
    return batch.commit();
  }
}
