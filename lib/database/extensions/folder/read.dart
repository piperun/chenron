import 'package:chenron/database/database.dart';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

enum IncludeFolderData {
  all,
  items,
  tags,
}

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
  /// - `mode`: An optional `IncludeFolderData` enum value that determines which additional data (items, tags) to include in the returned `FolderObject` instances. Defaults to `IncludeFolderData.all`.
  ///
  /// Returns:
  /// A `Future<List<FolderObject>>` containing the requested folder data.
  Future<List<FolderObject>> getAllFolders(
      {IncludeFolderData mode = IncludeFolderData.all}) {
    Map<IncludeFolderData, List<Join<HasResultSet, dynamic>>> joins =
        _getJoins();
    var query = select(folders).join(joins[mode]!);

    return query.map((row) {
      final folder = row.readTable(folders);
      final folderTags = row.readTableOrNull(tags);
      final folderDocuments = row.readTableOrNull(documents);
      final folderLinks = row.readTableOrNull(links);

      return FolderObject(
          folder: folder,
          tags: folderTags,
          items: (links: folderLinks, documents: folderDocuments));
    }).get();
  }

  Future<FolderObject?> getFolder(String folderId,
      {IncludeFolderData mode = IncludeFolderData.all}) async {
    Map<IncludeFolderData, List<Join<HasResultSet, dynamic>>> joins =
        _getJoins();
    var query = (select(folders)..where((tbl) => tbl.id.equals(folderId)))
        .join(joins[mode]!);

    final result = query.map((row) {
      final folder = row.readTable(folders);
      final folderTags = row.readTableOrNull(tags);
      final folderLinks = row.readTableOrNull(links);
      final folderitems = row.readTableOrNull(items);

      return FolderObject(folder: folder, tags: folderTags, items: folderLinks);
    }).getSingleOrNull();

    final joinResults = query.map((row) {
      final folderTags = row.readTableOrNull(tags);
      final folderLinks = row.readTableOrNull(links);
      final folderitems = row.readTableOrNull(items);

      return (tags: folderTags, links: folderLinks);
    }).get();
    final test = await joinResults;
    return result;
  }

  Future<FolderObject?> getTest(String folderId,
      {IncludeFolderData mode = IncludeFolderData.all}) async {
    ContentQueries joins = _getJoins2(mode);
    FolderObject? folderObject;
    final folderQuery = await (select(folders)
          ..where((folder) => folder.id.equals(folderId)))
        .getSingleOrNull();
    if (folderQuery != null) {
      folderObject = FolderObject(folder: folderQuery);
      final contentQuery = (select(items).join(
        joins.items!,
      )..where(items.folderId.equals(folderId)));
      folderObject.items = await contentQuery.map((rows) {
        //TODO: Probably rewrite this so we add this to the FolderObject instead of returning it.
        final linkResult = rows.readTableOrNull(links);
        //final documentResult = rows.readTableOrNull(documents);
        return linkResult;
      }).get();
    }
    return folderObject;
  }

  Stream<FolderLink> watchTest(String folderId,
      {IncludeFolderData mode = IncludeFolderData.all}) {
    ContentQueries joins = _getJoins2(mode);

    final folderQuery = (select(folders)
          ..where((folder) => folder.id.equals(folderId)))
        .watchSingle();

    final folderStream = folderQuery;

    final contentQuery = (select(items).join(
      joins.items!,
    )..where(items.folderId.equals(folderId)));
    final contentStream = contentQuery.watch().map((rows) {
      //TODO: Probably rewrite this so we add this to the FolderObject instead of returning it.
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

  Stream<List<FolderObject>> watchFolder(String folderId,
      {IncludeFolderData mode = IncludeFolderData.all}) {
    Map<IncludeFolderData, List<Join<HasResultSet, dynamic>>> joins =
        _getJoins();
    var query = (select(folders)..where((tbl) => tbl.id.equals(folderId)))
        .join(joins[mode]!);

    return query.watch().map((rows) {
      return rows.map((row) {
        final folder = row.readTable(folders);
        final folderTags = row.readTableOrNull(tags);
        final folderitems = row.readTableOrNull(items);

        return FolderObject(
            folder: folder, tags: folderTags, items: folderitems);
      }).toList();
    });
  }

  Stream<List<FolderObject>> watchAllFolders(
      {IncludeFolderData mode = IncludeFolderData.all}) {
    Map<IncludeFolderData, List<Join<HasResultSet, dynamic>>> joins =
        _getJoins();
    var query = select(folders).join(joins[mode]!);

    return query.watch().map((rows) {
      return rows.map((row) {
        final folder = row.readTable(folders);
        final folderTags = row.readTableOrNull(tags);
        final folderitems = row.readTableOrNull(items);

        return FolderObject(
            folder: folder, tags: folderTags, items: folderitems);
      }).toList();
    });
  }

  ContentQueries _getJoins2(IncludeFolderData mode) {
    switch (mode) {
      case IncludeFolderData.all:
        return ContentQueries(tags: [
          leftOuterJoin(
            tags,
            tags.id.equalsExp(metadataRecords.metadataId),
          )
        ], items: [
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
        return ContentQueries(tags: [
          leftOuterJoin(
            tags,
            tags.id.equalsExp(metadataRecords.metadataId),
          )
        ]);
      case IncludeFolderData.items:
        return ContentQueries(items: [
          leftOuterJoin(
            links,
            links.id.equalsExp(items.itemId),
          ),
          leftOuterJoin(
            documents,
            documents.id.equalsExp(items.itemId),
          ),
        ]);
    }
  }

/*
 FIXME: This solution is most likely sufficient for now, however should the time come we might need to refractor this into a more scalable solution.
 This could be done by creating a class that serves as a factory for generating the joins we need, however as of right now it's not an needed.
*/
  Map<IncludeFolderData, List<Join<HasResultSet, dynamic>>> _getJoins() {
    return {
      IncludeFolderData.all: [
        leftOuterJoin(
          tags,
          tags.id.equalsExp(metadataRecords.metadataId),
        ),
        leftOuterJoin(items, items.folderId.equalsExp(folders.id)),
        leftOuterJoin(
          documents,
          documents.id.equalsExp(items.itemId),
        ),
        leftOuterJoin(
          links,
          links.id.equalsExp(items.itemId),
        )
      ],
      IncludeFolderData.tags: [
        leftOuterJoin(
            metadataRecords, metadataRecords.itemId.equalsExp(folders.id)),
        leftOuterJoin(
          tags,
          tags.id.equalsExp(metadataRecords.metadataId),
        )
      ],
      IncludeFolderData.items: [
        leftOuterJoin(items, items.folderId.equalsExp(folders.id)),
        leftOuterJoin(
          documents,
          documents.id.equalsExp(items.id),
        ),
        leftOuterJoin(
          links,
          links.id.equalsExp(items.id),
        )
      ]
    };
  }
}

class ContentQueries {
  List<Join<HasResultSet, dynamic>>? tags;
  List<Join<HasResultSet, dynamic>>? items;

  ContentQueries({
    this.tags = const [],
    this.items = const [],
  });
}

class FolderObject {
  final Folder folder;
  Tag? tags;
  dynamic items;

  FolderObject({required this.folder, this.tags, this.items = const []});
}
