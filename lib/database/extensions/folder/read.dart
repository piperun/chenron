import 'package:chenron/database/database.dart';
import 'package:drift/drift.dart';

extension FolderReadExtensions on AppDatabase {
  Future<List<FolderWithTags>> getAllFoldersWithTags() {
    final query = select(folders).join([
      leftOuterJoin(items, items.folderId.equalsExp(folders.id)),
      leftOuterJoin(
          metadataRecords, metadataRecords.itemId.equalsExp(items.id)),
      leftOuterJoin(tags, tags.id.equalsExp(metadataRecords.metadataId)),
    ]);

    return query.map((row) {
      final folder = row.readTable(folders);
      final tag = row.readTableOrNull(tags);

      return FolderWithTags(
        folder: folder,
        tag: tag,
      );
    }).get();
  }

  Stream<List<FolderWithTags>> watchAllFoldersWithTags() {
    final query = select(folders).join([
      leftOuterJoin(items, items.folderId.equalsExp(folders.id)),
      leftOuterJoin(
          metadataRecords, metadataRecords.itemId.equalsExp(items.id)),
      leftOuterJoin(tags, tags.id.equalsExp(metadataRecords.metadataId)),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final folder = row.readTable(folders);
        final tag = row.readTableOrNull(tags);

        return FolderWithTags(
          folder: folder,
          tag: tag,
        );
      }).toList();
    });
  }
}

class FolderWithTags {
  final Folder folder;
  final Tag? tag;

  FolderWithTags({required this.folder, this.tag});
}
