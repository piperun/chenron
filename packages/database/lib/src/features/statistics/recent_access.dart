import "package:database/main.dart";
import "package:drift/drift.dart";

extension RecentAccessTracking on AppDatabase {
  /// Records an item access — upserts: inserts or updates lastAccessedAt + increments accessCount
  Future<void> recordItemAccess({
    required String entityId,
    required String entityType,
  }) async {
    await customStatement(
      "INSERT INTO recent_access (entity_id, entity_type, last_accessed_at, access_count) "
      "VALUES (?, ?, ?, 1) "
      "ON CONFLICT(entity_id, entity_type) DO UPDATE SET "
      "last_accessed_at = excluded.last_accessed_at, "
      "access_count = access_count + 1",
      [
        entityId,
        entityType,
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ],
    );
  }

  /// Gets the most recently accessed items
  Future<List<RecentAccessData>> getRecentlyViewed({
    int limit = 10,
    String? entityType,
  }) async {
    final query = select(recentAccess)
      ..orderBy([(t) => OrderingTerm.desc(t.lastAccessedAt)])
      ..limit(limit);

    if (entityType != null) {
      query.where((t) => t.entityType.equals(entityType));
    }

    return query.get();
  }

  /// Gets the most frequently accessed items
  Future<List<RecentAccessData>> getMostAccessed({
    int limit = 10,
    String? entityType,
  }) async {
    final query = select(recentAccess)
      ..orderBy([(t) => OrderingTerm.desc(t.accessCount)])
      ..limit(limit);

    if (entityType != null) {
      query.where((t) => t.entityType.equals(entityType));
    }

    return query.get();
  }
}
