import "package:database/main.dart";
import "package:database/models/db_result.dart";
import "package:database/models/item.dart";
import "package:drift/drift.dart";
import "package:database/src/core/builders/result_builder.dart";

class TagResultBuilder implements ResultBuilder<TagResult> {
  final Tag _tag;
  final Set<String> _relatedFolderIds = {};
  final Set<String> _relatedLinkIds = {};
  final Set<String> _relatedDocumentIds = {};
  final AppDatabase _db;

  TagResultBuilder(this._tag, this._db);

  @override
  String get entityId => _tag.id;

  @override
  void processRow(TypedResult row, Set<Enum> includeOptions) {
    // For tags, we collect related entity IDs from the metadata records
    final metadataRecord = row.readTableOrNull(_db.metadataRecords);
    if (metadataRecord != null) {
      final itemId = metadataRecord.itemId;

      // Need to determine the type of the item to add to the right collection
      final item = row.readTableOrNull(_db.items);
      if (item != null) {
        if (item.typeId == FolderItemType.link.dbId) {
          _relatedLinkIds.add(itemId);
        } else if (item.typeId == FolderItemType.document.dbId) {
          _relatedDocumentIds.add(itemId);
        } else {
          _relatedFolderIds.add(itemId);
        }
      }
    }
  }

  @override
  TagResult build() {
    return TagResult(
      data: _tag,
      relatedFolderIds:
          _relatedFolderIds.isEmpty ? null : _relatedFolderIds.toList(),
      relatedLinkIds: _relatedLinkIds.isEmpty ? null : _relatedLinkIds.toList(),
      relatedDocumentIds:
          _relatedDocumentIds.isEmpty ? null : _relatedDocumentIds.toList(),
    );
  }
}
