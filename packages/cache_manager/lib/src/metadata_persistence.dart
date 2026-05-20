import "package:cache_manager/src/metadata.dart";

/// Abstract interface for persistent metadata storage.
///
/// Implementations bridge the cache to a specific storage backend
/// (e.g. drift/SQLite). The cache_manager package depends only on
/// this interface, not on any concrete database.
abstract class MetadataPersistence {
  Future<Metadata?> get(String url);
  Future<void> set(Metadata metadata);
  Future<void> remove(String url);
  Future<void> clearAll();
  Future<int> count();

  /// Return all entries whose per-entry TTL has expired.
  Future<List<Metadata>> getExpiredEntries();
}
