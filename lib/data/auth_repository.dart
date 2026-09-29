import '../models/user_profile.dart';

/// Sign-in, sign-up, and the signed-in user's own account settings.
/// [FirebaseAuthRepository] is the real implementation; tests use a fake.
abstract class AuthRepository {
  /// The signed-in user's profile, or null when signed out.
  Stream<UserProfile?> watchProfile();

  Future<void> signIn(String email, String password);

  /// Creates a patient account. Doesn't send the verification email — the
  /// app does that from the verify screen, where the outcome can be shown.
  Future<void> signUp(String name, String email, String password);

  Future<void> signOut();
  Future<void> sendPasswordReset(String email);

  /// Updates the signed-in user's display name, in Auth and in Firestore.
  Future<void> updateDisplayName(String name);

  /// Updates the signed-in user's contact phone number (plain profile data).
  Future<void> updatePhone(String phone);

  Future<void> sendEmailVerification();

  /// The language Firebase writes its emails in (verification, password
  /// reset, email change), e.g. `ar` or `en`.
  Future<void> setEmailLanguage(String languageCode);

  /// Re-checks verification status with the server (it isn't pushed live).
  Future<bool> reloadAndCheckVerified();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Confirms the signed-in user's password. Firebase requires a recent
  /// sign-in before sensitive changes; this also catches a wrong password
  /// before anything irreversible happens.
  Future<void> reauthenticate(String password);

  /// Deletes the signed-in user's profile and login for good. Call
  /// [reauthenticate] first.
  Future<void> deleteAccount();
}
