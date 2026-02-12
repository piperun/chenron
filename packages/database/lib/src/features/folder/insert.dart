import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/models/item.dart";
import "package:database/src/core/handlers/relation_handler.dart";
import "package:database/src/features/document/handlers/insert_handler.dart";
import "package:database/src/features/link/handlers/insert_handler.dart";
import "package:drift/drift.dart";

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
          itemId: folderItem.itemId!,
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
          itemId: linkResult.linkId,
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
          itemId: docResult.documentId,
          folderId: folderId,
          type: FolderItemType.document,
        );
        relations.add(relation);
      }
    }

    return relations;
  }
}
