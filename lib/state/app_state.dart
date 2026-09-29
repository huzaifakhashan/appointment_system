import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import '../data/admin_repository.dart';
import '../data/appointment_repository.dart';
import '../data/auth_repository.dart';
import '../data/department_repository.dart';
import '../data/provider_repository.dart';
import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../models/business_settings.dart';
import '../models/department.dart';
import '../models/managed_user.dart';
import '../models/provider.dart';
import '../models/user_profile.dart';
import '../services/notification_service.dart';
import '../utils/service_names.dart';

/// The app's single source of truth: who is signed in, and the live data
/// their role needs. Screens read it through `AppScope.of(context)`.
class AppState extends ChangeNotifier {
  AppState(this._auth, this._repo, this._providerRepo, this._departmentRepo,
      this._adminRepo, this._notifier) {
    _authSub = _auth.watchProfile().listen(
      _onProfile,
      onError: (Object e) {
        // e.g. the profile doc can't be read. Don't leave the app stuck on
        // the loading spinner — fall back to the sign-in screen.
        debugPrint('Profile stream: $e');
        if (loading) _onProfile(null);
      },
    );
  }

  final AuthRepository _auth;
  final AppointmentRepository _repo;
  final ProviderRepository _providerRepo;
  final DepartmentRepository _departmentRepo;
  final AdminRepository _adminRepo;
  final NotificationService _notifier;

  StreamSubscription<UserProfile?>? _authSub;
  final List<StreamSubscription<Object?>> _dataSubs = [];

  /// True until the first auth event arrives.
  bool loading = true;
  UserProfile? profile;
  List<Appointment> _all = [];

  /// Patient only: every bookable doctor.
  List<Provider> providers = [];

  /// Doctor only: this account's own profile and schedule.
  Provider? myProvider;

  /// Patient & admin: every department.
  List<Department> departments = [];

  /// Admin only: every doctor and admin account.
  List<ManagedUser> staff = [];

  /// Admin only: every patient account.
  List<ManagedUser> patients = [];

  /// Last seen status per appointment id, to detect changes worth notifying.
  final Map<String, AppointmentStatus> _known = {};
  bool _firstSnapshot = true;

  // Names of the streams that have delivered their first snapshot, so screens
  // can show a spinner instead of flashing "nothing here yet" while loading.
  final Set<String> _loaded = {};

  bool get appointmentsLoading => !_loaded.contains('appointments');
  bool get providersLoading => !_loaded.contains('providers');
  bool get myProviderLoading => !_loaded.contains('myProvider');
  bool get departmentsLoading => !_loaded.contains('departments');
  bool get staffLoading => !_loaded.contains('staff');
  bool get patientsLoading => !_loaded.contains('patients');

  // Notifications and Firebase's emails are built outside any widget, so the
  // UI pushes the resolved language here (see main.dart's MaterialApp.builder).
  Locale? _locale;
  void setLocale(Locale locale) {
    if (locale == _locale) return;
    _locale = locale;
    _auth.setEmailLanguage(locale.languageCode).catchError(
        (Object e) => debugPrint('Could not set email language: $e'));
  }

  bool get isProvider => profile?.role == Role.provider;
  bool get isAdmin => profile?.role == Role.admin;

  /// Every appointment of the signed-in patient/doctor, soonest first.
  List<Appointment> get mine => _sorted([..._all]);

  /// Appointments that haven't ended yet, soonest first.
  List<Appointment> get upcoming {
    final now = DateTime.now();
    return _sorted(_all.where((a) => a.end.isAfter(now)).toList());
  }

  /// Appointments that already ended, most recent first.
  List<Appointment> get past {
    final now = DateTime.now();
    return _sorted(_all.where((a) => !a.end.isAfter(now)).toList()).reversed.toList();
  }

  /// Doctor only: requests still waiting for an answer, soonest first.
  List<Appointment> get pending => _sorted(
      _all.where((a) => a.status == AppointmentStatus.pending).toList());

  /// Doctor only: active (pending/confirmed) appointments on [day].
  List<Appointment> onDay(DateTime day) => _sorted(_all
      .where((a) =>
          a.blocksSlot &&
          a.start.year == day.year &&
          a.start.month == day.month &&
          a.start.day == day.day)
      .toList());

  static List<Appointment> _sorted(List<Appointment> l) =>
      l..sort((a, b) => a.start.compareTo(b.start));

  Stream<Set<String>> watchBusySlots(String providerId) =>
      _repo.watchBusySlots(providerId);

  // --- Live data ------------------------------------------------------------

  void _onProfile(UserProfile? p) {
    final changedUser = p?.uid != profile?.uid || p?.role != profile?.role;
    profile = p;
    loading = false;
    if (changedUser) {
      _stopData();
      if (p != null) _startData(p);
    }
    notifyListeners();
  }

  /// Subscribes to [stream], marking [name] loaded on its first snapshot.
  void _listen<T>(String name, Stream<T> stream, void Function(T) onData) {
    _dataSubs.add(stream.listen(
      (value) {
        _loaded.add(name);
        onData(value);
        notifyListeners();
      },
      onError: (Object e) => debugPrint('$name stream: $e'),
    ));
  }

  static List<T> _byName<T>(List<T> list, String Function(T) name) =>
      list..sort((a, b) => name(a).toLowerCase().compareTo(name(b).toLowerCase()));

  void _startData(UserProfile p) {
    switch (p.role) {
      case Role.customer:
        _listen('appointments', _repo.watchMine(p.uid), _onAppointments);
        _listen('providers', _providerRepo.watchAll(),
            (list) => providers = _byName(list, (d) => d.name));
        _listen('departments', _departmentRepo.watchAll(),
            (list) => departments = _byName(list, (d) => d.name));
      case Role.provider:
        _listen('appointments', _repo.watchForProvider(p.uid), _onAppointments);
        _listen('myProvider', _providerRepo.watchOne(p.uid), (prov) => myProvider = prov);
      case Role.admin:
        _listen('departments', _departmentRepo.watchAll(),
            (list) => departments = _byName(list, (d) => d.name));
        _listen('staff', _adminRepo.watchStaff(),
            (list) => staff = _byName(list, (u) => u.displayName));
        _listen('patients', _adminRepo.watchPatients(),
            (list) => patients = _byName(list, (u) => u.displayName));
    }
  }

  void _stopData() {
    for (final sub in _dataSubs) {
      sub.cancel();
    }
    _dataSubs.clear();
    _all = [];
    providers = [];
    myProvider = null;
    departments = [];
    staff = [];
    patients = [];
    _known.clear();
    _firstSnapshot = true;
    _loaded.clear();
  }

  void _onAppointments(List<Appointment> list) {
    _all = list;
    _notifyChanges(list);
  }

  /// Turns appointment changes into local notifications and reminders.
  void _notifyChanges(List<Appointment> list) {
    final t = lookupAppLocalizations(_locale ?? const Locale('en'));
    for (final a in list) {
      final before = _known[a.id];
      _known[a.id] = a.status;
      if (before == a.status) continue;

      // The name of the *other* side of the booking.
      final other = isProvider ? a.customerName : a.providerName;
      if (a.status == AppointmentStatus.confirmed && a.start.isAfter(DateTime.now())) {
        _notifier.scheduleReminder(a,
            title: t.reminderTitle, body: t.reminderBody(a.serviceDisplay(t), other));
      } else if (!a.blocksSlot) {
        _notifier.cancelReminder(a.id);
      }

      // The first snapshot is just what already existed — nothing "new".
      if (_firstSnapshot) continue;
      final title = switch (a.status) {
        AppointmentStatus.pending when isProvider && before == null =>
          t.newBookingRequestTitle,
        AppointmentStatus.cancelled when isProvider => t.appointmentCancelledTitle,
        AppointmentStatus.confirmed when !isProvider => t.appointmentConfirmedTitle,
        AppointmentStatus.rejected when !isProvider => t.appointmentDeclinedTitle,
        _ => null,
      };
      if (title != null) _notifier.show(title, '$other · ${a.serviceDisplay(t)}');
    }
    _firstSnapshot = false;
  }

  // --- Account --------------------------------------------------------------

  Future<void> signIn(String email, String password) => _auth.signIn(email, password);

  bool _verificationEmailDue = false;

  /// Creates the account, then flags that its verification email still needs
  /// sending. The verify screen sends it (see [takeVerificationEmailDue]):
  /// by the time sign-up finishes, the sign-up form is already gone, so an
  /// error sent from here would never be seen.
  Future<void> signUp(String name, String email, String password) async {
    await _auth.signUp(name, email, password);
    _verificationEmailDue = true;
    notifyListeners();
  }

  /// True exactly once after a sign-up — the caller should send the
  /// verification email now.
  bool takeVerificationEmailDue() {
    final due = _verificationEmailDue;
    _verificationEmailDue = false;
    return due;
  }

  Future<void> sendPasswordReset(String email) => _auth.sendPasswordReset(email);

  /// The signed-in user's own name. A doctor's public name is edited from
  /// their schedule settings instead (see [saveMySettings]).
  Future<void> updateMyName(String name) => _auth.updateDisplayName(name);

  Future<void> updateMyPhone(String phone) => _auth.updatePhone(phone);

  Future<void> sendEmailVerification() => _auth.sendEmailVerification();

  /// Re-checks verification with the server and, if it just became true,
  /// updates [profile] immediately — the profile stream doesn't re-fire on
  /// its own after a token refresh.
  Future<bool> reloadAndCheckVerified() async {
    final verified = await _auth.reloadAndCheckVerified();
    if (verified && profile != null && !profile!.emailVerified) {
      profile = profile!.copyWith(emailVerified: true);
      notifyListeners();
    }
    return verified;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _auth.changePassword(currentPassword: currentPassword, newPassword: newPassword);

  /// Patients only: deletes the account for good. The password is checked
  /// first, so a typo can't leave the account half-deleted. Upcoming
  /// appointments are cancelled so doctors get those times back; past ones
  /// stay in the doctors' records.
  Future<void> deleteMyAccount(String password) async {
    final p = profile;
    if (p == null || p.role != Role.customer) return;
    await _auth.reauthenticate(password);
    final now = DateTime.now();
    for (final a in [..._all]) {
      if (a.customerId == p.uid && a.blocksSlot && a.start.isAfter(now)) {
        await _repo.setStatus(a, AppointmentStatus.cancelled);
      }
    }
    try {
      await _notifier.cancelAll();
    } catch (e) {
      debugPrint('Could not clear notifications on account deletion: $e');
    }
    await _auth.deleteAccount();
  }

  bool _signingOut = false;

  /// Guarded here rather than in the button, because signing out swaps the
  /// whole screen (button included), which would reset a widget-local flag.
  Future<void> signOut() async {
    if (_signingOut || profile == null) return;
    _signingOut = true;
    try {
      try {
        await _notifier.cancelAll();
      } catch (e) {
        // Failing to clear local notifications must never block sign-out.
        debugPrint('Could not clear notifications on sign-out: $e');
      }
      await _auth.signOut();
    } finally {
      _signingOut = false;
    }
  }

  // --- Appointments ---------------------------------------------------------

  Future<void> book(Provider provider, Service service, DateTime start, String note) =>
      _repo.book(Appointment(
        id: '',
        customerId: profile!.uid,
        customerName: profile!.name,
        providerId: provider.uid,
        providerName: provider.name,
        serviceId: service.id,
        serviceName: service.name,
        serviceMinutes: service.minutes,
        start: start,
        status: AppointmentStatus.pending,
        note: note.trim(),
      ));

  Future<void> setStatus(Appointment a, AppointmentStatus status) =>
      _repo.setStatus(a, status);

  /// Doctor only: public name, working hours, closed days, and services.
  /// The department is assigned by the admin instead.
  Future<void> saveMySettings(String name, BusinessSettings s) =>
      _providerRepo.save(profile!.uid, name.trim(), s);

  // --- Admin only -----------------------------------------------------------

  Future<String> createDepartment(String name) => _departmentRepo.create(name);
  Future<void> renameDepartment(String id, String name) =>
      _departmentRepo.rename(id, name);
  Future<void> deleteDepartment(String id) => _departmentRepo.delete(id);

  Future<void> createDoctor({
    required String name,
    required String email,
    required String password,
    required Department department,
  }) =>
      _adminRepo.createDoctor(
        name: name,
        email: email,
        password: password,
        departmentId: department.id,
        departmentName: department.name,
      );

  Future<void> setStaffRole(String uid, Role role) => _adminRepo.setRole(uid, role);

  Future<void> setDoctorDepartment(String uid, Department department) =>
      _adminRepo.setDoctorDepartment(uid, department.id, department.name);

  Future<void> renameStaff(String uid, String name) => _adminRepo.renameStaff(uid, name);

  Future<void> deleteStaff(String uid) => _adminRepo.deleteStaff(uid);

  Future<void> sendStaffPasswordReset(String email) =>
      _adminRepo.sendStaffPasswordReset(email);

  Future<void> setPatientSuspended(String uid, bool suspended) =>
      _adminRepo.setPatientSuspended(uid, suspended);

  Future<void> deletePatient(String uid) => _adminRepo.deletePatient(uid);

  @override
  void dispose() {
    _authSub?.cancel();
    _stopData();
    super.dispose();
  }
}
