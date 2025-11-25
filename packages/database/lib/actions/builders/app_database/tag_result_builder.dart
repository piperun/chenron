import "package:database/models/item.dart" show FolderItemType;
import "package:drift/drift.dart";
import "package:database/actions/builders/result_builder.dart";
import "package:database/database.dart";
import "package:database/models/db_result.dart";

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
        if (item.typeId == FolderItemType.link.index) {
          _relatedLinkIds.add(itemId);
        } else if (item.typeId == FolderItemType.document.index) {
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
      name: _tag.name,
      relatedFolderIds:
          _relatedFolderIds.isEmpty ? null : _relatedFolderIds.toList(),
      relatedLinkIds: _relatedLinkIds.isEmpty ? null : _relatedLinkIds.toList(),
      relatedDocumentIds:
          _relatedDocumentIds.isEmpty ? null : _relatedDocumentIds.toList(),
    );
  }
}


