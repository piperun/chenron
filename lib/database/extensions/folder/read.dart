import 'package:chenron/data_struct/item.dart';
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
    FolderResult folderResult;

    final folderQuery = await (select(folders)
          ..where((folder) => folder.id.equals(folderId)))
        .getSingleOrNull();

    if (folderQuery == null) {
      return null;
    }
    folderResult = FolderResult(
      folder: folderQuery,
    );
    if (mode == IncludeFolderData.tags || mode == IncludeFolderData.all) {
      final query = await (select(metadataRecords).join([
        leftOuterJoin(
          tags,
          tags.id.equalsExp(metadataRecords.metadataId),
        ),
      ])
            ..where(metadataRecords.itemId.equals(folderId)))
          .get();
      folderResult.tags.addAll(_getTags(query));
    }
    if (mode == IncludeFolderData.items || mode == IncludeFolderData.all) {
      final query = await (select(items).join([
        leftOuterJoin(
          documents,
          documents.id.equalsExp(items.itemId),
        ),
        leftOuterJoin(
          links,
          links.id.equalsExp(items.itemId),
        )
      ])
            ..where(items.folderId.equals(folderId)))
          .get();
      folderResult.items.addAll(_getItems(query));
    }
    if (mode == IncludeFolderData.none) return folderResult;

    return folderResult;
  }

  Stream<FolderLink> watchTest(String folderId,
      {IncludeFolderData mode = IncludeFolderData.all}) {
    ContentJoins joins = ContentJoins(mode: mode);

    final folderQuery = (select(folders)
          ..where((folder) => folder.id.equals(folderId)))
        .watchSingle();

    final folderStream = folderQuery;

    final contentQuery = (select(items).join(
      joins.joins,
    )..where(items.folderId.equals(folderId)));
    final contentStream = contentQuery.watch().map((rows) {
      //TODO: Probably rewrite this so we add this to the FolderResult instead of returning it.
      return rows.map((row) {
        return row.readTable(links);
      }).toList();
      //final documentResult = rows.readTableOrNull(documents);
    });

    return Rx.combineLatest2(folderStream, contentStream,
        (Folder folderInfo, List<Link> folderItems) {
      return (folderInfo: folderInfo, folderItems: folderItems);
    });
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
    ContentJoins joins = ContentJoins(mode: mode);
    var query = select(folders).join(joins.joins);

    return query.watch().map((rows) {
      return rows.map((row) {
        final folder = row.readTable(folders);
        final folderTags = row.readTableOrNull(tags);

        return FolderResult(folder: folder);
      }).toList();
    });
  }

  List<Tag> _getTags(List<TypedResult> queryResults) {
    List<Tag> tagResults = [];
    for (final result in queryResults) {
      final tag = result.readTableOrNull(tags);
      if (tag != null) {
        tagResults.add(tag);
      }
    }
    return tagResults;
  }

  List<FolderItem> _getItems(List<TypedResult> queryResults) {
    List<FolderItem> folderItems = [];
    for (final result in queryResults) {
      final link = result.readTableOrNull(links);
      final document = result.readTableOrNull(documents);
      if (link != null) {
        folderItems.add(link.toFolderItem());
      }
      if (document != null) {
        folderItems.add(document.toFolderItem());
      }
    }
    return folderItems;
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
        // Keep the map empty
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
      final link = row.readTableOrNull(db.links);
      final document = row.readTableOrNull(db.documents);
      if (link != null) {
        return link.toFolderItem();
      }
      if (document != null) {
        return document.toFolderItem();
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
              final link = row.readTableOrNull(db.links);
              final document = row.readTableOrNull(db.documents);
              return link?.toFolderItem() ?? document?.toFolderItem();
            })
            .whereType<FolderItem>()
            .toList());
  }
}
