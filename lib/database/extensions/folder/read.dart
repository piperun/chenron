import 'package:chenron/models/item.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/convert.dart';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

enum IncludeFolderData { all, items, tags, none }

typedef FolderLink = ({
  Folder folderInfo,
  List<Link> folderItems,
});

extension FolderReadExtensions on AppDatabase {
  /// Retrieves a list of all folders from the database, with optional inclusion of folder items and tags.
  ///
  /// This method uses the `_getJoins()` function to construct the necessary database joins based on the specified `IncludeFolderData` mode.
  ///
  /// Parameters:
  /// - `mode`: An optional `IncludeFolderData` enum value that determines which additional data (items, tags) to include in the returned `FolderResult` instances. Defaults to `IncludeFolderData.all`.
  ///
  /// Returns:
  /// A `Future<List<FolderResult>>` containing the requested folder data.
  ///

  Future<FolderResult?> getFolder(String folderId,
      {IncludeFolderData mode = IncludeFolderData.all}) async {
    return FolderQueryBuilder(db: this, folderId: folderId, mode: mode)
        .fetchSingle();
  }

  Future<List<FolderResult>> getAllFolders(
      {IncludeFolderData mode = IncludeFolderData.all}) {
    return FolderQueryBuilder(db: this, mode: mode).fetchAll();
  }

  Stream<FolderResult> watchFolder(
      {folderId, IncludeFolderData mode = IncludeFolderData.all}) {
    return FolderQueryBuilder(folderId: folderId, db: this, mode: mode)
        .watchSingle();
  }

  Stream<List<FolderResult>> watchAllFolders(
      {IncludeFolderData mode = IncludeFolderData.all}) {
    return FolderQueryBuilder(db: this, mode: mode).watchAll();
  }
}

class ContentJoins extends AppDatabase {
  IncludeFolderData mode;
  List<Join<HasResultSet, dynamic>>? joinTags;
  List<Join<HasResultSet, dynamic>>? joinItems;
  final List<Join<HasResultSet, dynamic>> joins = [];

  ContentJoins({
    required this.mode,
  }) {
    switch (mode) {
      case IncludeFolderData.all:
        joins.addAll([
          leftOuterJoin(
              metadataRecords, metadataRecords.itemId.equalsExp(folders.id)),
          leftOuterJoin(
            items,
            items.folderId.equalsExp(items.folderId),
          ),
          innerJoin(
            tags,
            tags.id.equalsExp(metadataRecords.metadataId),
          ),
          leftOuterJoin(
            links,
            links.id.equalsExp(items.itemId),
          ),
          leftOuterJoin(
            documents,
            documents.id.equalsExp(items.itemId),
          ),
        ]);
      case IncludeFolderData.tags:
        joins.addAll([
          leftOuterJoin(
              metadataRecords, metadataRecords.itemId.equalsExp(folders.id)),
          leftOuterJoin(tags, tags.id.equalsExp(metadataRecords.metadataId)),
        ]);
      case IncludeFolderData.items:
        joins.addAll([
          leftOuterJoin(
            items,
            items.id.equalsExp(items.folderId),
          ),
          leftOuterJoin(
            links,
            links.id.equalsExp(items.itemId),
          ),
          leftOuterJoin(
            documents,
            documents.id.equalsExp(items.itemId),
          ),
        ]);
      case IncludeFolderData.none:
        return;
    }
  }

  void getJoins() {}
}

class FolderResult {
  final Folder folder;
  List<Tag> tags = [];
  List<FolderItem> items = [];

  FolderResult({required this.folder});
}

class FolderJoins {
  final IncludeFolderData mode;
  late Map<String, dynamic> _dataMap;

  FolderJoins(this.mode) {
    _initializeDataMap();
  }

  void _initializeDataMap() {
    _dataMap = {};
    switch (mode) {
      case IncludeFolderData.all:
        _dataMap['tags'] = [];
        _dataMap['items'] = [];
        break;
      case IncludeFolderData.tags:
        _dataMap['tags'] = [];
        break;
      case IncludeFolderData.items:
        _dataMap['items'] = [];
        break;
      case IncludeFolderData.none:
        break;
    }
  }

  void addTags(List<Tag> tags) {
    if (_dataMap.containsKey('tags')) {
      _dataMap['tags'].addAll(tags);
    }
  }

  void addItems(List<FolderItem> items) {
    if (_dataMap.containsKey('items')) {
      _dataMap['items'].addAll(items);
    }
  }

  Map<String, dynamic> get data => Map.unmodifiable(_dataMap);

  bool get includeTags => _dataMap.containsKey('tags');
  bool get includeItems => _dataMap.containsKey('items');
}

class FolderQueryBuilder {
  final AppDatabase db;
  final IncludeFolderData mode;
  final String? folderId;

  FolderQueryBuilder({required this.db, this.folderId, required this.mode});
  Future<List<FolderResult>> fetchAll() async {
    final folders = await _getAllFolders();
    final results = <FolderResult>[];

    for (final folder in folders) {
      final result = FolderResult(folder: folder);
      if (mode == IncludeFolderData.all || mode == IncludeFolderData.tags) {
        result.tags = await _getTags(folder.id);
      }
      if (mode == IncludeFolderData.all || mode == IncludeFolderData.items) {
        result.items = await _getItems(folder.id);
      }
      results.add(result);
    }

    return results;
  }

  Future<FolderResult> fetchSingle() async {
    if (folderId == null) {
      throw Exception('Folder id is null');
    }
    final folder = await _getFolder(folderId!);
    final result = FolderResult(folder: folder);

    if (mode == IncludeFolderData.all || mode == IncludeFolderData.tags) {
      result.tags = await _getTags(folder.id);
    }

    if (mode == IncludeFolderData.all || mode == IncludeFolderData.items) {
      final items = await _getItems(folder.id);
      result.items = items;
    }

    return result;
  }

  Stream<FolderResult> watchSingle() {
    if (folderId == null) {
      throw ArgumentError(
          'folderId must be provided for watching a single folder');
    }

    final folderStream = (db.select(db.folders)
          ..where((f) => f.id.equals(folderId!)))
        .watchSingle();

    final tagsStream =
        mode == IncludeFolderData.all || mode == IncludeFolderData.tags
            ? _watchTags(folderId!)
            : Stream.value(<Tag>[]);

    final itemsStream =
        mode == IncludeFolderData.all || mode == IncludeFolderData.items
            ? _watchItems(folderId!)
            : Stream.value(<FolderItem>[]);

    return Rx.combineLatest3(
      folderStream,
      tagsStream,
      itemsStream,
      (Folder folder, List<Tag> tags, List<FolderItem> items) {
        final result = FolderResult(folder: folder);
        result.tags = tags;
        result.items = items;
        return result;
      },
    );
  }

  Stream<List<FolderResult>> watchAll() {
    final foldersStream = db.select(db.folders).watch();

    return foldersStream.switchMap((folders) {
      final folderStreams = folders.map((folder) {
        final tagsStream =
            mode == IncludeFolderData.all || mode == IncludeFolderData.tags
                ? _watchTags(folder.id)
                : Stream.value(<Tag>[]);

        final itemsStream =
            mode == IncludeFolderData.all || mode == IncludeFolderData.items
                ? _watchItems(folder.id)
                : Stream.value(<FolderItem>[]);

        return Rx.combineLatest3(
          Stream.value(folder),
          tagsStream,
          itemsStream,
          (Folder f, List<Tag> tags, List<FolderItem> items) {
            final result = FolderResult(folder: f);
            result.tags = tags;
            result.items = items;
            return result;
          },
        );
      });

      return Rx.combineLatestList(folderStreams);
    });
  }

  Future<Folder> _getFolder(String folderId) {
    return (db.select(db.folders)..where((f) => f.id.equals(folderId)))
        .getSingle();
  }

  Future<List<Folder>> _getAllFolders() {
    return db.select(db.folders).get();
  }

  Future<List<Tag>> _getTags(String folderId) {
    final rows = (db.select(db.metadataRecords).join([
      leftOuterJoin(
          db.tags, db.tags.id.equalsExp(db.metadataRecords.metadataId)),
    ])
          ..where(db.metadataRecords.itemId.equals(folderId)))
        .map((row) {
      final tag = row.readTable(db.tags);
      return tag;
    }).get();

    return rows.then((tags) => tags.whereType<Tag>().toList());
  }

  Future<List<FolderItem>> _getItems(String folderId) {
    final rows = (db.select(db.items).join([
      leftOuterJoin(db.links, db.links.id.equalsExp(db.items.itemId)),
      leftOuterJoin(db.documents, db.documents.id.equalsExp(db.items.itemId)),
    ])
          ..where(db.items.folderId.equals(folderId)))
        .map((row) {
      final item = row.readTableOrNull(db.items);
      final link = row.readTableOrNull(db.links);
      final document = row.readTableOrNull(db.documents);
      if (link != null) {
        return link.toFolderItem(item?.id);
      }
      if (document != null) {
        return document.toFolderItem(item?.id);
      }
    }).get();
    return rows.then((items) => items.whereType<FolderItem>().toList());
  }

  Stream<List<Tag>> _watchTags(String folderId) {
    return (db.select(db.metadataRecords).join([
      leftOuterJoin(
          db.tags, db.tags.id.equalsExp(db.metadataRecords.metadataId)),
    ])
          ..where(db.metadataRecords.itemId.equals(folderId)))
        .watch()
        .map((rows) => rows.map((row) => row.readTable(db.tags)).toList());
  }

  Stream<List<FolderItem>> _watchItems(String folderId) {
    return (db.select(db.items).join([
      leftOuterJoin(db.links, db.links.id.equalsExp(db.items.itemId)),
      leftOuterJoin(db.documents, db.documents.id.equalsExp(db.items.itemId)),
    ])
          ..where(db.items.folderId.equals(folderId)))
        .watch()
        .map((rows) => rows
            .map((row) {
              final item = row.readTableOrNull(db.items);
              final link = row.readTableOrNull(db.links);
              final document = row.readTableOrNull(db.documents);
              return link?.toFolderItem(item?.id) ??
                  document?.toFolderItem(item?.id);
            })
            .whereType<FolderItem>()
            .toList());
  }
}
