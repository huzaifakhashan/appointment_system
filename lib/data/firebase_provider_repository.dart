import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/business_settings.dart';
import '../models/provider.dart';
import 'provider_repository.dart';

class FirebaseProviderRepository implements ProviderRepository {
  FirebaseProviderRepository([FirebaseFirestore? db])
      : _users = (db ?? FirebaseFirestore.instance).collection('users');

  final CollectionReference<Map<String, dynamic>> _users;

  @override
  Stream<List<Provider>> watchAll() => _users
      .where('role', isEqualTo: 'provider')
      .snapshots()
      .map((s) => [for (final d in s.docs) Provider.fromJson(d.id, d.data())]);

  @override
  Stream<Provider?> watchOne(String uid) => _users.doc(uid).snapshots().map(
      (d) => d.data() == null ? null : Provider.fromJson(d.id, d.data()!));

  @override
  Future<void> save(String uid, String name, BusinessSettings settings) =>
      _users.doc(uid).set({'name': name, ...settings.toJson()}, SetOptions(merge: true));
}
