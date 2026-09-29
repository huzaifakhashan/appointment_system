import '../models/business_settings.dart';
import '../models/provider.dart';

abstract class ProviderRepository {
  /// The directory of every provider a customer can book with.
  Stream<List<Provider>> watchAll();

  /// One provider's own profile, for their settings screen and app bar.
  Stream<Provider?> watchOne(String uid);

  /// Provider only: saves their business name and settings.
  Future<void> save(String uid, String name, BusinessSettings settings);
}
