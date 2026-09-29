import 'user_profile.dart';

/// Any account, as listed on the admin's staff/patients screens.
class ManagedUser {
  const ManagedUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.departmentId,
    this.departmentName,
    this.suspended = false,
  });

  final String uid;
  final String name;
  final String email;
  final Role role;
  final String phone;
  final String? departmentId;
  final String? departmentName;
  /// Patients only: blocked from booking new appointments by the admin.
  final bool suspended;

  /// The name, or the email for an account that never set one.
  String get displayName => name.isEmpty ? email : name;

  ManagedUser copyWith({
    String? name,
    Role? role,
    String? departmentId,
    String? departmentName,
    bool? suspended,
  }) =>
      ManagedUser(
        uid: uid,
        name: name ?? this.name,
        email: email,
        role: role ?? this.role,
        phone: phone,
        departmentId: departmentId ?? this.departmentId,
        departmentName: departmentName ?? this.departmentName,
        suspended: suspended ?? this.suspended,
      );

  factory ManagedUser.fromJson(String uid, Map<String, dynamic> j) => ManagedUser(
        uid: uid,
        name: (j['name'] as String?) ?? '',
        email: (j['email'] as String?) ?? '',
        phone: (j['phone'] as String?) ?? '',
        role: Role.fromName(j['role']),
        departmentId: j['departmentId'] as String?,
        departmentName: j['departmentName'] as String?,
        suspended: j['suspended'] == true,
      );
}
