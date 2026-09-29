/// Who an account is. Stored in Firestore as the enum's name.
///
/// `provider` is a doctor, `customer` is a patient, and `admin` manages the
/// hospital's departments and staff. The generic names stay internal — only
/// the user-facing text says doctor/patient.
enum Role {
  customer,
  provider,
  admin;

  /// Unknown or missing values fall back to [customer], the least-privileged
  /// role, so a malformed profile can never grant extra access.
  static Role fromName(Object? raw) => Role.values.firstWhere(
        (r) => r.name == raw,
        orElse: () => Role.customer,
      );
}

/// The signed-in user.
class UserProfile {
  const UserProfile(
    this.uid,
    this.name,
    this.role, {
    this.email = '',
    this.emailVerified = true,
    this.phone = '',
  });

  final String uid;
  final String name;
  final Role role;
  final String email;
  // Defaults to true so accounts without an email on file never show a
  // spurious "please verify" nag.
  final bool emailVerified;
  // A contact number, kept as plain profile data — not used to sign in.
  final String phone;

  UserProfile copyWith({bool? emailVerified}) => UserProfile(
        uid,
        name,
        role,
        email: email,
        emailVerified: emailVerified ?? this.emailVerified,
        phone: phone,
      );
}
