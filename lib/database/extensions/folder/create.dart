import 'package:chenron/data_struct/item.dart';
import 'package:chenron/data_struct/metadata.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/data_struct/folder.dart';
import 'package:chenron/database/extensions/insert_ext.dart';
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
      await insertTags(batch, tagInserts, folderId);
    });
  }

  Future<void> _createFolderContent(
      String folderId, List<FolderItem> itemInserts) async {
    if (itemInserts.isEmpty) return;

    await batch((batch) async {
      await insertFolderItems(batch, folderId, itemInserts);
    });
  }
}
