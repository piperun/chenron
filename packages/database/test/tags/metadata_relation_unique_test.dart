import "package:database/database.dart";
import "package:database/src/features/link/create.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";

/// A tag relation is identified by (itemId, metadataId, typeId). The same tag
/// must never be recorded against the same item more than once, no matter how
/// many times the create path runs (e.g. one link saved to several folders, or
/// an existing URL re-imported). A unique index enforces this so that
/// `insertMetadataRelation`'s `insertOrIgnore` actually deduplicates.
void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(
      databaseName: "test_metadata_relation_unique_db",
      setupOnInit: true,
      debugMode: true,
    );
  });

  tearDown(() async {
    await database.delete(database.metadataRecords).go();
    await database.delete(database.links).go();
    await database.delete(database.tags).go();
    await database.close();
  });

  Future<int> tagRelationCount(String itemId) async {
    final rows = await (database.select(database.metadataRecords)
          ..where((t) => t.itemId.equals(itemId)))
        .get();
    return rows.where((r) => r.typeId == MetadataTypeEnum.tag).length;
  }

  test("createLink for an existing url does not duplicate its tag relations",
      () async {
    final tag = [Metadata(type: MetadataTypeEnum.tag, value: "flutter")];

    final first =
        await database.createLink(link: "https://example.com", tags: tag);
    // Same URL again — createLink reuses the existing link, but its tag
    // process re-runs. Without a unique relation index this appended a second
    // copy of the "flutter" relation.
    final second =
        await database.createLink(link: "https://example.com", tags: tag);

    expect(second.linkId, first.linkId);
    expect(await tagRelationCount(first.linkId), 1);
  });

  test("a single createLink records each tag exactly once", () async {
    final result = await database.createLink(
      link: "https://multi.example",
      tags: [
        Metadata(type: MetadataTypeEnum.tag, value: "dart"),
        Metadata(type: MetadataTypeEnum.tag, value: "flutter"),
      ],
    );

    expect(await tagRelationCount(result.linkId), 2);
  });
}
