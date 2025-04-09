import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/id.dart";
import "package:chenron/models/metadata.dart";
import "package:drift/drift.dart";

extension LinkCreateExtensions on AppDatabase {
  Future<String> createLink({
    required String link,
    List<Metadata>? tags,
  }) async {
    return transaction(() async {
      final linkId = await _createLink(link);
      if (tags != null && tags.isNotEmpty) {
        await _createLinkTags(linkId, tags);
      }
      return linkId;
    });
  }

  Future<String> _createLink(String link) async {
    Link? linkExists = await (select(links)
          ..where((tbl) => tbl.path.equals(link)))
        .getSingleOrNull();
    String linkId;

    if (linkExists == null) {
      linkId = generateId();
      await links.insertOne(
        LinksCompanion.insert(id: linkId, path: link),
        mode: InsertMode.insertOrIgnore,
      );
    } else {
      linkId = linkExists.id;
    }
    return linkId;
  }

  Future<void> _createLinkTags(String linkId, List<Metadata> tags) async {
    await batch((batch) async {
      for (var tag in tags) {
        final tagId = await _getOrCreateTag(tag.value);
        batch.insert(
          metadataRecords,
          MetadataRecordsCompanion.insert(
            id: generateId(),
            itemId: linkId,
            metadataId: tagId,
            typeId: MetadataTypeEnum.tag.index,
          ),
        );
      }
    });
  }

  Future<String> _getOrCreateTag(String tagName) async {
    final existingTag = await (select(tags)
          ..where((t) => t.name.equals(tagName)))
        .getSingleOrNull();
    if (existingTag != null) {
      return existingTag.id;
    }
    final newTagId = generateId();
    await tags.insertOne(TagsCompanion.insert(
      id: newTagId,
      name: tagName,
    ));
    return newTagId;
  }
}
