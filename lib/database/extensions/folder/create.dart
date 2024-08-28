import 'package:chenron/data_struct/item.dart';
import 'package:chenron/data_struct/metadata.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/data_struct/folder.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

extension FolderExtensions on AppDatabase {
  static final Logger _logger = Logger('Folder Actions Database');
  Future<void> addFolder({
    required FolderInfo folderInfo,
    List<Metadata>? tags,
    List<FolderItem>? items,
  }) async {
    return transaction(() async {
      try {
        if (folderInfo.title != "") {
          await _createFolderInfo(folderInfo);
        }
        if (tags != null) {
          await _createFolderTags(folderInfo.id, tags);
        }
        if (items != null) {
          await _createFolderContent(folderInfo.id, items);
        }
      } catch (e) {
        _logger.severe('Error adding folder: $e');
        rethrow;
      }
    });
  }

  Future<int> _createFolderInfo(FolderInfo folderInfo) async {
    final newFolder = FoldersCompanion.insert(
      id: folderInfo.id,
      title: folderInfo.title,
      description: folderInfo.description,
    );
    return await folders.insertOne(newFolder);
  }

  Future<void> _createFolderTags(
      String folderId, List<Metadata> tagInserts) async {
    if (tagInserts.isEmpty) {
      return;
    }
    await batch((batch) async {
      await _insertTags(batch, tagInserts, folderId);
    });
  }

  Future<void> _createFolderContent(
      String folderId, List<FolderItem> itemInserts) async {
    if (itemInserts.isEmpty) return;

    await batch((batch) async {
      await _insertFolderItems(batch, folderId, itemInserts);
    });
  }

  Future<void> _insertFolderItems(
      Batch batch, String folderId, List<FolderItem> itemInserts) async {
    for (final itemInsert in itemInserts) {
      TableInfo? table;
      List<dynamic> exists = [];
      switch (itemInsert.type) {
        case FolderItemType.link:
          table = links;
          exists = await (select(links)
                ..where((tbl) => tbl.url.equals(itemInsert.content)))
              .get();
        case FolderItemType.document:
          table = documents;
          exists = await (select(documents)
                ..where((tbl) => tbl.id.equals(itemInsert.itemId)))
              .get();
      }
      if (exists.isEmpty) {
        batch.insert(
          table,
          onConflict: DoNothing(),
          mode: InsertMode.insertOrIgnore,
          itemInsert.toFolderItem(),
        );
      } else {
        itemInsert.itemId = exists.first.id;
      }

      batch.insert(
        items,
        onConflict: DoNothing(),
        mode: InsertMode.insertOrIgnore,
        itemInsert.toCompanion(folderId),
      );
    }
  }

  Future<void> _insertTags(
      Batch batch, List<Metadata> tagInserts, String folderId) async {
    List<Tag> exists = [];
    for (final tag in tagInserts) {
      exists = await (select(tags)
            ..where(
              (tbl) => tbl.id.equals(tag.id),
            ))
          .get();
      if (exists.isEmpty) {
        batch.insert(
          tags,
          onConflict: DoNothing(),
          mode: InsertMode.insertOrIgnore,
          tag.toMetadataItem(),
        );
      } else {
        tag.metadataId = exists.first.id;
      }
      batch.insert(
        metadataRecords,
        onConflict: DoNothing(),
        mode: InsertMode.insertOrIgnore,
        tag.toCompanion(folderId),
      );
    }
  }
}
