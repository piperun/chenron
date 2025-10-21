import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/create.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/link/create.dart";
import "package:chenron/models/db_result.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/utils/test_lib/folder_factory.dart";
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
        if (item.path is StringContent) {
          return {
            "type": item.type.name,
            "content": (item.path as StringContent).value,
          };
        } else if (item.path is MapContent) {
          return {
            "type": item.type.name,
            "content": (item.path as MapContent).value,
          };
        }
        return {};
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
    String title = "",
    List<String> tags = const [],
  }) async {
    _ensureSetup();

    final result = await database.createLink(
      link: url,
      tags: tags.isNotEmpty
          ? tags.map((tag) => Metadata(type: MetadataTypeEnum.tag, value: tag)).toList()
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
    
    final folder = await (database.select(database.folders)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    
    return folder != null;
  }

  /// Check if a folder has a specific tag
  Future<bool> folderHasTag(String folderId, String tagName) async {
    _ensureSetup();
    
    // Get all metadata records for this folder
    final metadataRecords = await (database.select(database.metadataRecords)
          ..where((tbl) => tbl.itemId.equals(folderId)))
        .get();
    
    // Get all tags
    final tags = await database.select(database.tags).get();
    
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
    
    final items = await (database.select(database.items)
          ..where((tbl) => tbl.folderId.equals(folderId)))
        .get();
    
    return items.any((item) => item.itemId == itemId);
  }

  /// Get folder title by ID
  Future<String?> getFolderTitle(String id) async {
    _ensureSetup();
    
    final folder = await (database.select(database.folders)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    
    return folder?.title;
  }

  /// Get folder description by ID
  Future<String?> getFolderDescription(String id) async {
    _ensureSetup();
    
    final folder = await (database.select(database.folders)
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
    
    final items = await (database.select(database.items)
          ..where((tbl) => tbl.folderId.equals(folderId)))
        .get();
    
    return items.length;
  }

  /// Reset the database (clear all data)
  Future<void> reset() async {
    if (!_isSetup) return;
    
    // Delete all data from tables
    await database.delete(database.metadataRecords).go();
    await database.delete(database.items).go();
    await database.delete(database.folders).go();
    await database.delete(database.links).go();
    await database.delete(database.documents).go();
    await database.delete(database.tags).go();
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
