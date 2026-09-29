import 'business_settings.dart';

/// A bookable doctor/business. Backed by a `users/{uid}` document whose role
/// is `provider`.
class Provider {
  const Provider({
    required this.uid,
    required this.name,
    required this.settings,
    this.departmentId,
    this.departmentName,
  });

  final String uid;
  final String name;
  final BusinessSettings settings;
  /// Assigned by the admin; null for a doctor not yet placed in a department.
  final String? departmentId;
  final String? departmentName;

  factory Provider.fromJson(String uid, Map<String, dynamic> j) => Provider(
        uid: uid,
        name: (j['name'] as String?) ?? '',
        settings: BusinessSettings.fromJson(j),
        departmentId: j['departmentId'] as String?,
        departmentName: j['departmentName'] as String?,
      );
}
