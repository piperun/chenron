import "package:database/main.dart";
import "package:drift/drift.dart";

extension WebMetadataCrudExtensions on AppDatabase {
  Future<WebMetadataEntry?> getWebMetadata(String url) async {
    return (select(webMetadataEntries)
          ..where((t) => t.url.equals(url)))
        .getSingleOrNull();
  }

  Future<void> upsertWebMetadata({
    required String url,
    String? title,
    String? description,
    String? image,
    required DateTime fetchedAt,
    int consecutiveUnchanged = 0,
    int ttlDays = 7,
  }) async {
    await into(webMetadataEntries).insertOnConflictUpdate(
      WebMetadataEntriesCompanion.insert(
        url: url,
        title: Value(title),
        description: Value(description),
        image: Value(image),
        fetchedAt: fetchedAt,
        consecutiveUnchanged: Value(consecutiveUnchanged),
        ttlDays: Value(ttlDays),
      ),
    );
  }

  Future<void> removeWebMetadata(String url) async {
    await (delete(webMetadataEntries)
          ..where((t) => t.url.equals(url)))
        .go();
  }

  Future<void> clearAllWebMetadata() async {
    await delete(webMetadataEntries).go();
  }

  Future<int> countWebMetadata() async {
    final count = countAll();
    final query = selectOnly(webMetadataEntries)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count)!;
  }

  /// Search metadata entries by title or description content.
  Future<List<WebMetadataEntry>> searchWebMetadata(String query) async {
    final pattern = "%$query%";
    return (select(webMetadataEntries)
          ..where(
            (w) => w.title.like(pattern) | w.description.like(pattern),
          ))
        .get();
  }

  /// Return all entries whose TTL has expired.
  ///
  /// An entry is expired when `fetchedAt + ttlDays` is in the past.
  Future<List<WebMetadataEntry>> getExpiredEntries() async {
    final rows = await customSelect(
      "SELECT * FROM web_metadata_entries "
      "WHERE datetime(fetched_at, '+' || ttl_days || ' days') < datetime('now')",
      readsFrom: {webMetadataEntries},
    ).get();
    return rows
        .map((row) => webMetadataEntries.map(row.data))
        .toList();
  }
}
