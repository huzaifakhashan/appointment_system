import 'package:firebase_core/firebase_core.dart';

import '../l10n/app_localizations.dart';

/// A user-facing message for any error thrown by Firebase (or anything else).
/// `FirebaseAuthException` is a `FirebaseException`, so this covers both.
///
/// [passwordOnly] is for forms where the user typed just their current
/// password (already signed in), so "wrong email or password" would confuse.
String errorMessage(AppLocalizations t, Object error, {bool passwordOnly = false}) {
  if (error is! FirebaseException) return t.authErrorGeneric;
  return switch (error.code) {
    'invalid-credential' || 'wrong-password' when passwordOnly =>
      t.authErrorWrongCurrentPassword,
    'invalid-credential' || 'wrong-password' || 'user-not-found' => t.authErrorWrongPassword,
    'email-already-in-use' => t.authErrorEmailInUse,
    'weak-password' => t.authErrorWeakPassword,
    'invalid-email' => t.authErrorInvalidEmail,
    'network-request-failed' || 'unavailable' => t.authErrorNetwork,
    'too-many-requests' => t.authErrorTooManyRequests,
    'requires-recent-login' => t.authErrorRequiresRecentLogin,
    'permission-denied' => t.permissionDenied,
    _ => t.authErrorGeneric,
  };
}
