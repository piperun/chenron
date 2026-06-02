import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(databaseName: "test_descendants_db", debugMode: true);
  });

  tearDown(() async {
    await database.delete(database.items).go();
    await database.delete(database.folders).go();
    await database.close();
  });

  Future<String> createFolder(String title) async {
    final data = FolderTestDataFactory.create(
      title: title,
      description: "",
      tagValues: [],
      itemsData: [],
    );
    final result = await database.createFolder(folderInfo: data.folder);
    return result.folderId;
  }

  /// Nest [child] inside [parent] (parent is parent-of child).
  Future<void> nest(String parent, String child) async {
    await database.addItemToFolder(
      itemId: child,
      folderId: parent,
      type: FolderItemType.folder,
    );
  }

  group("getDescendantFolderIds", () {
    test("returns empty set for a leaf folder", () async {
      final leaf = await createFolder("LeafFolder");
      final descendants =
          await database.getDescendantFolderIds(folderId: leaf);
      expect(descendants, isEmpty);
    });

    test("returns transitive child + grandchild ids", () async {
      // parent -> child -> grandchild
      final parent = await createFolder("ParentFolder");
      final child = await createFolder("ChildFolder");
      final grandchild = await createFolder("GrandchildFolder");
      await nest(parent, child);
      await nest(child, grandchild);

      final descendants =
          await database.getDescendantFolderIds(folderId: parent);

      expect(descendants, containsAll(<String>[child, grandchild]));
      // The folder itself is not its own descendant.
      expect(descendants.contains(parent), isFalse);
    });

    test("does not loop forever on an existing cycle", () async {
      // a -> b -> a (a pre-existing cycle from older buggy writes)
      final a = await createFolder("FolderA");
      final b = await createFolder("FolderB");
      await nest(a, b);
      await nest(b, a);

      final descendants =
          await database.getDescendantFolderIds(folderId: a);

      // b is a descendant; a reached again via the cycle must not hang or
      // be reported as its own descendant.
      expect(descendants, contains(b));
    });

    test("collects descendants across multiple branches", () async {
      final root = await createFolder("RootFolder");
      final left = await createFolder("LeftFolder");
      final right = await createFolder("RightFolder");
      final leftLeaf = await createFolder("LeftLeafFolder");
      await nest(root, left);
      await nest(root, right);
      await nest(left, leftLeaf);

      final descendants =
          await database.getDescendantFolderIds(folderId: root);

      expect(descendants, containsAll(<String>[left, right, leftLeaf]));
    });
  });
}
