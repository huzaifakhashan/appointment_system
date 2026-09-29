/// A hospital department (Dentistry, Ophthalmology, ...). Doctors are
/// assigned to one by the admin.
class Department {
  const Department({required this.id, required this.name});
  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'name': name};

  factory Department.fromJson(String id, Map<String, dynamic> j) =>
      Department(id: id, name: (j['name'] as String?) ?? '');
}
