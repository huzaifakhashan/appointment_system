// Generates the README screenshots from the real app, running on in-memory
// demo data — no Firebase needed, and nothing real is read or written.
//
//   flutter test tool/screenshots --update-goldens
//
// Images are written to docs/screenshots/{ar,en}/. Needs a font with Arabic
// glyphs (Segoe UI, found on Windows) and Flutter's Material icon font.

import 'dart:io';

import 'package:appointment_system/main.dart';
import 'package:appointment_system/models/appointment.dart';
import 'package:appointment_system/models/business_settings.dart';
import 'package:appointment_system/models/managed_user.dart';
import 'package:appointment_system/models/user_profile.dart';
import 'package:appointment_system/services/notification_service.dart';
import 'package:appointment_system/state/app_scope.dart';
import 'package:appointment_system/state/app_state.dart';
import 'package:appointment_system/state/locale_controller.dart';
import 'package:appointment_system/state/locale_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/fakes.dart';

void main() {
  setUpAll(() async {
    for (final l in LocaleController.supported) {
      await initializeDateFormatting(l.languageCode);
    }
    final flutterRoot = Platform.environment['FLUTTER_ROOT'] ??
        File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
    // The Material theme asks for "Roboto"; Segoe UI stands in because it
    // also covers Arabic.
    await _loadFont('Roboto', [
      'C:/Windows/Fonts/segoeui.ttf',
      'C:/Windows/Fonts/seguisb.ttf',
      'C:/Windows/Fonts/segoeuib.ttf',
    ]);
    await _loadFont('MaterialIcons',
        ['$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf']);
  });

  for (final lang in ['ar', 'en']) {
    group(lang, () {
      late _Demo demo;

      Future<void> start(WidgetTester tester, UserProfile? user) async {
        // ignore: invalid_use_of_visible_for_testing_member
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = const Size(390 * 2.5, 844 * 2.5);
        tester.view.devicePixelRatio = 2.5;
        addTearDown(tester.view.reset);
        demo = _Demo(lang);
        final locale = LocaleController();
        await locale.setLocale(Locale(lang));
        await tester.pumpWidget(LocaleScope(
          controller: locale,
          child: AppScope(state: demo.state, child: const App()),
        ));
        demo.auth.emit(user);
        await _settle(tester);
      }

      Future<void> shot(String name) => expectLater(
          find.byType(App), matchesGoldenFile('../../docs/screenshots/$lang/$name.png'));

      Future<void> tap(WidgetTester tester, Finder f) async {
        await tester.tap(f.first);
        await _settle(tester);
      }

      _screenshot('login', (tester) async {
        await start(tester, null);
        await shot('01_login');
      });

      _screenshot('patient', (tester) async {
        await start(tester, _Demo.patientProfile(lang));
        await shot('02_patient_home');

        await tap(tester, find.byType(FloatingActionButton));
        await shot('03_choose_doctor');

        await tap(tester, find.text(demo.tr('Dr. Layla Haddad', 'د. ليلى حداد')));
        await tap(tester, find.byType(ChoiceChip).at(2));
        await shot('04_booking');
      });

      _screenshot('verify email', (tester) async {
        final p = _Demo.patientProfile(lang);
        await start(tester,
            UserProfile(p.uid, p.name, p.role, email: p.email, emailVerified: false));
        await tester.runAsync(() => demo.state.signUp(p.name, p.email, 'secret1'));
        await _settle(tester);
        await shot('12_verify_email');
      });

      _screenshot('patient profile', (tester) async {
        await start(tester, _Demo.patientProfile(lang));
        await tap(tester, find.byIcon(Icons.account_circle));
        await shot('11_profile');

        final delete = find.byIcon(Icons.delete_outline);
        await tester.scrollUntilVisible(delete, 300,
            scrollable: find.byType(Scrollable).last);
        await tester.ensureVisible(delete);
        await _settle(tester);
        await tap(tester, delete);
        await shot('13_delete_account');
      });

      _screenshot('doctor', (tester) async {
        await start(tester, _Demo.doctorProfile(lang));
        await shot('05_doctor_requests');

        await tap(tester, find.byIcon(Icons.calendar_month));
        await shot('06_doctor_calendar');

        await tap(tester, find.byIcon(Icons.settings));
        await shot('07_doctor_settings');
      });

      _screenshot('admin', (tester) async {
        await start(tester, _Demo.adminProfile(lang));
        await shot('08_admin_departments');

        await tap(tester, find.byIcon(Icons.groups));
        await shot('09_admin_staff');

        await tap(tester, find.byIcon(Icons.people));
        await shot('10_admin_patients');
      });
    });
  }
}

/// A test that draws real shadows (tests normally switch them off).
void _screenshot(String description, WidgetTesterCallback body) {
  testWidgets(description, (tester) async {
    debugDisableShadows = false;
    try {
      await body(tester);
    } finally {
      debugDisableShadows = true;
    }
  });
}

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) throw StateError('Font not found: $path');
    loader.addFont(file.readAsBytes().then((b) => ByteData.sublistView(b)));
  }
  await loader.load();
}

/// Like pumpAndSettle, but tolerates spinners that animate forever.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(pump);
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// A small, believable hospital: 5 departments, 5 doctors, a few patients,
/// and appointments in every state — in English or Arabic.
class _Demo {
  _Demo(this.lang) {
    providers = FakeProviders();
    admin = FakeAdmin(providers);
    state = AppState(auth, repo, providers, departments, admin, NotificationService());
    _seed();
  }

  final String lang;
  final auth = FakeAuth();
  final repo = FakeRepo();
  final departments = FakeDepartments();
  late final FakeProviders providers;
  late final FakeAdmin admin;
  late final AppState state;

  String tr(String en, String ar) => lang == 'ar' ? ar : en;
  static String _tr(String lang, String en, String ar) => lang == 'ar' ? ar : en;

  static UserProfile patientProfile(String lang) => UserProfile(
      'p_ahmad', _tr(lang, 'Ahmad Ali', 'أحمد علي'), Role.customer,
      email: 'ahmad.ali@example.com', phone: '+964 770 123 4567');
  static UserProfile doctorProfile(String lang) =>
      UserProfile('dr_omar', _tr(lang, 'Dr. Omar Al-Khatib', 'د. عمر الخطيب'), Role.provider,
          email: 'omar@hospital.example');
  static UserProfile adminProfile(String lang) => UserProfile(
      'a_huda', _tr(lang, 'Huda Salim', 'هدى سليم'), Role.admin,
      email: 'huda@hospital.example');

  void _seed() {
    // Departments.
    final depts = {
      'dent': tr('Dentistry', 'طب الأسنان'),
      'eye': tr('Ophthalmology', 'طب العيون'),
      'peds': tr('Pediatrics', 'طب الأطفال'),
      'card': tr('Cardiology', 'أمراض القلب'),
      'derm': tr('Dermatology', 'الأمراض الجلدية'),
    };
    for (final name in depts.values) {
      departments.create(name);
    }
    // FakeDepartments numbers its ids d0, d1, ... in creation order.
    final deptId = {for (final (i, key) in depts.keys.indexed) key: 'd$i'};

    // Doctors.
    final today = DateTime.now().weekday;
    final doctors = [
      (
        'dr_layla',
        tr('Dr. Layla Haddad', 'د. ليلى حداد'),
        'dent',
        BusinessSettings.fallback.copyWith(
          // Off today too, so the booking screenshot opens on a full day.
          closedWeekdays: {DateTime.friday, today},
          services: [
            BusinessSettings.fallback.services.first,
            Service('cleaning', tr('Teeth cleaning', 'تنظيف الأسنان'), 60),
            BusinessSettings.fallback.services.last,
          ],
        ),
      ),
      (
        'dr_omar',
        tr('Dr. Omar Al-Khatib', 'د. عمر الخطيب'),
        'eye',
        BusinessSettings.fallback.copyWith(
            openHour: 9, closeHour: 16, closedWeekdays: {DateTime.friday, DateTime.saturday}),
      ),
      ('dr_sara', tr('Dr. Sara Youssef', 'د. سارة يوسف'), 'peds', BusinessSettings.fallback),
      ('dr_karim', tr('Dr. Karim Mansour', 'د. كريم منصور'), 'card', BusinessSettings.fallback),
      ('dr_rana', tr('Dr. Rana Abdullah', 'د. رنا عبد الله'), 'derm', BusinessSettings.fallback),
    ];
    for (final (uid, name, dept, settings) in doctors) {
      providers.seed(uid, name,
          settings: settings, departmentId: deptId[dept], departmentName: depts[dept]);
      admin.seedStaff(ManagedUser(
        uid: uid,
        name: name,
        email: '${uid.substring(3)}@hospital.example',
        role: Role.provider,
        departmentId: deptId[dept],
        departmentName: depts[dept],
      ));
    }
    final huda = adminProfile(lang);
    admin.seedStaff(ManagedUser(
        uid: huda.uid, name: huda.name, email: huda.email, role: Role.admin));

    // Patients.
    final ahmad = patientProfile(lang);
    final patients = [
      (ahmad.uid, ahmad.name, ahmad.email, ahmad.phone, false),
      ('p_maryam', tr('Maryam Hassan', 'مريم حسن'), 'maryam.h@example.com', '+964 750 222 1100', false),
      ('p_yousef', tr('Yousef Ibrahim', 'يوسف إبراهيم'), 'yousef.i@example.com', '', false),
      ('p_ali', tr('Ali Kadhim', 'علي كاظم'), 'ali.k@example.com', '+964 780 555 0199', false),
      ('p_nour', tr('Nour Khaled', 'نور خالد'), 'nour.k@example.com', '', true),
    ];
    for (final (uid, name, email, phone, suspended) in patients) {
      admin.seedPatient(uid, name, email: email, phone: phone, suspended: suspended);
    }
    String patientName(String uid) => patients.firstWhere((p) => p.$1 == uid).$2;
    String doctorName(String uid) => doctors.firstWhere((d) => d.$1 == uid).$2;

    // Appointments, relative to today.
    final now = DateTime.now();
    DateTime at(int dayOffset, int hour, [int minute = 0]) =>
        DateTime(now.year, now.month, now.day + dayOffset, hour, minute);
    var nextId = 0;
    void book(String patient, String doctor, String serviceId, DateTime start,
        AppointmentStatus status, [String note = '']) {
      final s = doctors
          .firstWhere((d) => d.$1 == doctor)
          .$4
          .services
          .firstWhere((s) => s.id == serviceId);
      repo.seed(Appointment(
        id: 'a${nextId++}',
        customerId: patient,
        customerName: patientName(patient),
        providerId: doctor,
        providerName: doctorName(doctor),
        serviceId: s.id,
        serviceName: s.name,
        serviceMinutes: s.minutes,
        start: start,
        status: status,
        note: note,
      ));
    }

    const confirmed = AppointmentStatus.confirmed;
    const pending = AppointmentStatus.pending;
    // Ahmad (the patient in the screenshots).
    book('p_ahmad', 'dr_omar', 'consult', at(1, 10), confirmed,
        tr('Blurry vision in the left eye', 'تشوّش في الرؤية بالعين اليسرى'));
    book('p_ahmad', 'dr_layla', 'cleaning', at(3, 12, 30), pending);
    book('p_ahmad', 'dr_karim', 'checkup', at(-12, 9), confirmed);
    book('p_ahmad', 'dr_layla', 'followup', at(-25, 11), AppointmentStatus.cancelled);
    // Dr. Omar (the doctor in the screenshots): today's schedule + requests.
    book('p_ali', 'dr_omar', 'checkup', at(0, 9), confirmed);
    book('p_maryam', 'dr_omar', 'followup', at(0, 11, 30), confirmed);
    book('p_yousef', 'dr_omar', 'consult', at(0, 13), confirmed,
        tr('First visit', 'الزيارة الأولى'));
    book('p_maryam', 'dr_omar', 'consult', at(1, 11, 30), pending,
        tr('Itchy, red eyes for a week', 'احمرار وحكة في العينين منذ أسبوع'));
    book('p_yousef', 'dr_omar', 'checkup', at(2, 9), pending);
    book('p_ali', 'dr_omar', 'followup', at(4, 14), pending);
  }
}
