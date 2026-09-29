import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../utils/switch_map.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _users = (db ?? FirebaseFirestore.instance).collection('users');

  final FirebaseAuth _auth;
  final CollectionReference<Map<String, dynamic>> _users;

  User get _user => _auth.currentUser!;

  @override
  Stream<UserProfile?> watchProfile() => _auth.authStateChanges().switchMap((u) {
        if (u == null) return Stream.value(null);
        return _users.doc(u.uid).snapshots().map((d) {
          final data = d.data() ?? const <String, dynamic>{};
          return UserProfile(
            u.uid,
            (data['name'] as String?) ?? u.displayName ?? u.email ?? '',
            Role.fromName(data['role']),
            email: u.email ?? '',
            emailVerified: u.emailVerified,
            phone: (data['phone'] as String?) ?? '',
          );
        });
      });

  @override
  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  @override
  Future<void> signUp(String name, String email, String password) async {
    // Only this step can fail in a way the user must fix (email taken, weak
    // password...), so only its errors reach the sign-up form.
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    final user = cred.user!;
    // The account now exists and the app has already moved on to the verify
    // screen, so a failure here is logged rather than thrown into a form
    // that's no longer on screen. The profile falls back to Auth's data.
    try {
      await user.updateDisplayName(name.trim());
      await _users.doc(user.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': Role.customer.name,
      });
    } catch (e) {
      debugPrint('Could not save the new profile: $e');
    }
    // The verification email is sent by the verify screen (see
    // AppState.takeVerificationEmailDue), where its result can be shown.
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  @override
  Future<void> updateDisplayName(String name) async {
    await _user.updateDisplayName(name.trim());
    await _users.doc(_user.uid).update({'name': name.trim()});
  }

  @override
  Future<void> updatePhone(String phone) =>
      _users.doc(_user.uid).update({'phone': phone.trim()});

  @override
  Future<void> sendEmailVerification() => _user.sendEmailVerification();

  @override
  Future<void> setEmailLanguage(String languageCode) => _auth.setLanguageCode(languageCode);

  @override
  Future<bool> reloadAndCheckVerified() async {
    await _auth.currentUser?.reload();
    // reload() only updates the cached User. Firestore's security rules read
    // `email_verified` off the ID token, so force a token refresh too — that
    // lets a freshly verified account book right away.
    await _auth.currentUser?.getIdToken(true);
    return _auth.currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> reauthenticate(String password) => _user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: _user.email!, password: password));

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await reauthenticate(currentPassword);
    await _user.updatePassword(newPassword);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _user;
    // The profile first, while still signed in (the rules need that); then
    // the login itself, which signs the user out.
    await _users.doc(user.uid).delete();
    await user.delete();
  }
}
