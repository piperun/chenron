import "package:database/database.dart";
import "package:database/main.dart";
import "folder_factory.dart";
import "package:drift/native.dart";

/// Mock database helper for testing
/// Uses Drift's in-memory database to provide full database functionality without file I/O
class MockDatabaseHelper {
  late AppDatabase database;
  bool _isSetup = false;

  /// Set up the in-memory database
  Future<void> setup({bool setupOnInit = true}) async {
    database = AppDatabase(
      queryExecutor: NativeDatabase.memory(),
      setupOnInit: setupOnInit,
    );

    if (setupOnInit) {
      await database.setup();
    }

    _isSetup = true;
  }

  /// Create a test folder in the database
  Future<String> createTestFolder({
    required String title,
    String description = "",
    List<String> tags = const [],
    List<FolderItem> items = const [],
  }) async {
    _ensureSetup();

    final folderData = FolderTestDataFactory.create(
      title: title,
      description: description,
      tagValues: tags,
      itemsData: items.map<Map<String, dynamic>>((item) {
        return item.map(
          link: (link) => {
            "type": "link",
            "content": link.url,
          },
          document: (doc) => {
            "type": "document",
            "content": {
              "title": doc.title,
              "body": doc.filePath,
            },
          },
          folder: (_) => {},
        );
      }).toList(),
    );

    final result = await database.createFolder(
      folderInfo: folderData.folder,
      tags: tags.isNotEmpty ? folderData.tags : null,
      items: items.isNotEmpty ? folderData.items : null,
    );

    return result.folderId;
  }

  /// Create a test link in the database
  Future<String> createTestLink({
    required String url,
    List<String> tags = const [],
  }) async {
    _ensureSetup();

    final result = await database.createLink(
      link: url,
      tags: tags.isNotEmpty
          ? tags
              .map((tag) => Metadata(type: MetadataTypeEnum.tag, value: tag))
              .toList()
          : null,
    );

    return result.linkId;
  }

  /// Get folder by ID with includes
  Future<FolderResult?> getFolder(String id) async {
    _ensureSetup();

    return await database.getFolder(
      folderId: id,
      includeOptions: const IncludeOptions({
        AppDataInclude.items,
        AppDataInclude.tags,
      }),
    );
  }

  /// Check if a folder exists
  Future<bool> folderExists(String id) async {
    _ensureSetup();

    final folders = database.folders;
    final folder = await (database.select(folders)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    return folder != null;
  }

  /// Check if a folder has a specific tag
  Future<bool> folderHasTag(String folderId, String tagName) async {
    _ensureSetup();

    // Get all metadata records for this folder
    final metadataRecordsTable = database.metadataRecords;
    final metadataRecords = await (database.select(metadataRecordsTable)
          ..where((tbl) => tbl.itemId.equals(folderId)))
        .get();

    // Get all tags
    final tagsTable = database.tags;
    final tags = await database.select(tagsTable).get();

    // Check if any metadata record matches the tag name
    for (final record in metadataRecords) {
      final matchingTag = tags.firstWhere(
        (t) => t.id == record.metadataId && t.name == tagName,
        orElse: () => tags.first, // dummy
      );
      if (matchingTag.name == tagName) return true;
    }

    return false;
  }

  /// Check if a folder has a specific item
  Future<bool> folderHasItem(String folderId, String itemId) async {
    _ensureSetup();

    final itemsTable = database.items;
    final items = await (database.select(itemsTable)
          ..where((tbl) => tbl.folderId.equals(folderId)))
        .get();

    return items.any((item) => item.itemId == itemId);
  }

  /// Get folder title by ID
  Future<String?> getFolderTitle(String id) async {
    _ensureSetup();

    final folders = database.folders;
    final folder = await (database.select(folders)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    return folder?.title;
  }

  /// Get folder description by ID
  Future<String?> getFolderDescription(String id) async {
    _ensureSetup();

    final folders = database.folders;
    final folder = await (database.select(folders)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    return folder?.description;
  }

  /// Get all tags for a folder
  Future<List<String>> getFolderTags(String folderId) async {
    _ensureSetup();

    final folderResult = await getFolder(folderId);
    if (folderResult == null) return [];

    return folderResult.tags.map((tag) => tag.name).toList();
  }

  /// Count items in a folder
  Future<int> countFolderItems(String folderId) async {
    _ensureSetup();

    final itemsTable = database.items;
    final items = await (database.select(itemsTable)
          ..where((tbl) => tbl.folderId.equals(folderId)))
        .get();

    return items.length;
  }

  /// Reset the database (clear all data)
  Future<void> reset() async {
    if (!_isSetup) return;

    // Delete all data from tables
    // Delete all data from tables
    final metadataRecords = database.metadataRecords;
    await database.delete(metadataRecords).go();
    final items = database.items;
    await database.delete(items).go();
    final folders = database.folders;
    await database.delete(folders).go();
    final links = database.links;
    await database.delete(links).go();
    final documents = database.documents;
    await database.delete(documents).go();
    final tags = database.tags;
    await database.delete(tags).go();
  }

  /// Dispose of the database
  Future<void> dispose() async {
    if (_isSetup) {
      await database.close();
      _isSetup = false;
    }
  }

  void _ensureSetup() {
    if (!_isSetup) {
      throw StateError(
        "MockDatabaseHelper not set up. Call setup() before using.",
      );
    }
  }
}
