import "package:database/main.dart";
import "package:database/models/db_result.dart";
import "package:database/models/item.dart";
import "package:database/src/core/convert.dart";
import "package:drift/drift.dart";
import "package:database/src/core/builders/result_builder.dart";

class FolderResultBuilder implements ResultBuilder<FolderResult> {
  final Folder _folder;
  final List<Tag> _tags = [];
  final Map<String, List<Tag>> _itemTags = {};
  final Map<String, Item> _items = {};
  final Map<String, Link> _links = {};
  final Map<String, Document> _documents = {};
  final Map<String, Folder> _folders = {};
  final AppDatabase _db;
  late final $MetadataRecordsTable _linkMetadata;
  late final $TagsTable _linkTags;
  late final $FoldersTable _nestedFolders;

  FolderResultBuilder(this._folder, this._db) {
    _linkMetadata = _db.metadataRecords.createAlias("link_metadata");
    _linkTags = _db.tags.createAlias("link_tags");
    _nestedFolders = _db.folders.createAlias("nested_folders");
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

        // Store link, document, or nested folder data
        if (item.typeId == FolderItemType.link.dbId) {
          final link = row.readTableOrNull(_db.links);
          if (link != null && !_links.containsKey(link.id)) {
            _links[link.id] = link;
          }
        } else if (item.typeId == FolderItemType.document.dbId) {
          final doc = row.readTableOrNull(_db.documents);
          if (doc != null && !_documents.containsKey(doc.id)) {
            _documents[doc.id] = doc;
          }
        } else if (item.typeId == FolderItemType.folder.dbId) {
          final folder = row.readTableOrNull(_nestedFolders);
          if (folder != null && !_folders.containsKey(folder.id)) {
            _folders[folder.id] = folder;
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
      if (item.typeId == FolderItemType.link.dbId) {
        final link = _links[item.itemId];
        if (link != null) {
          folderItem = link.toFolderItem(itemId, tags: itemTagsList);
        }
      } else if (item.typeId == FolderItemType.document.dbId) {
        final doc = _documents[item.itemId];
        if (doc != null) {
          folderItem = doc.toFolderItem(itemId, tags: itemTagsList);
        }
      } else if (item.typeId == FolderItemType.folder.dbId) {
        final folder = _folders[item.itemId];
        if (folder != null) {
          folderItem = folder.toFolderItem(itemId, tags: itemTagsList);
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
