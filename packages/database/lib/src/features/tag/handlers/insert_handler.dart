import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/models/metadata.dart";
import "package:database/src/core/id.dart";

import "package:drift/drift.dart";

extension TagInsertHandler on AppDatabase {
  Future<List<TagResultIds>> insertTags({
    required Batch batch,
    required List<Metadata> tagMetadata,
  }) async {
    if (tagMetadata.isEmpty) return <TagResultIds>[];

    final Map<String, String> existingTagsMap =
        await _getExistingTags(tagMetadata);
    final List<TagResultIds> results = <TagResultIds>[];

    for (final Metadata metadata in tagMetadata) {
      final String tagId;

      if (existingTagsMap.containsKey(metadata.value)) {
        tagId = existingTagsMap[metadata.value]!;
      } else {
        tagId = generateId();
        batch.insert(
          tags,
          onConflict: DoNothing(),
          mode: InsertMode.insertOrIgnore,
          TagsCompanion.insert(id: tagId, name: metadata.value),
        );
      }

      results.add(TagResultIds(tagId: tagId));
    }

    return results;
  }

  Future<Map<String, String>> _getExistingTags(
      List<Metadata> tagInserts) async {
    if (tagInserts.isEmpty) return <String, String>{};

    final Set<String> tagNames =
        tagInserts.map((Metadata t) => t.value).toSet();

    const int maxQuerySize = 500;
    if (tagNames.length > maxQuerySize) {
      final Map<String, String> result = <String, String>{};
      final List<List<String>> chunks =
          _chunkList<String>(tagNames.toList(), maxQuerySize);

      for (final List<String> chunk in chunks) {
        final List<Tag> chunkResults =
            await (select(tags)..where((t) => t.name.isIn(chunk))).get();
        result.addAll({for (final Tag tag in chunkResults) tag.name: tag.id});
      }

      return result;
    }

    final List<Tag> existingTags =
        await (select(tags)..where((t) => t.name.isIn(tagNames))).get();
    return {for (final Tag tag in existingTags) tag.name: tag.id};
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final List<List<T>> chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      final int end =
          (i + chunkSize < list.length) ? i + chunkSize : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }
}
