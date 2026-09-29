import '../models/department.dart';

abstract class DepartmentRepository {
  Stream<List<Department>> watchAll();

  /// Admin only. Returns the new department's id.
  Future<String> create(String name);
  Future<void> rename(String id, String name);
  Future<void> delete(String id);
}
