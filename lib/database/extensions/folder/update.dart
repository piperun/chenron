import 'package:chenron/models/item.dart';
import 'package:chenron/models/metadata.dart';
import 'package:chenron/database/extensions/insert_ext.dart';
import 'package:drift/drift.dart';
import 'package:chenron/models/cud.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/actions/batch.dart';

extension FolderExtensions on AppDatabase {
  Future<void> updateFolder(String folderId,
      {String? title,
      String? description,
      CUD<Metadata>? tagUpdates,
      CUD<FolderItem>? itemUpdates}) {
    return batchOps((batch) async {
      if (title != null || description != null) {
        await _updateFolderInfo(folderId, title, description);
      }
      if (tagUpdates != null) {
        await _updateFolderTags(folderId, tagUpdates);
      }
      if (itemUpdates != null) {
        await _updateFolderContent(folderId, itemUpdates);
      }
    });
  }

  Future<int> _updateFolderInfo(
      String folderId, String? title, String? description) async {
    final folderUpdate = FoldersCompanion(
      title: title == null ? const Value.absent() : Value(title),
      description:
          description == null ? const Value.absent() : Value(description),
    );
    return (folders.update()..where((t) => t.id.equals(folderId)))
        .write(folderUpdate);
  }

  Future<void> _updateFolderTags(
      String folderId, CUD<Metadata> tagUpdates) async {
    if (tagUpdates.create.isNotEmpty) {
      await batch((batch) async {
        await insertTags(batch, tagUpdates.create, folderId);
      });
    }
    if (tagUpdates.update.isNotEmpty) {
      await batch((batch) async {
        for (final tagUpdate in tagUpdates.update) {
          batch.insert(
              mode: InsertMode.insertOrIgnore,
              onConflict: DoNothing(),
              metadataRecords,
              tagUpdate.toCompanion(folderId));
        }
      });
    }
    if (tagUpdates.remove.isNotEmpty) {
      await batch((batch) async {
        for (final tagRemove in tagUpdates.remove) {
          batch.deleteWhere(
              metadataRecords, (tbl) => tbl.metadataId.equals(tagRemove));
        }
      });
    }
  }

  Future<void> _updateFolderContent(
      String folderId, CUD<FolderItem> itemUpdates) async {
    if (itemUpdates.create.isNotEmpty) {
      await batch((batch) async {
        await insertFolderItems(batch, folderId, itemUpdates.create);
      });
    }
    if (itemUpdates.update.isNotEmpty) {
      await batch((batch) async {
        for (final itemUpdate in itemUpdates.update) {
          batch.insert(
              mode: InsertMode.insertOrIgnore,
              onConflict: DoNothing(),
              items,
              itemUpdate.toCompanion(folderId));
        }
      });
    }
    if (itemUpdates.remove.isNotEmpty) {
      await batch((batch) async {
        for (final tagRemove in itemUpdates.remove) {
          batch.deleteWhere(
              items,
              (tbl) =>
                  (tbl.itemId.equals(tagRemove)) &
                  tbl.folderId.equals(folderId));
          /*{ 
            final findItemId = tbl.itemId.equals(tagRemove.itemId);
            final findFolderId = tbl.folderId.equals(folderId);
            return findFolderId & findItemId;});
            */
          //(tbl) => tbl.folderId.equals(folderId));
        }
      });
    }
  }
}

/*
  Future<void> _updateFolderContent(
      BatchOperations batch, String folderId, CUD folderContent) async {
    final createOperations = <(TableInfo, Insertable)>[];
    final relationOperations = <(TableInfo, Insertable)>[];
    final updateOperations = <(TableInfo, Insertable)>[];
    final removeOperations = <(TableInfo, Insertable)>[];

    for (final item in folderContent.create) {
      final insert = item.toInsertable();
      final relation = _getRelationInsert(folderId, insert);
      final (dataTable, relationTable) = _getTablesForRow(insert);
      createOperations.add((dataTable, insert));
      relationOperations.add((relationTable, relation));
    }

    for (final item in folderContent.update) {
      final (_, relationTable) = _getTablesForRow(item);
      updateOperations.add((relationTable, item));
    }
    for (final item in folderContent.remove) {
      final (insertTable, _) = _getTablesForRow(item);
      removeOperations.add((insertTable, item));
    }

    await batch.insertIterBatch(createOperations);
    await batch.insertIterBatch(relationOperations);
    await batch.insertIterBatch(updateOperations);
    await batch.deleteIterBatch(removeOperations);
  }

  (TableInfo, TableInfo) _getTablesForRow(Insertable row) {
    switch (row) {
      case FolderTreesCompanion():
        return (folderTrees, folderTrees);
      case LinksCompanion():
        return (links, folderLinks);
      case DocumentsCompanion():
        return (documents, folderDocuments);

      default:
        throw ArgumentError('Invalid row type: ${row.runtimeType}');
    }
  }

  Insertable _getRelationInsert(String id, Insertable row) {
    switch (row) {
      case LinksCompanion():
        return FolderLinksCompanion.insert(folderId: id, linkId: row.id.value);
      case DocumentsCompanion():
        return FolderDocumentsCompanion.insert(
            folderId: id, documentId: row.id.value);
      case FoldersCompanion():
        return FolderTreesCompanion.insert(parentId: id, childId: row.id.value);
      default:
        throw ArgumentError('Invalid row type: ${row.runtimeType}');
    }
  }
}

*/