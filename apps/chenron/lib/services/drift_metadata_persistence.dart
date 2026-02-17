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
    );
  }

  @override
  Future<void> remove(String url) => _db.removeWebMetadata(url);

  @override
  Future<void> clearAll() => _db.clearAllWebMetadata();

  @override
  Future<int> count() => _db.countWebMetadata();
}
