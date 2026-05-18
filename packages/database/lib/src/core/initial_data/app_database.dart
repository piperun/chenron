import "package:database/app_database.dart";
import "package:database/models/folder.dart";
import "package:database/src/features/folder/create.dart";

extension DatabaseInit on AppDatabase {
  /// Seed the default "Default" folder on first creation if none exists.
  ///
  /// Enum-table seeding used to live here too (and was bundled with
  /// this method). After the v15 migration replaced the lookup tables
  /// with `intEnum<T>()`, only the default-folder bootstrap remains.
  Future<void> setupDefaultFolder() async {
    final folderCount = await select(folders).get().then((f) => f.length);
    if (folderCount > 0) return;
    await createFolder(
      folderInfo: FolderDraft(
        title: "Default",
        description: "Default folder for all items",
      ),
    );
  }
}
