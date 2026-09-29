import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/firebase_admin_repository.dart';
import 'data/firebase_appointment_repository.dart';
import 'data/firebase_auth_repository.dart';
import 'data/firebase_department_repository.dart';
import 'data/firebase_provider_repository.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'models/user_profile.dart';
import 'screens/admin_home.dart';
import 'screens/auth_screen.dart';
import 'screens/customer_home.dart';
import 'screens/provider_home.dart';
import 'screens/verify_email_screen.dart';
import 'services/notification_service.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'state/locale_controller.dart';
import 'state/locale_scope.dart';
import 'widgets/double_back_to_exit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  for (final locale in LocaleController.supported) {
    await initializeDateFormatting(locale.languageCode);
  }
  final notifier = NotificationService();
  await notifier.init();
  final locale = LocaleController();
  await locale.load();
  final state = AppState(
    FirebaseAuthRepository(),
    FirebaseAppointmentRepository(),
    FirebaseProviderRepository(),
    FirebaseDepartmentRepository(),
    FirebaseAdminRepository(),
    notifier,
  );
  runApp(LocaleScope(
    controller: locale,
    child: AppScope(state: state, child: const App()),
  ));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  AppState? _appState;
  String? _lastUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = AppScope.of(context);
    if (!identical(_appState, appState)) {
      _appState?.removeListener(_onAppStateChanged);
      _appState = appState..addListener(_onAppStateChanged);
      _lastUid = appState.profile?.uid;
    }
  }

  // The home screen below is picked reactively from the signed-in user, but
  // screens pushed on top of it (profile, settings, dialogs...) would stay.
  // So whenever the user changes, pop back to that root screen.
  void _onAppStateChanged() {
    final uid = _appState?.profile?.uid;
    if (uid != _lastUid) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    _lastUid = uid;
  }

  @override
  void dispose() {
    _appState?.removeListener(_onAppStateChanged);
    super.dispose();
  }

  Widget _home(AppState state) {
    final profile = state.profile;
    if (state.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return switch (profile?.role) {
      null => const AuthScreen(),
      // Doctor/admin accounts are created by an admin, so only a patient's
      // self-registered address needs to be proven real.
      Role.customer when !profile!.emailVerified => const VerifyEmailScreen(),
      Role.customer => const CustomerHome(),
      Role.provider => const ProviderHome(),
      Role.admin => const AdminHome(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final locale = LocaleScope.of(context);
    return MaterialApp(
      navigatorKey: _navigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale.locale,
      supportedLocales: LocaleController.supported,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: DoubleBackToExit(child: _home(state)),
      // Keeps notifications and Firebase's emails in the language Flutter resolved
      // (the user's choice, or the device's, limited to what we ship).
      builder: (context, child) {
        state.setLocale(Localizations.localeOf(context));
        return child!;
      },
    );
  }
}

ThemeData _theme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: Colors.teal, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    cardTheme: const CardThemeData(margin: EdgeInsets.symmetric(vertical: 6)),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
