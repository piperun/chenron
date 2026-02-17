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
  }) async {
    await into(webMetadataEntries).insertOnConflictUpdate(
      WebMetadataEntriesCompanion.insert(
        url: url,
        title: Value(title),
        description: Value(description),
        image: Value(image),
        fetchedAt: fetchedAt,
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
}
