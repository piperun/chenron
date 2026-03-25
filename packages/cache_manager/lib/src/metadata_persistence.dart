/// Abstract interface for persistent metadata storage.
///
/// Implementations bridge the cache to a specific storage backend
/// (e.g. drift/SQLite). The cache_manager package depends only on
/// this interface, not on any concrete database.
abstract class MetadataPersistence {
  Future<Map<String, dynamic>?> get(String url);
  Future<void> set(String url, Map<String, dynamic> metadata);
  Future<void> remove(String url);
  Future<void> clearAll();
  Future<int> count();

  /// Return all entries whose per-entry TTL has expired.
  /// Each map includes: url, title, description, image, fetchedAt,
  /// consecutiveUnchanged, ttlDays.
  Future<List<Map<String, dynamic>>> getExpiredEntries();
}
