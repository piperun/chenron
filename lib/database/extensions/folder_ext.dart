import 'dart:convert';
import 'package:cuid2/cuid2.dart';
import 'package:logging/logging.dart';
import 'package:drift/drift.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/types/data_types.dart';

extension FolderExtensions on AppDatabase {
  static final Logger _logger = Logger('Folder Actions Database');

  Future<void> addFolder({
    required FolderDataType folderData,
    List<String>? tags,
    List<DataBaseObject>? items,
  }) async {
    String tagId;

    return transaction(() async {
      try {
        // Insert folder
        final newFolder = FoldersCompanion.insert(
          id: folderData.id,
          title: folderData.title,
          description: folderData.description,
        );
        await folders.insertOne(newFolder);

        // Process tags
        if (tags != null && tags.isNotEmpty) {
          await batch((batch) {
            for (final tagName in tags) {
              tagId = cuidSecure(30);
              batch.insert(
                  this.tags,
                  onConflict: DoNothing(),
                  mode: InsertMode.insertOrIgnore,
                  TagsCompanion.insert(id: tagId, name: tagName));
              batch.insert(
                  folderTags,
                  onConflict: DoNothing(),
                  mode: InsertMode.insertOrIgnore,
                  FolderTagsCompanion.insert(
                      folderId: folderData.id, tagId: tagId));
            }
          });
        }

        // Process items (Links or Documents)
        if (items != null && items.isNotEmpty) {
          await batch(
            (batch) {
              for (final item in items) {
                if (!isCuid(item.id)) {
                  throw Exception(
                      'Invalid id: got $item.id expected: {$cuidSecure(30)}');
                }
                switch (item) {
                  case LinkDataType link:
                    batch.insert(
                        links,
                        onConflict: DoNothing(),
                        mode: InsertMode.insertOrIgnore,
                        LinksCompanion.insert(
                          id: link.id,
                          url: link.url,
                        ));
                    batch.insert(
                        folderLinks,
                        onConflict: DoNothing(),
                        mode: InsertMode.insertOrIgnore,
                        FolderLinksCompanion.insert(
                            folderId: folderData.id, linkId: link.id));
                    break;
                  case DocumentDataType document:
                    batch.insert(
                        documents,
                        onConflict: DoNothing(),
                        mode: InsertMode.insertOrIgnore,
                        DocumentsCompanion.insert(
                          id: document.id,
                          title: document.title,
                          content: utf8.encode(document.content),
                        ));
                    batch.insert(
                        folderDocuments,
                        onConflict: DoNothing(),
                        mode: InsertMode.insertOrIgnore,
                        FolderDocumentsCompanion.insert(
                            folderId: folderData.id, documentId: document.id));
                    break;
                  default:
                    _logger.severe('Unknown item type');
                    throw ArgumentError('Invalid item type: $item');
                }
              }
            },
          );
        }
      } catch (e) {
        _logger.severe('Error adding folder: $e');
        rethrow; // Rethrow the error to be handled by the caller
      }
    });
  }

  Future<bool> removeFolder(String folderId) async {
    return transaction(() async {
      final deletions = await Future.wait([
        (delete(folders)..where((t) => t.id.equals(folderId))).go(),
        (delete(folderTags)..where((t) => t.folderId.equals(folderId))).go(),
        (delete(folderLinks)..where((t) => t.folderId.equals(folderId))).go(),
        (delete(folderDocuments)..where((t) => t.folderId.equals(folderId)))
            .go(),
        (delete(folderTrees)..where((t) => t.parentId.equals(folderId))).go(),
      ]);

      return deletions.any((count) => count > 0);
    });
  }
}
