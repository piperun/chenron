import 'package:chenron/data_struct/item.dart';
import 'package:chenron/data_struct/metadata.dart';
import 'package:chenron/database/database.dart';
import 'package:drift/drift.dart';

extension InsertionExtensions on AppDatabase {
  Future<void> insertTags(
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

  Future<void> insertFolderItems(
      Batch batch, String folderId, List<FolderItem> itemInserts) async {
    for (final itemInsert in itemInserts) {
      TableInfo? table;
      List<dynamic> exists = [];
      switch (itemInsert.content) {
        case StringContent(value: String url):
          table = links;
          exists = await (select(links)
                ..where((tbl) => tbl.content.equals(url)))
              .get();
        case MapContent(value: Map<String, String> doc):
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
}
