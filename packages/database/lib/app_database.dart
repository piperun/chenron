import "package:database/schema/app_schema.dart";
import "package:database/src/core/initial_data/app_database.dart";
import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";
import "package:basedir/directory.dart";
import "dart:io";
import "package:path/path.dart" as path;
import "package:database/models/document_file_type.dart";

part "app_database.g.dart";

enum AppDataInclude { items, tags }

enum IdType { linkId, documentId, tagId, folderId }

typedef DeleteRelationRecord = ({String id, IdType idType});

@DriftDatabase(tables: [
  Folders,
  Links,
  Documents,
  Tags,
  Items,
  ItemTypes,
  MetadataRecords,
  MetadataTypes,
  Statistics,
  ActivityEvents,
  RecentAccess,
  WebMetadataEntries,
  BackgroundJobs,
])
class AppDatabase extends _$AppDatabase {
  static const int idLength = 30;
  final bool setupOnInit;
  final bool debugMode;
  AppDatabase({
    QueryExecutor? queryExecutor,
    String? databaseName,
    this.setupOnInit = false,
    String? customPath,
    this.debugMode = false,
  }) : super(queryExecutor ??
            _openConnection(
                databaseName: databaseName ?? "chenron",
                customPath: customPath,
                debugMode: debugMode));

  Future<void> setup() async {
    if (setupOnInit) {
      await setupEnumTypes();
    }
  }

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
        if (setupOnInit) {
          await setupEnumTypes();
        }
        // Create triggers for auto-updating timestamps on new databases
        await _createUpdateTriggers();
        // Create triggers for automatic activity tracking
        await _createActivityTriggers();
      },
      onUpgrade: (migrator, from, to) async {
        // Migration from v1 to v2: Add Statistics table and updatedAt columns
        if (from < 2) {
          // Add updatedAt to Folders
          // Add updatedAt to Folders
          await customStatement(
              "ALTER TABLE folders ADD COLUMN updated_at TEXT NOT NULL DEFAULT '1970-01-01T00:00:00Z'");
          await customStatement(
              "UPDATE folders SET updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')");

          // Add updatedAt to Documents
          await customStatement(
              "ALTER TABLE documents ADD COLUMN updated_at TEXT NOT NULL DEFAULT '1970-01-01T00:00:00Z'");
          await customStatement(
              "UPDATE documents SET updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')");

          // Create Statistics table
          await migrator.createTable(statistics);

          // Create triggers for auto-updating timestamps
          await _createUpdateTriggers();
        }

        // Migration from v2 to v3: Refactor Documents for file-based storage
        if (from < 3) {
          // Add new columns for file metadata
          await customStatement(
              'ALTER TABLE documents ADD COLUMN mime_type TEXT NOT NULL DEFAULT "text/markdown"');
          await customStatement(
              "ALTER TABLE documents ADD COLUMN file_size INTEGER");
          await customStatement(
              "ALTER TABLE documents ADD COLUMN checksum TEXT");

          // Migrate existing documents: move content from 'path' column to files
          final existingDocs = await customSelect(
            "SELECT id, title, path FROM documents",
            readsFrom: {documents},
          ).get();

          for (final row in existingDocs) {
            final docId = row.read<String>("id");
            final content = row.read<String>("path"); // Old content stored here
            final relativePath = "documents/$docId.md";

            // Write content to file
            final file = await _getDocumentFile(relativePath);
            await file.writeAsString(content);
            final size = await file.length();

            // Update database with file path
            await customStatement(
              "UPDATE documents SET path = ?, file_size = ? WHERE id = ?",
              [relativePath, size, docId],
            );
          }

          // Rename path column to file_path
          // SQLite doesn't support RENAME COLUMN before 3.25.0, so we recreate the table
          await customStatement("""
            CREATE TABLE documents_new (
              id TEXT PRIMARY KEY NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              title TEXT NOT NULL,
              file_path TEXT UNIQUE NOT NULL,
              mime_type TEXT NOT NULL,
              file_size INTEGER,
              checksum TEXT
            )
          """);

          await customStatement("""
            INSERT INTO documents_new (id, created_at, updated_at, title, file_path, mime_type, file_size, checksum)
            SELECT id, created_at, updated_at, title, path, mime_type, file_size, checksum
            FROM documents
          """);

          await customStatement("DROP TABLE documents");
          await customStatement(
              "ALTER TABLE documents_new RENAME TO documents");

          // Recreate index
          await customStatement(
              "CREATE INDEX document_title ON documents(title)");
        }

        // Migration from v3 to v4: Add color columns to folders and tags
        if (from < 4) {
          // Check if color column already exists in folders
          final foldersInfo = await customSelect(
            "PRAGMA table_info(folders)",
          ).get();
          final hasFoldersColor =
              foldersInfo.any((row) => row.read<String>("name") == "color");

          if (!hasFoldersColor) {
            await customStatement(
                "ALTER TABLE folders ADD COLUMN color INTEGER");
          }

          // Check if color column already exists in tags
          final tagsInfo = await customSelect(
            "PRAGMA table_info(tags)",
          ).get();
          final hasTagsColor =
              tagsInfo.any((row) => row.read<String>("name") == "color");

          if (!hasTagsColor) {
            await customStatement("ALTER TABLE tags ADD COLUMN color INTEGER");
          }
        }

        // Migration from v4 to v5: Replace mime_type with file_type enum
        if (from < 5) {
          // Check if documents table has the columns we expect
          final docsInfo = await customSelect(
            "PRAGMA table_info(documents)",
          ).get();

          final hasMimeType =
              docsInfo.any((row) => row.read<String>("name") == "mime_type");
          final hasFileType =
              docsInfo.any((row) => row.read<String>("name") == "file_type");

          // Only run migration if we have mime_type but not file_type
          if (hasMimeType && !hasFileType) {
            // First, add the new file_type column with a default value
            await customStatement(
                'ALTER TABLE documents ADD COLUMN file_type TEXT NOT NULL DEFAULT "markdown"');

            // Update existing documents: map mime_type to file_type
            await customStatement("""
              UPDATE documents
              SET file_type = CASE
                WHEN mime_type LIKE '%pdf%' THEN 'pdf'
                WHEN mime_type LIKE '%image%' THEN 'image'
                ELSE 'markdown'
              END
            """);

            // Now we need to recreate the table without mime_type column
            await customStatement("""
              CREATE TABLE documents_new (
                id TEXT PRIMARY KEY NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                title TEXT NOT NULL,
                file_path TEXT UNIQUE NOT NULL,
                file_type TEXT NOT NULL,
                file_size INTEGER,
                checksum TEXT
              )
            """);

            await customStatement("""
              INSERT INTO documents_new (id, created_at, updated_at, title, file_path, file_type, file_size, checksum)
              SELECT id, created_at, updated_at, title, file_path, file_type, file_size, checksum
              FROM documents
            """);

            await customStatement("DROP TABLE documents");
            await customStatement(
                "ALTER TABLE documents_new RENAME TO documents");

            // Recreate index
            await customStatement(
                "CREATE INDEX document_title ON documents(title)");
          } else if (!hasFileType) {
            // If we don't have file_type at all, just add it
            await customStatement(
                'ALTER TABLE documents ADD COLUMN file_type TEXT NOT NULL DEFAULT "markdown"');
          }
        }

        // Migration from v5 to v6: Add ActivityEvents and RecentAccess tables
        if (from < 6) {
          await migrator.createTable(activityEvents);
          await migrator.createTable(recentAccess);

          await customStatement(
              "CREATE INDEX idx_activity_events_occurred_at ON activity_events(occurred_at)");
          await customStatement(
              "CREATE INDEX idx_activity_events_entity ON activity_events(entity_type, entity_id)");
          await customStatement(
              "CREATE INDEX idx_recent_access_last ON recent_access(last_accessed_at DESC)");

          await _createActivityTriggers();
        }

        // Migration v6 to v7: Fix 0-based type_id values in items and
        // metadata_records. The relation_handler was inserting type.index
        // (0-based) instead of type.dbId (matching 1-based seed IDs).
        // All existing rows need incrementing: links (0->1), documents (1->2),
        // folders (2->3).
        if (from < 7) {
          await customStatement(
              "UPDATE items SET type_id = type_id + 1");
          await customStatement(
              "UPDATE metadata_records SET type_id = type_id + 1");
        }

        // Migration v7 to v8: The v7 migration only fixed type_id=0 (links)
        // on databases that already ran v7. This corrective migration sets
        // the correct type_id by joining against the actual entity tables,
        // so it's safe for both partially-migrated and fresh databases.
        if (from < 8) {
          await customStatement(
              "UPDATE items SET type_id = 1 WHERE id IN "
              "(SELECT i.id FROM items i INNER JOIN links l ON i.item_id = l.id)");
          await customStatement(
              "UPDATE items SET type_id = 2 WHERE id IN "
              "(SELECT i.id FROM items i INNER JOIN documents d ON i.item_id = d.id)");
          await customStatement(
              "UPDATE items SET type_id = 3 WHERE id IN "
              "(SELECT i.id FROM items i INNER JOIN folders f ON i.item_id = f.id)");
          await customStatement(
              "UPDATE metadata_records SET type_id = 1 WHERE id IN "
              "(SELECT mr.id FROM metadata_records mr INNER JOIN tags t ON mr.metadata_id = t.id)");
        }

        // Migration v8 to v9: Make the (folder_id, item_id) index unique to
        // prevent duplicate item-folder associations.
        if (from < 9) {
          // Deduplicate: keep earliest row per (folder_id, item_id)
          await customStatement("""
            DELETE FROM items WHERE id NOT IN (
              SELECT MIN(id) FROM items GROUP BY folder_id, item_id
            )
          """);
          // Replace non-unique index with unique one
          await customStatement(
              "DROP INDEX IF EXISTS items_folder_item_idx");
          await customStatement(
              "CREATE UNIQUE INDEX items_folder_item_idx ON items (folder_id, item_id)");
        }

        // Migration v9 to v10: Add web_metadata_entries table for
        // persistent metadata caching (replaces SharedPreferences).
        if (from < 10) {
          await migrator.createTable(webMetadataEntries);
        }

        // Migration v10 to v11: Add adaptive TTL columns to
        // web_metadata_entries for change-tracking and per-entry TTL.
        if (from < 11) {
          await customStatement(
            "ALTER TABLE web_metadata_entries ADD COLUMN consecutive_unchanged INTEGER NOT NULL DEFAULT 0",
          );
          await customStatement(
            "ALTER TABLE web_metadata_entries ADD COLUMN ttl_days INTEGER NOT NULL DEFAULT 7",
          );
        }

        // Migration v11 to v12: Add indexes on frequently queried columns.
        if (from < 12) {
          await customStatement(
            "CREATE INDEX IF NOT EXISTS metadata_records_item_idx ON metadata_records (item_id)",
          );
          await customStatement(
            "CREATE INDEX IF NOT EXISTS activity_events_occurred_idx ON activity_events (occurred_at)",
          );
        }

        // Migration v12 to v13: Add the background jobs queue table for
        // background archive (and later metadata) processing. Originally
        // named archive_jobs; renamed in v14. Users migrating directly from
        // v12 to v14+ get the new name from the start (skipping the rename
        // dance below).
        if (from < 13) {
          await migrator.createTable(backgroundJobs);
        }

        // Migration v13 to v14: Rename archive_jobs -> background_jobs and
        // make link_id nullable (so metadata fetches not tied to a specific
        // link can be logged). For users coming from v12 in one shot, the
        // v13 step already created background_jobs and this is a no-op.
        if (from < 14) {
          final legacy = await customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='archive_jobs'",
          ).get();
          if (legacy.isNotEmpty) {
            await customStatement(
                "DROP INDEX IF EXISTS archive_jobs_status_created_idx");
            await customStatement(
                "ALTER TABLE archive_jobs RENAME TO background_jobs_old");
            await migrator.createTable(backgroundJobs);
            await customStatement(
              "INSERT INTO background_jobs "
              "(id, link_id, url, service, status, result_url, error, attempts, created_at, updated_at) "
              "SELECT id, link_id, url, service, status, result_url, error, attempts, created_at, updated_at "
              "FROM background_jobs_old",
            );
            await customStatement("DROP TABLE background_jobs_old");
          }
        }
      },
    );
  }

  /// Helper to get document file for migration and file operations
  Future<File> _getDocumentFile(String relativePath) async {
    final baseDir = await getDefaultApplicationDirectory();
    final fullPath = path.join(baseDir.path, "data", relativePath);
    final file = File(fullPath);
    await file.parent.create(recursive: true);
    return file;
  }

  /// Creates SQLite triggers to automatically update the updatedAt timestamp
  Future<void> _createUpdateTriggers() async {
    // Trigger for Folders table
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS update_folders_timestamp
      AFTER UPDATE ON folders
      FOR EACH ROW
      WHEN NEW.updated_at = OLD.updated_at
      BEGIN
        UPDATE folders
        SET updated_at = (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
        WHERE id = NEW.id;
      END
    """);

    // Trigger for Documents table
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS update_documents_timestamp
      AFTER UPDATE ON documents
      FOR EACH ROW
      WHEN NEW.updated_at = OLD.updated_at
      BEGIN
        UPDATE documents
        SET updated_at = (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
        WHERE id = NEW.id;
      END
    """);
  }

  /// Creates SQLite triggers to automatically record activity events
  /// on INSERT and DELETE for links, documents, folders, and tags.
  Future<void> _createActivityTriggers() async {
    // Use hex(randomblob(15)) to generate a 30-char ID inside triggers
    const idExpr = "lower(hex(randomblob(15)))";

    // Links
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS track_link_created
      AFTER INSERT ON links
      BEGIN
        INSERT INTO activity_events (id, occurred_at, event_type, entity_type, entity_id)
        VALUES ($idExpr, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'), 'link_created', 'link', NEW.id);
      END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS track_link_deleted
      AFTER DELETE ON links
      BEGIN
        INSERT INTO activity_events (id, occurred_at, event_type, entity_type, entity_id)
        VALUES ($idExpr, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'), 'link_deleted', 'link', OLD.id);
      END
    """);

    // Documents
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS track_document_created
      AFTER INSERT ON documents
      BEGIN
        INSERT INTO activity_events (id, occurred_at, event_type, entity_type, entity_id)
        VALUES ($idExpr, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'), 'document_created', 'document', NEW.id);
      END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS track_document_deleted
      AFTER DELETE ON documents
      BEGIN
        INSERT INTO activity_events (id, occurred_at, event_type, entity_type, entity_id)
        VALUES ($idExpr, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'), 'document_deleted', 'document', OLD.id);
      END
    """);

    // Folders
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS track_folder_created
      AFTER INSERT ON folders
      BEGIN
        INSERT INTO activity_events (id, occurred_at, event_type, entity_type, entity_id)
        VALUES ($idExpr, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'), 'folder_created', 'folder', NEW.id);
      END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS track_folder_deleted
      AFTER DELETE ON folders
      BEGIN
        INSERT INTO activity_events (id, occurred_at, event_type, entity_type, entity_id)
        VALUES ($idExpr, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'), 'folder_deleted', 'folder', OLD.id);
      END
    """);

    // Tags
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS track_tag_created
      AFTER INSERT ON tags
      BEGIN
        INSERT INTO activity_events (id, occurred_at, event_type, entity_type, entity_id)
        VALUES ($idExpr, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'), 'tag_created', 'tag', NEW.id);
      END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS track_tag_deleted
      AFTER DELETE ON tags
      BEGIN
        INSERT INTO activity_events (id, occurred_at, event_type, entity_type, entity_id)
        VALUES ($idExpr, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'), 'tag_deleted', 'tag', OLD.id);
      END
    """);
  }

  static QueryExecutor _openConnection(
      {String databaseName = "chenron",
      String? customPath,
      bool debugMode = false}) {
    // In production, we use the default database path.
    // `driftDatabase` from `package:drift_flutter` stores the database in
    // `getApplicationDocumentsDirectory()`.
    Future<String> Function()? dbPath;
    if (debugMode) {
      dbPath = null;
    } else if (customPath != null) {
      dbPath = () async => customPath;
    } else {
      dbPath = () async => (await getDefaultApplicationDirectory()).path;
    }

    return driftDatabase(
        name: databaseName,
        native: DriftNativeOptions(
          databasePath: dbPath,
          setup: (db) {
            db.execute("PRAGMA journal_mode=WAL;");
          },
        ));
  }
}
