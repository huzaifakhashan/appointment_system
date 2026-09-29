import 'package:appointment_system/main.dart';
import 'package:appointment_system/models/business_settings.dart';
import 'package:appointment_system/models/user_profile.dart';
import 'package:appointment_system/screens/profile_screen.dart';
import 'package:appointment_system/services/notification_service.dart';
import 'package:appointment_system/state/app_scope.dart';
import 'package:appointment_system/state/app_state.dart';
import 'package:appointment_system/state/locale_controller.dart';
import 'package:appointment_system/state/locale_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

/// Builds the real app on top of in-memory fakes, so every screen can be
/// rendered and tapped through without Firebase.
void main() {
  late FakeAuth auth;
  late FakeProviders providers;
  late AppState state;
  late LocaleController locale;

  const patient = UserProfile('u1', 'Sara', Role.customer, email: 'sara@example.com');

  setUpAll(() async {
    for (final l in LocaleController.supported) {
      await initializeDateFormatting(l.languageCode);
    }
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    auth = FakeAuth();
    providers = FakeProviders();
    final departments = FakeDepartments();
    state = AppState(auth, FakeRepo(), providers, departments, FakeAdmin(providers),
        NotificationService());
    locale = LocaleController();
  });

  tearDown(() => state.dispose());

  Future<void> start(WidgetTester tester, UserProfile? user) async {
    // A typical phone (360×780 logical pixels), so layout overflows show up.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(LocaleScope(
      controller: locale,
      child: AppScope(state: state, child: const App()),
    ));
    auth.emit(user);
    await settle(tester);
  }

  testWidgets('signed out shows the sign-in form', (tester) async {
    await start(tester, null);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('New here? Create an account'), findsOneWidget);
  });

  const unverified = UserProfile('u1', 'Sara', Role.customer,
      email: 'sara@example.com', emailVerified: false);

  testWidgets('unverified patient sees the verify-email screen', (tester) async {
    await start(tester, unverified);
    expect(find.text('Verify your email'), findsOneWidget);
    // Just reopening the app doesn't send another email by itself.
    expect(auth.verificationEmailsSent, 0);
  });

  testWidgets('signing up sends exactly one verification email', (tester) async {
    // Like Firebase: the account (and so the verify screen) appears while
    // sign-up is still running.
    await start(tester, unverified);
    await tester.runAsync(() => state.signUp('Sara', 'sara@example.com', 'secret1'));
    await settle(tester);
    expect(auth.verificationEmailsSent, 1);
    expect(find.textContaining('Verification email sent to sara@example.com'), findsOneWidget);
    // The success message says where to look; the generic hint steps aside.
    expect(find.textContaining('Spam or Junk'), findsOneWidget);
    expect(find.text("Didn't get it? Check your spam folder."), findsNothing);
  });

  testWidgets('a failed verification email shows why, and stays on screen',
      (tester) async {
    auth.verificationError = StateError('quota exceeded');
    await start(tester, unverified);
    await tester.runAsync(() => state.signUp('Sara', 'sara@example.com', 'secret1'));
    await settle(tester);
    expect(find.text('Something went wrong. Please try again.'), findsWidgets);

    // Resending works once the problem is gone.
    auth.verificationError = null;
    await tester.tap(find.text('Resend verification email'));
    await settle(tester);
    expect(auth.verificationEmailsSent, 1);
    expect(find.textContaining('Verification email sent to sara@example.com'), findsOneWidget);
  });

  testWidgets('patient can browse doctors and open a booking form', (tester) async {
    providers.seed('dr1', 'Dr. Amal');
    await start(tester, patient);
    expect(find.text('Hi, Sara'), findsOneWidget);

    await tester.tap(find.text('Book'));
    await settle(tester);
    expect(find.text('Dr. Amal'), findsOneWidget);

    await tester.tap(find.text('Dr. Amal'));
    await settle(tester);
    expect(find.text('Available times'), findsOneWidget);
  });

  testWidgets('date picker opens even when the doctor is off today', (tester) async {
    final today = DateTime.now().weekday;
    providers.seed('dr1', 'Dr. Omar',
        settings: BusinessSettings.fallback.copyWith(closedWeekdays: {today}));
    await start(tester, patient);
    await tester.tap(find.text('Book'));
    await settle(tester);
    await tester.tap(find.text('Dr. Omar'));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.calendar_today));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('doctor who works no days gets a clear message', (tester) async {
    providers.seed('dr1', 'Dr. Lina',
        settings: BusinessSettings.fallback.copyWith(closedWeekdays: {1, 2, 3, 4, 5, 6, 7}));
    await start(tester, patient);
    await tester.tap(find.text('Book'));
    await settle(tester);
    await tester.tap(find.text('Dr. Lina'));
    await settle(tester);
    expect(find.text('This doctor has no working days set yet'), findsOneWidget);
  });

  testWidgets('signing out from a pushed screen, then back in, lands on home',
      (tester) async {
    await start(tester, patient);
    await tester.tap(find.byTooltip('Profile'));
    await settle(tester);
    expect(find.text('My profile'), findsWidgets);

    auth.emit(null);
    await settle(tester);
    expect(find.text('New here? Create an account'), findsOneWidget);

    auth.emit(patient);
    await settle(tester);
    expect(find.text('Hi, Sara'), findsOneWidget);
  });

  testWidgets('patient can delete their account from the profile', (tester) async {
    await start(tester, patient);
    await tester.tap(find.byTooltip('Profile'));
    await settle(tester);
    expect(find.text('Change email'), findsNothing);

    final deleteButton = find.widgetWithText(OutlinedButton, 'Delete account');
    await tester.scrollUntilVisible(deleteButton, 200,
        scrollable: find
            .descendant(of: find.byType(ProfileScreen), matching: find.byType(Scrollable))
            .first);
    await tester.ensureVisible(deleteButton);
    await settle(tester);
    await tester.tap(deleteButton);
    await settle(tester);
    expect(find.text('Delete your account?'), findsOneWidget);

    // Wrong password: stays in the dialog with a message.
    await tester.enterText(find.byType(TextFormField).last, 'nope');
    await tester.tap(find.text('Delete permanently'));
    await settle(tester);
    expect(auth.accountDeleted, isFalse);
    expect(find.text('Incorrect password'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, 'secret1');
    await tester.tap(find.text('Delete permanently'));
    await settle(tester);
    expect(auth.accountDeleted, isTrue);
    expect(find.text('New here? Create an account'), findsOneWidget);
    expect(find.text('Your account has been deleted'), findsOneWidget);
  });

  for (final role in [Role.provider, Role.admin]) {
    testWidgets('${role.name} with an unverified email is never asked to verify',
        (tester) async {
      providers.seed('s1', 'Dr. Amal');
      await start(tester,
          UserProfile('s1', 'Staff', role, email: 'staff@example.com', emailVerified: false));
      expect(find.text('Verify your email'), findsNothing);

      await tester.tap(find.byTooltip('Profile'));
      await settle(tester);
      expect(find.textContaining('staff@example.com'), findsOneWidget);
      expect(find.text('Not verified'), findsNothing);
      expect(find.text('Resend verification email'), findsNothing);
    });
  }

  testWidgets('doctors get no delete-account option', (tester) async {
    providers.seed('dr1', 'Dr. Amal');
    await start(tester, const UserProfile('dr1', 'Dr. Amal', Role.provider));
    await tester.tap(find.byTooltip('Profile'));
    await settle(tester);
    expect(find.text('Delete account'), findsNothing);
  });

  testWidgets('doctor home shows requests and calendar', (tester) async {
    providers.seed('dr1', 'Dr. Amal');
    await start(tester, const UserProfile('dr1', 'Dr. Amal', Role.provider));
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('No pending requests'), findsOneWidget);

    await tester.tap(find.text('Calendar'));
    await settle(tester);
    expect(find.text('Nothing scheduled on this day'), findsOneWidget);

    await tester.tap(find.byTooltip('Schedule & services'));
    await settle(tester);
    expect(find.text('Working hours'), findsOneWidget);
  });

  testWidgets('admin home shows its three tabs', (tester) async {
    await start(tester, const UserProfile('a1', 'Admin', Role.admin));
    expect(find.text('Departments'), findsOneWidget);
    expect(find.text('Staff'), findsOneWidget);
    expect(find.text('Patients'), findsOneWidget);
    expect(find.text('No departments yet'), findsOneWidget);
  });

  testWidgets('switching to Arabic lays the app out right-to-left', (tester) async {
    await start(tester, patient);
    await locale.setLocale(const Locale('ar'));
    await settle(tester);
    expect(find.text('أهلاً، Sara'), findsOneWidget);
    final context = tester.element(find.byType(Scaffold).first);
    expect(Directionality.of(context), TextDirection.rtl);
  });
}

/// Like pumpAndSettle, but tolerates spinners that animate forever.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(pump);
    await tester.pump(const Duration(milliseconds: 100));
  }
}
