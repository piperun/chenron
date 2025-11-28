import "package:database/database.dart" show AppDatabase;
import "package:database/extensions/insert_ext.dart";
import "package:database/models/created_ids.dart" show ItemResultIds;
import "package:database/models/item.dart";
import "package:drift/drift.dart" show Batch;

extension InsertionExtensions on AppDatabase {
  Future<List<ItemResultIds>> insertFolderItems({
    required Batch batch,
    required String folderId,
    required List<FolderItem> itemInserts,
  }) async {
    final List<String> linkUrls = [];
    final List<DocumentItem> docItems = [];
    final List<FolderItem> folderItems = [];

    for (final item in itemInserts) {
      item.map(
        link: (linkItem) => linkUrls.add(linkItem.url),
        document: (docItem) => docItems.add(docItem),
        folder: (folderItem) => folderItems.add(item),
      );
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

    if (docItems.isNotEmpty) {
      final docResults = insertDocuments(batch: batch, docs: docItems);
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
