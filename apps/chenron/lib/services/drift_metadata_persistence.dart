import "package:cache_manager/cache_manager.dart";
import "package:database/database.dart";

/// Bridges [MetadataPersistence] to the drift [AppDatabase],
/// storing web metadata in the [WebMetadataEntries] table.
class DriftMetadataPersistence implements MetadataPersistence {
  final AppDatabase _db;

  DriftMetadataPersistence(this._db);

  @override
  Future<Map<String, dynamic>?> get(String url) async {
    final entry = await _db.getWebMetadata(url);
    if (entry == null) return null;
    return {
      "title": entry.title,
      "description": entry.description,
      "image": entry.image,
      "url": url,
      "fetchedAt": entry.fetchedAt.toIso8601String(),
      "consecutiveUnchanged": entry.consecutiveUnchanged,
      "ttlDays": entry.ttlDays,
    };
  }

  @override
  Future<void> set(String url, Map<String, dynamic> metadata) async {
    await _db.upsertWebMetadata(
      url: url,
      title: metadata["title"] as String?,
      description: metadata["description"] as String?,
      image: metadata["image"] as String?,
      fetchedAt: DateTime.now(),
      consecutiveUnchanged: (metadata["consecutiveUnchanged"] as int?) ?? 0,
      ttlDays: (metadata["ttlDays"] as int?) ?? 7,
    );
  }

  @override
  Future<void> remove(String url) => _db.removeWebMetadata(url);

  @override
  Future<void> clearAll() => _db.clearAllWebMetadata();

  @override
  Future<int> count() => _db.countWebMetadata();

  @override
  Future<List<Map<String, dynamic>>> getExpiredEntries() async {
    final entries = await _db.getExpiredEntries();
    return entries
        .map((e) => {
              "url": e.url,
              "title": e.title,
              "description": e.description,
              "image": e.image,
              "fetchedAt": e.fetchedAt.toIso8601String(),
              "consecutiveUnchanged": e.consecutiveUnchanged,
              "ttlDays": e.ttlDays,
            })
        .toList();
  }
}
