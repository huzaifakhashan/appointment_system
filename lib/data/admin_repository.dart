import '../models/managed_user.dart';
import '../models/user_profile.dart';

abstract class AdminRepository {
  /// Every doctor and admin account.
  Stream<List<ManagedUser>> watchStaff();

  /// Every patient account.
  Stream<List<ManagedUser>> watchPatients();

  /// Creates a doctor account with the given password, set by the admin.
  /// Does not touch the admin's own signed-in session.
  Future<void> createDoctor({
    required String name,
    required String email,
    required String password,
    required String departmentId,
    required String departmentName,
  });

  Future<void> setRole(String uid, Role role);
  Future<void> setDoctorDepartment(String uid, String departmentId, String departmentName);
  Future<void> renameStaff(String uid, String name);

  /// Removes the staff member's profile (see the rules file for what this
  /// does and does not do to their ability to sign in).
  Future<void> deleteStaff(String uid);

  /// Sends a password reset link to a staff member's email — the only way
  /// an admin can put a new password on someone else's account without a
  /// paid backend (they can't set one directly).
  Future<void> sendStaffPasswordReset(String email);

  /// Blocks (or unblocks) a patient from booking new appointments. Doesn't
  /// touch what they've already booked or their ability to sign in.
  Future<void> setPatientSuspended(String uid, bool suspended);

  /// Removes the patient's profile (see the rules file for what this does
  /// and does not do to their ability to sign in).
  Future<void> deletePatient(String uid);
}
