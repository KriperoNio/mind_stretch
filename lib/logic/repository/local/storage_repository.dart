abstract class StorageRepository {
  Future<String?> load(String key);
  Future<void> save(String key, String value);
  Future<void> reset(String key);
  Future<void> resetAll();
}
