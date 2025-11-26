import "package:database/database.dart" show AppDatabase, Document;
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
    final List<Document> docList = [];
    final List<FolderItem> folderItems = [];

    for (final item in itemInserts) {
      item.map(
        link: (linkItem) => linkUrls.add(linkItem.url),
        document: (docItem) {
          // Create a Document object for insertion
          final doc = Document(
            id: docItem.id ?? '',
            title: docItem.title,
            filePath: docItem.filePath,
            mimeType: docItem.mimeType,
            fileSize: docItem.fileSize,
            checksum: docItem.checksum,
            createdAt: docItem.createdAt ?? DateTime.now(),
            updatedAt: docItem.updatedAt ?? DateTime.now(),
          );
          docList.add(doc);
        },
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
