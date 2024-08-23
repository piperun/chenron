import 'package:drift/drift.dart';
import 'package:chenron/database/types/data_types.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/actions/batch.dart';

extension FolderExtensions on AppDatabase {
  Future<void> updateFolder(String folderId,
      {String? title,
      String? description,
      CUD? tagUpdates,
      CUD? dataBaseObjects}) {
    return batchOps((batch) async {
      if (title != null || description != null) {
        await _updateFolderInfo(folderId, title, description);
      }
      if (tagUpdates != null) {
        await _updateFolderTags(batch, folderId, tagUpdates);
      }
      if (dataBaseObjects != null) {
        await _updateFolderContent(batch, folderId, dataBaseObjects);
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
      BatchOperations batch, String folderId, CUD tagUpdates) async {
    if (tagUpdates.create.isNotEmpty) {
      await batch.insertAllBatch(
          tags, tagUpdates.create.map((tag) => tag.toInsertable()));
      await batch.insertAllBatch(
          folderTags,
          tagUpdates.create.map((tag) =>
              FolderTagsCompanion.insert(folderId: folderId, tagId: tag.id)));
    }
    if (tagUpdates.update.isNotEmpty) {
      await batch.insertAllBatch(folderTags, tagUpdates.update);
    }
    if (tagUpdates.remove.isNotEmpty) {
      await batch.deleteBatch(folderTags, tagUpdates.remove);
    }
  }

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
      case FolderLinksCompanion():
        return (folderLinks, folderLinks);
      case FolderDocumentsCompanion():
        return (folderDocuments, folderDocuments);
      case FolderTagsCompanion():
        return (folderTags, folderTags);
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
