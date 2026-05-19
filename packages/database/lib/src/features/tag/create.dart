import "package:database/database.dart";
import "package:database/src/core/handlers/run_vepr.dart";
import "package:database/src/core/id.dart";
import "package:drift/drift.dart";

extension TagExtensions on AppDatabase {
  Future<String> addTag(String tagName, {int? color}) async {
    final result = await runVepr<TagResultIds, void, TagResultIds>(
      logSource: "addTag",
      validate: () {
        if (tagName.trim().isEmpty) {
          throw ArgumentError("Tag name cannot be empty.");
        }
      },
      execute: () async {
        final existing = await (select(tags)
              ..where((t) => t.name.equals(tagName)))
            .getSingleOrNull();
        if (existing != null) {
          return TagResultIds(tagId: existing.id, wasCreated: false);
        }
        final id = generateId();
        await tags.insertOne(
          TagsCompanion.insert(id: id, name: tagName, color: Value(color)),
          mode: InsertMode.insertOrIgnore,
        );
        return TagResultIds(tagId: id, wasCreated: true);
      },
      process: (_) async {},
      build: (e, _) => e,
    );
    return result.tagId;
  }
}
