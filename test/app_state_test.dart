import 'dart:ui' show Locale;

import 'package:appointment_system/l10n/app_localizations.dart';
import 'package:appointment_system/models/appointment.dart';
import 'package:appointment_system/models/provider.dart';
import 'package:appointment_system/models/user_profile.dart';
import 'package:appointment_system/services/notification_service.dart';
import 'package:appointment_system/state/app_state.dart';
import 'package:appointment_system/utils/error_messages.dart';
import 'package:appointment_system/utils/service_names.dart';
import 'package:appointment_system/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  late FakeAuth auth;
  late FakeRepo repo;
  late FakeProviders providerRepo;
  late FakeDepartments departmentRepo;
  late FakeAdmin adminRepo;
  late AppState state;
  // Two days out, skipped forward past the fallback schedule's closed
  // Friday so this doesn't flake depending on which day it's run.
  final day = () {
    var d = DateTime.now().add(const Duration(days: 2));
    while (d.weekday == DateTime.friday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }();

  const clinicA = 'clinicA';
  const clinicB = 'clinicB';

  setUp(() async {
    auth = FakeAuth();
    repo = FakeRepo();
    providerRepo = FakeProviders();
    departmentRepo = FakeDepartments();
    adminRepo = FakeAdmin(providerRepo);
    providerRepo.seed(clinicA, 'Clinic A');
    providerRepo.seed(clinicB, 'Clinic B');
    state = AppState(auth, repo, providerRepo, departmentRepo, adminRepo, NotificationService());
    auth.emit(const UserProfile('u1', 'Sara', Role.customer));
    await pump();
  });

  tearDown(() => state.dispose());

  Provider clinic(String id) => state.providers.firstWhere((p) => p.uid == id);
  Service consult(String id) => clinic(id).settings.services.first;
  Service checkup(String id) => clinic(id).settings.services[1]; // 60 min

  test('customer sees the provider directory', () {
    expect(state.providers.map((p) => p.name), containsAll(['Clinic A', 'Clinic B']));
  });

  test('booked slot disappears; rejecting frees it again', () async {
    final p = clinic(clinicA);
    final service = consult(clinicA);
    final busy = <String>{};
    final slot = p.settings.freeSlotsOn(day, service, busy).first;

    await state.book(p, service, slot, '');
    await pump();
    final stillBusy = await repo.watchBusySlots(clinicA).first;
    expect(p.settings.freeSlotsOn(day, service, stillBusy), isNot(contains(slot)));
    expect(state.mine.single.status, AppointmentStatus.pending);

    await state.setStatus(state.mine.single, AppointmentStatus.rejected);
    await pump();
    final freedBusy = await repo.watchBusySlots(clinicA).first;
    expect(p.settings.freeSlotsOn(day, service, freedBusy), contains(slot));
  });

  test('two clinics never block each other for the same time', () async {
    final pA = clinic(clinicA);
    final pB = clinic(clinicB);
    final slot = pA.settings.freeSlotsOn(day, consult(clinicA), {}).first;

    await state.book(pA, consult(clinicA), slot, '');
    await pump();

    // Clinic B's own slot at the same time is still free.
    final busyB = await repo.watchBusySlots(clinicB).first;
    expect(pB.settings.freeSlotsOn(day, consult(clinicB), busyB), contains(slot));
    // Booking it with clinic B does not throw.
    await state.book(pB, consult(clinicB), slot, '');
  });

  test('long service blocks overlapping half-hour slots at that clinic', () async {
    final p = clinic(clinicA);
    final service = checkup(clinicA);
    final slot = p.settings.freeSlotsOn(day, service, {}).first;
    await state.book(p, service, slot, '');
    await pump();

    final busy = await repo.watchBusySlots(clinicA).first;
    final next = slot.add(const Duration(minutes: 30));
    expect(p.settings.freeSlotsOn(day, consult(clinicA), busy), isNot(contains(next)));
  });

  test('double booking the same slot at the same clinic is rejected', () async {
    final p = clinic(clinicA);
    final service = consult(clinicA);
    final slot = p.settings.freeSlotsOn(day, service, {}).first;
    await state.book(p, service, slot, '');
    expect(() => state.book(p, service, slot, ''), throwsStateError);
  });

  test('a provider only sees appointments made with them', () async {
    final pA = clinic(clinicA);
    final pB = clinic(clinicB);
    await state.book(pA, consult(clinicA), pA.settings.freeSlotsOn(day, consult(clinicA), {}).first, '');
    await state.book(pB, consult(clinicB), pB.settings.freeSlotsOn(day, consult(clinicB), {}).first, '');

    auth.emit(const UserProfile(clinicA, 'Clinic A', Role.provider));
    await pump();
    await pump();
    expect(state.isProvider, isTrue);
    expect(state.pending, hasLength(1));
    expect(state.pending.single.providerId, clinicA);
  });

  test('a booking keeps its provider and service name even if edited later', () async {
    final p = clinic(clinicA);
    final service = consult(clinicA);
    await state.book(p, service, p.settings.freeSlotsOn(day, service, {}).first, '');
    await pump();

    await providerRepo.save(clinicA, 'Renamed Clinic',
        p.settings.copyWith(services: [Service(service.id, 'Renamed', 45), ...p.settings.services.skip(1)]));
    await pump();

    expect(state.mine.single.providerName, 'Clinic A');
    expect(state.mine.single.serviceName, service.name);
  });

  test('no free slots on a day the clinic is closed', () async {
    final p = clinic(clinicA);
    final service = consult(clinicA);
    final closed = p.settings.copyWith(closedWeekdays: {day.weekday});
    expect(closed.freeSlotsOn(day, service, {}), isEmpty);
  });

  test('slotKey format', () {
    expect(slotKey(DateTime(2026, 9, 20, 14, 30)), '202609201430');
    expect(slotKeys(DateTime(2026, 9, 20, 9), 60), ['202609200900', '202609200930']);
  });

  test('future bookings are upcoming, not past', () async {
    final p = clinic(clinicA);
    final service = consult(clinicA);
    await state.book(p, service, p.settings.freeSlotsOn(day, service, {}).first, '');
    await pump();
    expect(state.upcoming, hasLength(1));
    expect(state.past, isEmpty);
  });

  group('deleting an account', () {
    Appointment past() => Appointment(
          id: 'old',
          customerId: 'u1',
          customerName: 'Sara',
          providerId: clinicA,
          providerName: 'Clinic A',
          serviceId: 'consult',
          serviceName: 'Consultation',
          serviceMinutes: 30,
          start: DateTime.now().subtract(const Duration(days: 30)),
          status: AppointmentStatus.confirmed,
        );

    test('cancels upcoming appointments, keeps past ones, deletes', () async {
      final p = clinic(clinicA);
      final service = consult(clinicA);
      final slot = p.settings.freeSlotsOn(day, service, {}).first;
      await state.book(p, service, slot, '');
      repo.seed(past());
      await pump();

      await state.deleteMyAccount('secret1');
      await pump();

      expect(auth.accountDeleted, isTrue);
      expect(state.profile, isNull); // signed out
      // The doctor gets the time back...
      final busy = await repo.watchBusySlots(clinicA).first;
      expect(p.settings.freeSlotsOn(day, service, busy), contains(slot));
      // ...and still has the past visit in their records.
      auth.emit(const UserProfile(clinicA, 'Clinic A', Role.provider));
      await pump();
      await pump();
      final statuses = {for (final a in state.mine) a.id: a.status};
      expect(statuses['old'], AppointmentStatus.confirmed);
      expect(statuses.values, contains(AppointmentStatus.cancelled));
    });

    test('a wrong password changes nothing', () async {
      final p = clinic(clinicA);
      final service = consult(clinicA);
      await state.book(p, service, p.settings.freeSlotsOn(day, service, {}).first, '');
      await pump();

      await expectLater(state.deleteMyAccount('wrong'), throwsA(isA<FirebaseAuthException>()));
      await pump();
      expect(auth.accountDeleted, isFalse);
      expect(state.mine.single.status, AppointmentStatus.pending);
    });

    test('staff accounts cannot delete themselves', () async {
      auth.emit(const UserProfile(clinicA, 'Clinic A', Role.provider));
      await pump();
      await state.deleteMyAccount('secret1');
      expect(auth.accountDeleted, isFalse);
    });
  });

  test('unknown or missing roles fall back to patient', () {
    expect(Role.fromName('admin'), Role.admin);
    expect(Role.fromName('provider'), Role.provider);
    expect(Role.fromName('superuser'), Role.customer);
    expect(Role.fromName(null), Role.customer);
  });

  test('validators', () {
    final v = Validators(lookupAppLocalizations(const Locale('en')));
    expect(v.email('sara@example.com'), isNull);
    expect(v.email('sara@'), isNotNull);
    expect(v.email('not an email'), isNotNull);
    expect(v.newPassword('12345'), isNotNull);
    expect(v.newPassword('123456'), isNull);
    expect(v.phone(''), isNull); // optional
    expect(v.phone('+964 770 123 4567'), isNull);
    expect(v.phone('abc'), isNotNull);
    expect(v.required()('  '), isNotNull);
  });

  test('default services are translated, renamed ones are not', () {
    final ar = lookupAppLocalizations(const Locale('ar'));
    final en = lookupAppLocalizations(const Locale('en'));
    expect(serviceDisplayName(ar, 'followup', 'Follow-up'), 'مراجعة');
    expect(serviceDisplayName(ar, 'consult', 'Consultation'), 'استشارة');
    expect(serviceDisplayName(en, 'checkup', 'Check-up'), 'Check-up');
    // A doctor renamed it, or added their own service: shown as typed.
    expect(serviceDisplayName(ar, 'followup', 'Post-op visit'), 'Post-op visit');
    expect(serviceDisplayName(ar, '1726', 'تنظيف أسنان'), 'تنظيف أسنان');
  });

  test('non-Firebase errors get the generic message', () {
    final t = lookupAppLocalizations(const Locale('en'));
    expect(errorMessage(t, StateError('boom')), t.authErrorGeneric);
  });

  group('admin', () {
    setUp(() async {
      auth.emit(const UserProfile('admin1', 'Admin', Role.admin));
      await pump();
    });

    test('creates a department and a doctor in it, visible to patients', () async {
      final id = await state.createDepartment('Dentistry');
      await pump();
      expect(state.departments.map((d) => d.name), contains('Dentistry'));

      await state.createDoctor(
          name: 'Dr. Amal',
          email: 'amal@example.com',
          password: 'password123',
          department: state.departments.first);
      await pump();
      expect(state.staff, hasLength(1));
      expect(state.staff.single.departmentId, id);
      expect(state.staff.single.role, Role.provider);

      // The new doctor shows up in the patient-facing directory too.
      auth.emit(const UserProfile('u1', 'Sara', Role.customer));
      await pump();
      final doctor = state.providers.firstWhere((p) => p.name == 'Dr. Amal');
      expect(doctor.departmentName, 'Dentistry');
    });

    test('can promote a doctor to admin', () async {
      await state.createDepartment('Ophthalmology');
      await pump();
      await state.createDoctor(
          name: 'Dr. Omar',
          email: 'omar@example.com',
          password: 'password123',
          department: state.departments.first);
      await pump();

      final doctor = state.staff.single;
      await state.setStaffRole(doctor.uid, Role.admin);
      await pump();
      expect(state.staff.single.role, Role.admin);
    });

    test('deleting a department removes it from the list', () async {
      final id = await state.createDepartment('Cardiology');
      await pump();
      expect(state.departments.map((d) => d.id), contains(id));

      await state.deleteDepartment(id);
      await pump();
      expect(state.departments.map((d) => d.id), isNot(contains(id)));
    });

    test('can rename and then remove a doctor', () async {
      await state.createDepartment('Dermatology');
      await pump();
      await state.createDoctor(
          name: 'Dr. Lina',
          email: 'lina@example.com',
          password: 'password123',
          department: state.departments.first);
      await pump();

      final doctor = state.staff.single;
      await state.renameStaff(doctor.uid, 'Dr. Lina Haddad');
      await pump();
      expect(state.staff.single.name, 'Dr. Lina Haddad');

      await state.deleteStaff(doctor.uid);
      await pump();
      expect(state.staff, isEmpty);
    });

    test('sees the patient directory', () async {
      adminRepo.seedPatient('p1', 'Sara', email: 'sara@example.com', phone: '070123456');
      await pump();
      expect(state.patients, hasLength(1));
      expect(state.patients.single.email, 'sara@example.com');
      expect(state.patients.single.phone, '070123456');
    });

    test('can suspend, unsuspend, and remove a patient', () async {
      adminRepo.seedPatient('p1', 'Sara', email: 'sara@example.com');
      await pump();
      expect(state.patients.single.suspended, isFalse);

      await state.setPatientSuspended('p1', true);
      await pump();
      expect(state.patients.single.suspended, isTrue);

      await state.setPatientSuspended('p1', false);
      await pump();
      expect(state.patients.single.suspended, isFalse);

      await state.deletePatient('p1');
      await pump();
      expect(state.patients, isEmpty);
    });

    test('can send a staff member a password reset email', () async {
      await state.createDepartment('ENT');
      await pump();
      await state.createDoctor(
          name: 'Dr. Nabil',
          email: 'nabil@example.com',
          password: 'password123',
          department: state.departments.first);
      await pump();

      await state.sendStaffPasswordReset(state.staff.single.email);
      expect(adminRepo.sentPasswordResets, contains('nabil@example.com'));
    });
  });
}
