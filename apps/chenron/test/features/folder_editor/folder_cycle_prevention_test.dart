import "package:chenron/components/forms/folder_form.dart";
import "package:chenron/features/folder_editor/notifiers/folder_editor_notifier.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get_it/get_it.dart";
import "package:signals/signals.dart";

class _MockAppDatabaseLifecycle extends AppDatabaseLifecycle {
  final AppDatabase _injected;

  _MockAppDatabaseLifecycle(this._injected);

  @override
  AppDatabase get database => _injected;

  @override
  AppDatabase get appDatabase => _injected;

  @override
  AppDatabase buildDatabase({
    required String databaseName,
    required String customPath,
    required bool setupOnInit,
  }) =>
      throw UnimplementedError("Mock does not build databases");
}

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  group("Folder editor cycle prevention", () {
    late MockDatabaseHelper mockDb;

    setUp(() async {
      mockDb = MockDatabaseHelper();
      await mockDb.setup(setupOnInit: true);

      if (GetIt.I.isRegistered<Signal<AppDatabaseLifecycle>>()) {
        await GetIt.I.reset();
      }
      GetIt.I.registerSingleton<Signal<AppDatabaseLifecycle>>(
        signal(_MockAppDatabaseLifecycle(mockDb.database)),
      );
    });

    tearDown(() async {
      await mockDb.dispose();
      if (GetIt.I.isRegistered<Signal<AppDatabaseLifecycle>>()) {
        await GetIt.I.reset();
      }
    });

    test(
        "setting a descendant as parent does not write a reciprocal row",
        () async {
      // parent contains child -> child is a descendant of parent.
      final parentId = await mockDb.createTestFolder(title: "Parent Folder");
      final childId = await mockDb.createTestFolder(title: "Child Folder");
      await mockDb.database.addItemToFolder(
        itemId: childId,
        folderId: parentId,
        type: FolderItemType.folder,
      );

      final notifier = FolderEditorNotifier();
      await notifier.loadFolder(parentId);

      // Attempt the illegal move: make the child the parent's parent.
      final current = notifier.formData.value!;
      notifier.updateFormData(
        FolderFormData(
          title: current.title,
          description: current.description,
          color: current.color,
          parentFolderIds: [childId],
          tags: current.tags,
          items: current.items,
        ),
      );

      await notifier.saveChanges(parentId);

      // The child must NOT have gained the parent as one of its own items;
      // otherwise parent->child and child->parent form a cycle.
      final childsParents =
          await mockDb.database.getParentFolders(itemId: parentId);
      expect(
        childsParents.map((f) => f.id),
        isNot(contains(childId)),
        reason: "A descendant must never become an ancestor (cycle).",
      );

      notifier.dispose();
    });

    test("setting the folder itself as its own parent is rejected", () async {
      final folderId = await mockDb.createTestFolder(title: "Self Folder");

      final notifier = FolderEditorNotifier();
      await notifier.loadFolder(folderId);

      final current = notifier.formData.value!;
      notifier.updateFormData(
        FolderFormData(
          title: current.title,
          description: current.description,
          color: current.color,
          parentFolderIds: [folderId],
          tags: current.tags,
          items: current.items,
        ),
      );

      await notifier.saveChanges(folderId);

      final selfParents =
          await mockDb.database.getParentFolders(itemId: folderId);
      expect(
        selfParents.map((f) => f.id),
        isNot(contains(folderId)),
        reason: "A folder must never be its own parent.",
      );

      notifier.dispose();
    });
  });
}
