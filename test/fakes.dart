import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:appointment_system/data/admin_repository.dart';
import 'package:appointment_system/data/appointment_repository.dart';
import 'package:appointment_system/data/auth_repository.dart';
import 'package:appointment_system/data/department_repository.dart';
import 'package:appointment_system/data/provider_repository.dart';
import 'package:appointment_system/models/appointment.dart';
import 'package:appointment_system/models/business_settings.dart';
import 'package:appointment_system/models/department.dart';
import 'package:appointment_system/models/managed_user.dart';
import 'package:appointment_system/models/provider.dart';
import 'package:appointment_system/models/user_profile.dart';

/// In-memory stand-ins for the Firebase repositories, shared by all tests.

class FakeAuth implements AuthRepository {
  final _c = StreamController<UserProfile?>.broadcast();
  @override
  Stream<UserProfile?> watchProfile() => _c.stream;
  void emit(UserProfile? p) => _c.add(p);
  @override
  Future<void> signIn(String email, String password) async {}
  @override
  Future<void> signUp(String name, String email, String password) async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<void> sendPasswordReset(String email) async {}
  @override
  Future<void> updateDisplayName(String name) async {}
  @override
  Future<void> updatePhone(String phone) async {}
  /// How many verification emails were sent; set [verificationError] to make
  /// sending fail instead.
  int verificationEmailsSent = 0;
  Object? verificationError;
  @override
  Future<void> sendEmailVerification() async {
    if (verificationError != null) throw verificationError!;
    verificationEmailsSent++;
  }
  @override
  Future<void> setEmailLanguage(String languageCode) async {}
  @override
  Future<bool> reloadAndCheckVerified() async => true;
  @override
  Future<void> changePassword(
          {required String currentPassword, required String newPassword}) async {}
  /// The only password [reauthenticate] accepts.
  String password = 'secret1';
  bool accountDeleted = false;
  @override
  Future<void> reauthenticate(String password) async {
    if (password != this.password) throw FirebaseAuthException(code: 'wrong-password');
  }

  @override
  Future<void> deleteAccount() async {
    accountDeleted = true;
    emit(null); // like Firebase: deleting the login signs the user out
  }
}

/// In-memory store that mimics the real repo's atomic, per-provider slot
/// reservation.
class FakeRepo implements AppointmentRepository {
  final _all = <Appointment>[];
  final _busy = <String>{}; // "<providerId>_<slotKey>"
  final _changes = StreamController<void>.broadcast();

  String _slotId(String providerId, String key) => '${providerId}_$key';

  @override
  Stream<List<Appointment>> watchMine(String customerId) async* {
    yield _all.where((a) => a.customerId == customerId).toList();
    await for (final _ in _changes.stream) {
      yield _all.where((a) => a.customerId == customerId).toList();
    }
  }

  @override
  Stream<List<Appointment>> watchForProvider(String providerId) async* {
    yield _all.where((a) => a.providerId == providerId).toList();
    await for (final _ in _changes.stream) {
      yield _all.where((a) => a.providerId == providerId).toList();
    }
  }

  @override
  Stream<Set<String>> watchBusySlots(String providerId) async* {
    Set<String> forProvider() => _busy
        .where((id) => id.startsWith('${providerId}_'))
        .map((id) => id.substring(providerId.length + 1))
        .toSet();
    yield forProvider();
    await for (final _ in _changes.stream) {
      yield forProvider();
    }
  }

  @override
  Future<void> book(Appointment a) async {
    final ids = [
      for (final key in slotKeys(a.start, a.serviceMinutes)) _slotId(a.providerId, key),
    ];
    if (ids.any(_busy.contains)) throw StateError('slot taken');
    _busy.addAll(ids);
    _all.add(Appointment(
      id: '${_all.length}',
      customerId: a.customerId,
      customerName: a.customerName,
      providerId: a.providerId,
      providerName: a.providerName,
      serviceId: a.serviceId,
      serviceName: a.serviceName,
      serviceMinutes: a.serviceMinutes,
      start: a.start,
      status: a.status,
      note: a.note,
    ));
    _changes.add(null);
  }

  /// Adds an appointment in any status (e.g. an already-confirmed one).
  void seed(Appointment a) {
    if (a.blocksSlot) {
      _busy.addAll(
          [for (final key in slotKeys(a.start, a.serviceMinutes)) _slotId(a.providerId, key)]);
    }
    _all.add(a);
    _changes.add(null);
  }

  @override
  Future<void> setStatus(Appointment a, AppointmentStatus status) async {
    final i = _all.indexWhere((x) => x.id == a.id);
    _all[i] = _all[i].copyWith(status: status);
    if (status == AppointmentStatus.rejected ||
        status == AppointmentStatus.cancelled) {
      _busy.removeAll(
          [for (final key in slotKeys(a.start, a.serviceMinutes)) _slotId(a.providerId, key)]);
    }
    _changes.add(null);
  }
}

class FakeProviders implements ProviderRepository {
  final Map<String, Provider> _byId = {};
  final _c = StreamController<void>.broadcast();

  void seed(String uid, String name,
      {BusinessSettings? settings, String? departmentId, String? departmentName}) {
    _byId[uid] = Provider(
      uid: uid,
      name: name,
      settings: settings ?? BusinessSettings.fallback,
      departmentId: departmentId,
      departmentName: departmentName,
    );
    _c.add(null);
  }

  @override
  Stream<List<Provider>> watchAll() async* {
    yield _byId.values.toList();
    await for (final _ in _c.stream) {
      yield _byId.values.toList();
    }
  }

  @override
  Stream<Provider?> watchOne(String uid) async* {
    yield _byId[uid];
    await for (final _ in _c.stream) {
      yield _byId[uid];
    }
  }

  @override
  Future<void> save(String uid, String name, BusinessSettings settings) async {
    final existing = _byId[uid];
    _byId[uid] = Provider(
      uid: uid,
      name: name,
      settings: settings,
      departmentId: existing?.departmentId,
      departmentName: existing?.departmentName,
    );
    _c.add(null);
  }
}

class FakeDepartments implements DepartmentRepository {
  final Map<String, Department> _byId = {};
  final _c = StreamController<void>.broadcast();
  var _nextId = 0;

  @override
  Stream<List<Department>> watchAll() async* {
    yield _byId.values.toList();
    await for (final _ in _c.stream) {
      yield _byId.values.toList();
    }
  }

  @override
  Future<String> create(String name) async {
    final id = 'd${_nextId++}';
    _byId[id] = Department(id: id, name: name);
    _c.add(null);
    return id;
  }

  @override
  Future<void> rename(String id, String name) async {
    _byId[id] = Department(id: id, name: name);
    _c.add(null);
  }

  @override
  Future<void> delete(String id) async {
    _byId.remove(id);
    _c.add(null);
  }
}

class FakeAdmin implements AdminRepository {
  FakeAdmin(this._providers);
  final FakeProviders _providers;
  final Map<String, ManagedUser> _staff = {};
  final Map<String, ManagedUser> _patients = {};
  final _c = StreamController<void>.broadcast();
  var _nextUid = 0;

  void seedPatient(String uid, String name,
      {String email = '', String phone = '', bool suspended = false}) {
    _patients[uid] = ManagedUser(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        role: Role.customer,
        suspended: suspended);
    _c.add(null);
  }

  void seedStaff(ManagedUser user) {
    _staff[user.uid] = user;
    _c.add(null);
  }

  @override
  Stream<List<ManagedUser>> watchStaff() async* {
    yield _staff.values.toList();
    await for (final _ in _c.stream) {
      yield _staff.values.toList();
    }
  }

  @override
  Stream<List<ManagedUser>> watchPatients() async* {
    yield _patients.values.toList();
    await for (final _ in _c.stream) {
      yield _patients.values.toList();
    }
  }

  @override
  Future<void> createDoctor({
    required String name,
    required String email,
    required String password,
    required String departmentId,
    required String departmentName,
  }) async {
    final uid = 'doctor${_nextUid++}';
    _staff[uid] = ManagedUser(
        uid: uid,
        name: name,
        email: email,
        role: Role.provider,
        departmentId: departmentId,
        departmentName: departmentName);
    _providers.seed(uid, name, departmentId: departmentId, departmentName: departmentName);
    _c.add(null);
  }

  @override
  Future<void> setRole(String uid, Role role) async {
    _staff[uid] = _staff[uid]!.copyWith(role: role);
    _c.add(null);
  }

  @override
  Future<void> setDoctorDepartment(String uid, String departmentId, String departmentName) async {
    _staff[uid] =
        _staff[uid]!.copyWith(departmentId: departmentId, departmentName: departmentName);
    _c.add(null);
  }

  @override
  Future<void> renameStaff(String uid, String name) async {
    _staff[uid] = _staff[uid]!.copyWith(name: name);
    _c.add(null);
  }

  @override
  Future<void> deleteStaff(String uid) async {
    _staff.remove(uid);
    _c.add(null);
  }

  final sentPasswordResets = <String>[];

  @override
  Future<void> sendStaffPasswordReset(String email) async {
    sentPasswordResets.add(email);
  }

  @override
  Future<void> setPatientSuspended(String uid, bool suspended) async {
    _patients[uid] = _patients[uid]!.copyWith(suspended: suspended);
    _c.add(null);
  }

  @override
  Future<void> deletePatient(String uid) async {
    _patients.remove(uid);
    _c.add(null);
  }
}

/// Lets pending stream events and futures run.
Future<void> pump() => Future<void>.delayed(Duration.zero);
