import "package:chenron/database/database.dart";
import "package:cuid2/cuid2.dart";
import "package:drift/drift.dart";

extension TagExtensions on AppDatabase {
  Future<String> addTag(String tagName) async {
    final existingTag = await (tags.select()
          ..where((t) => t.name.equals(tagName)))
        .getSingleOrNull();

    final String tagId = existingTag?.id ?? cuidSecure(30);

    if (existingTag == null) {
      await tags.insertOne(
          mode: InsertMode.insertOrIgnore,
          onConflict: DoNothing(),
          TagsCompanion.insert(
            id: tagId,
            name: tagName,
          ));
    }
    return tagId;
  }
}
