import "package:chenron/database/actions/joins/item.dart";
import "package:chenron/database/actions/joins/tag.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/base_query_builder.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:drift/drift.dart";

class FolderRelationBuilder implements RelationBuilder<FolderResult> {
  final AppDatabase db;

  final ItemJoins itemJoins;
  final TagJoins tagJoins;
  FolderRelationBuilder(this.db)
      : itemJoins = ItemJoins(db),
        tagJoins = TagJoins(db);
  @override
  final joinList = <Join>[];

  @override
  void createJoins(Set<IncludeOptions> includes) {
    if (includes.contains(IncludeOptions.items)) {
      joinList.addAll(itemJoins.joins(db.folders.id));
    }

    if (includes.contains(IncludeOptions.tags)) {
      joinList.addAll(tagJoins.joins(db.folders.id));
    }
  }

  @override
  List<FolderResult> buildRelations({
    required List<TypedResult?> rows,
    Set<IncludeOptions> includes = const {},
  }) {
    final folderMap = <String, FolderResult>{};

    for (final row in rows) {
      if (row == null) {
        continue;
      }

      final folder = row.readTable(db.folders);
      final folderId = folder.id;

      final folderResult = folderMap.putIfAbsent(
        folderId,
        () => FolderResult(folder: folder),
      );

      if (includes.contains(IncludeOptions.items)) {
        final item = itemJoins.readJoins(row);
        if (item != null) {
          folderResult.items.add(item);
        }
      }

      if (includes.contains(IncludeOptions.tags)) {
        final tag = tagJoins.readJoins(row);
        if (tag != null) {
          folderResult.tags.add(tag);
        }
      }
    }

    for (final result in folderMap.values) {
      result.items = result.items.toSet().toList();
      result.tags = result.tags.toSet().toList();
    }

    return folderMap.values.toList();
  }
}
