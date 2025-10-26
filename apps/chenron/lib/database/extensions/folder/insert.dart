import "package:chenron/database/database.dart" show AppDatabase;
import "package:chenron/database/extensions/insert_ext.dart";
import "package:chenron/models/created_ids.dart" show ItemResultIds;
import "package:chenron/models/item.dart"
    show FolderItem, FolderItemType, MapContent, StringContent;
import "package:drift/drift.dart" show Batch;

extension InsertionExtensions on AppDatabase {
  Future<List<ItemResultIds>> insertFolderItems({
    required Batch batch,
    required String folderId,
    required List<FolderItem> itemInserts,
  }) async {
    final List<String> linkUrls = [];
    final List<Map<String, String>> docList = [];
    final List<FolderItem> folderItems = [];

    for (final item in itemInserts) {
      // Handle folder items separately
      if (item.type == FolderItemType.folder && item.itemId != null) {
        folderItems.add(item);
        continue;
      }

      switch (item.path) {
        case StringContent(value: final url):
          linkUrls.add(url);
        case MapContent(value: final doc):
          docList.add(doc);
      }
    }

    final List<ItemResultIds> relations = <ItemResultIds>[];

    // Handle folder-to-folder relationships
    if (folderItems.isNotEmpty) {
      for (final folderItem in folderItems) {
        final relation = insertItemRelation(
          batch: batch,
          entityId: folderItem.itemId!,
          folderId: folderId,
          type: FolderItemType.folder,
        );
        relations.add(relation);
      }
    }

    if (linkUrls.isNotEmpty) {
      final linkResults = await insertLinks(batch: batch, urls: linkUrls);
      for (final linkResult in linkResults) {
        final relation = insertItemRelation(
          batch: batch,
          entityId: linkResult.linkId,
          folderId: folderId,
          type: FolderItemType.link,
        );
        relations.add(relation);
      }
    }

    if (docList.isNotEmpty) {
      final docResults = insertDocuments(batch: batch, docs: docList);
      for (final docResult in docResults) {
        final relation = insertItemRelation(
          batch: batch,
          entityId: docResult.documentId,
          folderId: folderId,
          type: FolderItemType.document,
        );
        relations.add(relation);
      }
    }

    return relations;
  }
}
