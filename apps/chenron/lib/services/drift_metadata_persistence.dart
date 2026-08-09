import "package:cache_manager/cache_manager.dart";
import "package:database/database.dart" hide Metadata;
import "package:database/features.dart";

/// Bridges metadata snapshots and refresh retry state to the v20 Drift schema.
class DriftMetadataPersistence
    implements MetadataPersistence, MetadataRefreshPersistence {
  final AppDatabase _db;

  DriftMetadataPersistence(this._db);

  @override
  Future<Metadata?> get(String url) async {
    final entry = await _db.getWebMetadata(url);
    return entry == null ? null : _metadataFromEntry(entry);
  }

  @override
  Future<void> set(Metadata metadata) async {
    await _db.upsertWebMetadata(
      url: metadata.url,
      title: metadata.title,
      description: metadata.description,
      image: metadata.imageUrl,
      resolvedUrl: metadata.resolvedUrl,
      etag: metadata.etag,
      lastModified: metadata.lastModified,
      contentHash: metadata.contentHash,
      fetchedAt: metadata.fetchedAt,
      consecutiveUnchanged: metadata.consecutiveUnchanged,
      ttlDays: metadata.ttlDays,
    );
  }

  @override
  Future<void> remove(String url) => _db.removeWebMetadata(url);

  @override
  Future<void> clearAll() => _db.transaction(() async {
        await _db.clearAllWebMetadata();
        await _db.clearAllWebMetadataRefresh();
      });

  @override
  Future<int> count() => _db.countWebMetadata();

  @override
  Future<List<Metadata>> getExpiredEntries() async {
    final entries = await _db.getExpiredEntries();
    return entries.map(_metadataFromEntry).toList(growable: false);
  }

  @override
  Future<MetadataRefreshRecord?> getRefreshRecord(String url) async {
    final entry = await _db.getWebMetadataRefresh(url);
    if (entry == null) return null;
    return MetadataRefreshRecord(
      url: entry.url,
      lastAttemptAt: entry.lastAttemptAt,
      lastFailureKind: entry.lastFailureKind == null
          ? null
          : MetadataFailureKind.values.byName(entry.lastFailureKind!),
      lastStatusCode: entry.lastStatusCode,
      consecutiveFailures: entry.consecutiveFailures,
      nextRetryAt: entry.nextRetryAt,
    );
  }

  @override
  Future<void> setRefreshRecord(MetadataRefreshRecord record) {
    return _db.upsertWebMetadataRefresh(
      url: record.url,
      lastAttemptAt: record.lastAttemptAt,
      lastFailureKind: record.lastFailureKind?.name,
      lastStatusCode: record.lastStatusCode,
      consecutiveFailures: record.consecutiveFailures,
      nextRetryAt: record.nextRetryAt,
    );
  }

  @override
  Future<void> removeRefreshRecord(String url) =>
      _db.removeWebMetadataRefresh(url);

  @override
  Future<void> clearAllRefreshRecords() => _db.clearAllWebMetadataRefresh();

  Metadata _metadataFromEntry(WebMetadataEntry entry) => Metadata(
        url: entry.url,
        resolvedUrl: entry.resolvedUrl,
        title: entry.title,
        description: entry.description,
        imageUrl: entry.image,
        fetchedAt: entry.fetchedAt,
        ttlDays: entry.ttlDays,
        etag: entry.etag,
        lastModified: entry.lastModified,
        contentHash: entry.contentHash,
        consecutiveUnchanged: entry.consecutiveUnchanged,
      );
}
