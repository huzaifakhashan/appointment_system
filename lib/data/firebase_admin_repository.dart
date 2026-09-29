import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/business_settings.dart';
import '../models/managed_user.dart';
import '../models/user_profile.dart';
import 'admin_repository.dart';

class FirebaseAdminRepository implements AdminRepository {
  FirebaseAdminRepository([FirebaseFirestore? db])
      : _users = (db ?? FirebaseFirestore.instance).collection('users');

  final CollectionReference<Map<String, dynamic>> _users;

  List<ManagedUser> _parse(QuerySnapshot<Map<String, dynamic>> s) =>
      [for (final d in s.docs) ManagedUser.fromJson(d.id, d.data())];

  @override
  Stream<List<ManagedUser>> watchStaff() => _users
      .where('role', whereIn: [Role.provider.name, Role.admin.name])
      .snapshots()
      .map(_parse);

  @override
  Stream<List<ManagedUser>> watchPatients() =>
      _users.where('role', isEqualTo: Role.customer.name).snapshots().map(_parse);

  @override
  Future<void> createDoctor({
    required String name,
    required String email,
    required String password,
    required String departmentId,
    required String departmentName,
  }) async {
    // A second, throwaway Firebase app lets us create the account without
    // signing the admin out of their own session.
    final secondaryApp = await Firebase.initializeApp(
      name: 'doctor_creator_${DateTime.now().microsecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    try {
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user!.updateDisplayName(name.trim());
      await secondaryAuth.signOut();
      await _users.doc(cred.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': Role.provider.name,
        'departmentId': departmentId,
        'departmentName': departmentName,
        ...BusinessSettings.fallback.toJson(),
      });
    } finally {
      await secondaryApp.delete();
    }
  }

  @override
  Future<void> setRole(String uid, Role role) =>
      _users.doc(uid).update({'role': role.name});

  @override
  Future<void> setDoctorDepartment(String uid, String departmentId, String departmentName) =>
      _users.doc(uid).update({
        'departmentId': departmentId,
        'departmentName': departmentName,
      });

  @override
  Future<void> renameStaff(String uid, String name) =>
      _users.doc(uid).update({'name': name.trim()});

  @override
  Future<void> deleteStaff(String uid) => _users.doc(uid).delete();

  @override
  Future<void> sendStaffPasswordReset(String email) =>
      FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

  @override
  Future<void> setPatientSuspended(String uid, bool suspended) =>
      _users.doc(uid).update({'suspended': suspended});

  @override
  Future<void> deletePatient(String uid) => _users.doc(uid).delete();
}
