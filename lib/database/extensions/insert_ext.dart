import "dart:convert";

import "package:chenron/database/extensions/id.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/database/database.dart";
import "package:chenron/models/created_ids.dart";
import "package:chenron/utils/str_sanitizer.dart";
import "package:drift/drift.dart";

extension InsertionExtensions on AppDatabase {
  Future<List<CreatedIds<Tag>>> insertTags(
      Batch batch, List<Metadata> tagInserts, String folderId) async {
    List<CreatedIds<Tag>> tagResults = [];
    Map<String, String> existingTags = await _getExistingTags(tagInserts);

    for (final tag in tagInserts) {
      String tagId = existingTags[tag.value] ?? generateId();
      String metadataId = generateId();

      if (!existingTags.containsKey(tag.value)) {
        batch.insert(
          tags,
          onConflict: DoNothing(),
          mode: InsertMode.insertOrIgnore,
          TagsCompanion.insert(id: tagId, name: tag.value),
        );
      }

      batch.insert(
        metadataRecords,
        onConflict: DoNothing(),
        mode: InsertMode.insertOrIgnore,
        MetadataRecordsCompanion.insert(
          id: metadataId,
          typeId: tag.type.index,
          metadataId: tagId,
          itemId: folderId,
        ),
      );
      tagResults.add(CreatedIds.tag(tagId: tagId, metadataId: metadataId));
    }

    return tagResults;
  }

  Future<List<CreatedIds<Item>>> insertFolderItems(
      {required Batch batch,
      required String folderId,
      required List<FolderItem> itemInserts}) async {
    List<CreatedIds<Item>> itemResults = [];

    for (final itemInsert in itemInserts) {
      switch (itemInsert.content) {
        case StringContent(value: final url):
          itemResults.add(
              await _insertLink(batch: batch, folderId: folderId, url: url));
        case MapContent(value: final doc):
          itemResults.add(_insertDocument(
            batch: batch,
            folderId: folderId,
            doc: doc,
          ));
      }
    }
    return itemResults;
  }

  Future<CreatedIds<Item>> _insertLink({
    required Batch batch,
    required String folderId,
    required String url,
  }) async {
    url = removeTrailingSlash(url);
    Link? linkExists = await (select(links)
          ..where((tbl) => tbl.content.equals(url)))
        .getSingleOrNull();
    String linkId;

    if (linkExists == null) {
      linkId = generateId();
      batch.insert(
        links,
        LinksCompanion.insert(id: linkId, content: url),
        mode: InsertMode.insertOrIgnore,
      );
    } else {
      linkId = linkExists.id;
    }

    final itemId = _insertItem(
        batch: batch,
        itemId: linkId,
        folderId: folderId,
        type: FolderItemType.link);
    return CreatedIds.item(linkId: linkId, itemId: itemId);
  }

  CreatedIds<Item> _insertDocument({
    required Batch batch,
    required String folderId,
    required Map<String, String> doc,
  }) {
    String documentId = generateId();
    batch.insert(
      documents,
      DocumentsCompanion.insert(
        id: documentId,
        title: doc["title"] ?? "",
        content: utf8.encode(doc["body"] ?? ""),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    final itemId = _insertItem(
        batch: batch,
        itemId: documentId,
        folderId: folderId,
        type: FolderItemType.document);
    return CreatedIds.item(documentId: documentId, itemId: itemId);
  }

  String _insertItem(
      {required Batch batch,
      required String itemId,
      required String folderId,
      required FolderItemType type}) {
    String id = generateId();
    batch.insert(
      items,
      ItemsCompanion.insert(
        id: id,
        folderId: folderId,
        itemId: itemId,
        typeId: type.index,
      ),
      mode: InsertMode.insertOrIgnore,
    );
    return id;
  }

  Future<Map<String, String>> _getExistingTags(
      List<Metadata> tagInserts) async {
    final tagNames = tagInserts.map((t) => t.value).toSet();
    final existingTags =
        await (select(tags)..where((t) => t.name.isIn(tagNames))).get();
    return {for (var tag in existingTags) tag.name: tag.id};
  }
}
