import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/main.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() async {
    database =
        AppDatabase(databaseName: "test_folders_by_ids_db", debugMode: true);
  });

  tearDown(() async {
    await database.delete(database.items).go();
    await database.delete(database.folders).go();
    await database.close();
  });

  Future<String> createNamedFolder(String title) async {
    final data = FolderTestDataFactory.create(
      title: title,
      description: "",
      tagValues: [],
      itemsData: [],
    );
    final result = await database.createFolder(folderInfo: data.folder);
    return result.folderId;
  }

  group("getFoldersByIds", () {
    test("returns empty list for empty input", () async {
      await createNamedFolder("Alpha Folder");
      expect(await database.getFoldersByIds(const []), isEmpty);
    });

    test("returns rows matching the ids (single round-trip)", () async {
      final a = await createNamedFolder("Alpha Folder");
      await createNamedFolder("Bravo Folder"); // exists but not requested
      final c = await createNamedFolder("Charlie Folder");

      final result = await database.getFoldersByIds([a, c]);

      expect(result, hasLength(2));
      expect(
        result.map((f) => f.title).toSet(),
        {"Alpha Folder", "Charlie Folder"},
      );
      expect(
        result.map((f) => f.title).toSet(),
        isNot(contains("Bravo Folder")),
      );
    });

    test("silently skips ids that don't exist", () async {
      final a = await createNamedFolder("Alpha Folder");

      final result =
          await database.getFoldersByIds([a, "does-not-exist", "also-missing"]);

      expect(result, hasLength(1));
      expect(result.single.title, "Alpha Folder");
    });

    test("handles a large id list in one call", () async {
      // Create 50 folders. The old loop would issue 50 SELECTs; the
      // new method issues one. Behavioural assertion: every id is
      // returned, no duplicates.
      final ids = <String>[];
      for (var i = 0; i < 50; i++) {
        ids.add(await createNamedFolder("Folder $i"));
      }

      final result = await database.getFoldersByIds(ids);

      expect(result, hasLength(50));
      expect(result.map((f) => f.id).toSet(), ids.toSet());
    });
  });
}
