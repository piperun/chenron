import "package:chenron/database/extensions/convert.dart";
import "package:drift/drift.dart";
import "package:chenron/database/actions/builders/result_builder.dart";
import "package:chenron/database/database.dart";
import "package:chenron/models/db_result.dart";
import "package:chenron/models/item.dart";

class FolderResultBuilder implements ResultBuilder<FolderResult> {
  final Folder _folder;
  final List<Tag> _tags = [];
  final Map<String, List<Tag>> _itemTags = {};
  final Map<String, Item> _items = {};
  final Map<String, Link> _links = {};
  final Map<String, Document> _documents = {};
  final AppDatabase _db;
  late final $MetadataRecordsTable _linkMetadata;
  late final $TagsTable _linkTags;

  FolderResultBuilder(this._folder, this._db) {
    _linkMetadata = _db.metadataRecords.createAlias("link_metadata");
    _linkTags = _db.tags.createAlias("link_tags");
  }

  @override
  String get entityId => _folder.id;

  @override
  void processRow(TypedResult row, Set<Enum> includeOptions) {
    if (includeOptions.contains(AppDataInclude.tags)) {
      final tag = row.readTableOrNull(_db.tags);
      if (tag != null && !_tags.any((t) => t.id == tag.id)) {
        _tags.add(tag);
      }
    }

    if (includeOptions.contains(AppDataInclude.items)) {
      final item = row.readTableOrNull(_db.items);
      if (item != null) {
        // Store the item
        if (!_items.containsKey(item.id)) {
          _items[item.id] = item;
        }

        // Store link or document data
        if (item.typeId == FolderItemType.link.index) {
          final link = row.readTableOrNull(_db.links);
          if (link != null && !_links.containsKey(link.id)) {
            _links[link.id] = link;
          }
        } else if (item.typeId == FolderItemType.document.index) {
          final doc = row.readTableOrNull(_db.documents);
          if (doc != null && !_documents.containsKey(doc.id)) {
            _documents[doc.id] = doc;
          }
        }

        // Collect tags from source link/document (using aliased tables)
        final linkMetadata = row.readTableOrNull(_linkMetadata);
        final linkTag = row.readTableOrNull(_linkTags);
        if (linkMetadata != null && linkTag != null) {
          _itemTags.putIfAbsent(item.id, () => []);
          if (!_itemTags[item.id]!.any((t) => t.id == linkTag.id)) {
            _itemTags[item.id]!.add(linkTag);
          }
        }
      }
    }
  }

  @override
  FolderResult build() {
    final folderItems = <FolderItem>[];

    for (final entry in _items.entries) {
      final itemId = entry.key;
      final item = entry.value;
      final itemTagsList = _itemTags[itemId] ?? [];

      FolderItem? folderItem;
      if (item.typeId == FolderItemType.link.index) {
        final link = _links[item.itemId];
        if (link != null) {
          folderItem = link.toFolderItem(itemId, tags: itemTagsList);
        }
      } else if (item.typeId == FolderItemType.document.index) {
        final doc = _documents[item.itemId];
        if (doc != null) {
          folderItem = doc.toFolderItem(itemId, tags: itemTagsList);
        }
      }

      if (folderItem != null) {
        folderItems.add(folderItem);
      }
    }

    return FolderResult(
      data: _folder,
      tags: _tags,
      items: folderItems,
    );
  }
}
