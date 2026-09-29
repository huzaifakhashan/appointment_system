import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/department.dart';
import 'department_repository.dart';

class FirebaseDepartmentRepository implements DepartmentRepository {
  FirebaseDepartmentRepository([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('departments');
  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  @override
  Stream<List<Department>> watchAll() => _col.snapshots().map(
      (s) => [for (final d in s.docs) Department.fromJson(d.id, d.data())]);

  @override
  Future<String> create(String name) async =>
      (await _col.add({'name': name.trim()})).id;

  // Doctors keep a copy of their department's name (so the patient-facing
  // directory needs no extra lookups), so renaming or deleting a department
  // updates every doctor in it in the same batch.

  @override
  Future<void> rename(String id, String name) async {
    final batch = _db.batch()..update(_col.doc(id), {'name': name.trim()});
    for (final doc in await _doctorsIn(id)) {
      batch.update(doc.reference, {'departmentName': name.trim()});
    }
    await batch.commit();
  }

  @override
  Future<void> delete(String id) async {
    final batch = _db.batch()..delete(_col.doc(id));
    for (final doc in await _doctorsIn(id)) {
      batch.update(doc.reference, {
        'departmentId': FieldValue.delete(),
        'departmentName': FieldValue.delete(),
      });
    }
    await batch.commit();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _doctorsIn(String id) async =>
      (await _users.where('departmentId', isEqualTo: id).get()).docs;
}
