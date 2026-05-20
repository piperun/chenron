import "package:cache_manager/cache_manager.dart";
import "package:database/database.dart" hide Metadata;
import "package:database/features.dart";

/// Bridges [MetadataPersistence] to the drift [AppDatabase],
/// storing web metadata in the [WebMetadataEntries] table.
///
/// Maps between the typed [Metadata] model (cache_manager) and the
/// drift row layout. The only naming mismatch is `Metadata.imageUrl`
/// vs the `image` column.
///
/// `etag` and `contentHash` exist on [Metadata] for forward
/// compatibility but the current drift schema doesn't persist them.
/// They round-trip as `null` until the schema gains those columns.
///
/// Note: `package:database/database.dart` exports an unrelated
/// `Metadata` model (for tags / metadata records). It is hidden here so
/// the cache_manager [Metadata] is unambiguous.
class DriftMetadataPersistence implements MetadataPersistence {
  final AppDatabase _db;

  DriftMetadataPersistence(this._db);

  @override
  Future<Metadata?> get(String url) async {
    final entry = await _db.getWebMetadata(url);
    if (entry == null) return null;
    return Metadata(
      url: url,
      title: entry.title,
      description: entry.description,
      imageUrl: entry.image,
      fetchedAt: entry.fetchedAt,
      ttlDays: entry.ttlDays,
      consecutiveUnchanged: entry.consecutiveUnchanged,
    );
  }

  @override
  Future<void> set(Metadata metadata) async {
    await _db.upsertWebMetadata(
      url: metadata.url,
      title: metadata.title,
      description: metadata.description,
      image: metadata.imageUrl,
      fetchedAt: metadata.fetchedAt,
      consecutiveUnchanged: metadata.consecutiveUnchanged,
      ttlDays: metadata.ttlDays,
    );
  }

  @override
  Future<void> remove(String url) => _db.removeWebMetadata(url);

  @override
  Future<void> clearAll() => _db.clearAllWebMetadata();

  @override
  Future<int> count() => _db.countWebMetadata();

  @override
  Future<List<Metadata>> getExpiredEntries() async {
    final entries = await _db.getExpiredEntries();
    return entries
        .map((e) => Metadata(
              url: e.url,
              title: e.title,
              description: e.description,
              imageUrl: e.image,
              fetchedAt: e.fetchedAt,
              ttlDays: e.ttlDays,
              consecutiveUnchanged: e.consecutiveUnchanged,
            ))
        .toList();
  }
}
