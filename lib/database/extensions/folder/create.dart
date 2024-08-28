import 'package:chenron/data_struct/item.dart';
import 'package:chenron/data_struct/metadata.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/actions/batch.dart';
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
        return batchOps((batch) async {
          if (folderInfo.title != "") {
            await _createFolderInfo(folderInfo);
          }
          if (tags != null) {
            await _createFolderTags(batch, folderInfo.id, tags);
          }
          if (items != null) {
            await _createFolderContent(folderInfo.id, items);
          }
        });
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
      BatchOperations batch, String folderId, List<Metadata> tagInserts) async {
    if (tagInserts.isNotEmpty) {
      await batch.insertAllBatch(
          tags, tagInserts.map((tag) => tag.toMetadataItem()));
      await batch.insertAllBatch(
          metadataRecords, tagInserts.map((tag) => tag.toCompanion(folderId)));
    }
  }

  Future<void> _createFolderContent(
      String folderId, List<FolderItem> itemInserts) async {
    if (itemInserts.isEmpty) return;

    await batch((batch) async {
      for (final itemInsert in itemInserts) {
        await _insertFolderItem(batch, folderId, itemInsert);
      }
    });
  }

  Future<void> _insertFolderItem(
      Batch batch, String folderId, FolderItem itemInsert) async {
    final table = _getTableForItemType(itemInsert.type);
    if (table == null) {
      _logger.severe('Unknown item type');
      throw ArgumentError('Invalid item type: $itemInsert');
    }
    await _yes(batch, itemInsert, folderId);
  }

  Future<void> _yes(Batch batch, FolderItem itemInsert, String folderId) async {
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

  TableInfo? _getTableForItemType(FolderItemType type) {
    switch (type) {
      case FolderItemType.link:
        return links;
      case FolderItemType.document:
        return documents;
      default:
        return null;
    }
  }
}
