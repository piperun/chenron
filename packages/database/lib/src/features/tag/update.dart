import "package:database/main.dart";
import "package:drift/drift.dart";

extension TagUpdateExtensions on AppDatabase {
  Future<void> updateTagColor({
    required String tagName,
    required int? color,
  }) async {
    await (update(tags)..where((t) => t.name.equals(tagName)))
        .write(TagsCompanion(color: Value(color)));
  }

  Future<void> renameTag({
    required String oldName,
    required String newName,
  }) async {
    await (update(tags)..where((t) => t.name.equals(oldName)))
        .write(TagsCompanion(name: Value(newName)));
  }
}
