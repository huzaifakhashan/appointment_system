import '../models/appointment.dart';

/// Storage contract for bookings. [FirebaseAppointmentRepository] is the real
/// implementation; tests use an in-memory fake.
abstract class AppointmentRepository {
  /// Appointments a customer made, across every provider.
  Stream<List<Appointment>> watchMine(String customerId);

  /// Every appointment made with one provider.
  Stream<List<Appointment>> watchForProvider(String providerId);

  /// Keys (see [slotKey]) of every busy 30-minute block for [providerId],
  /// from today onwards.
  Stream<Set<String>> watchBusySlots(String providerId);

  /// Stores [a] as pending and reserves its time blocks with its provider,
  /// atomically. Throws if any block is already taken.
  Future<void> book(Appointment a);

  /// Changes the status. Rejecting or cancelling frees the time blocks.
  Future<void> setStatus(Appointment a, AppointmentStatus status);
}
