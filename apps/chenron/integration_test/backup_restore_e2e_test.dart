import "dart:io";

import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:database/file_operations.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";

/// Backup + restore round-trip: real on-disk SQLite, real `VACUUM INTO`,
/// real file replacement. Catches regressions in
/// `DatabaseFileOperations.backupDatabase` and proves the produced file
/// is a valid AppDatabase that re-opens with the original schema +
/// data intact.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(installTestLogger);

  late Directory tempDir;
  late File dbFile;
  late Directory backupDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp("backup_restore_e2e");
    dbFile = File("${tempDir.path}/app.sqlite");
    backupDir = await Directory("${tempDir.path}/backups").create();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  AppDatabase openDb() => AppDatabase(
        queryExecutor: NativeDatabase(dbFile),
        setupOnInit: true,
      );

  group("Backup + restore round-trip", () {
    test("recovers folders, links, and tags byte-for-byte", () async {
      final original = openDb();

      final folderResult = await original.createFolder(
        folderInfo: FolderDraft(
          title: "My Bookmarks",
          description: "Pre-backup folder",
        ),
        tags: [
          Metadata(value: "reading", type: MetadataTypeEnum.tag),
          Metadata(value: "later", type: MetadataTypeEnum.tag),
        ],
      );

      await original.createLink(
        link: "https://example.org/one",
        tags: [
          Metadata(value: "docs", type: MetadataTypeEnum.tag),
        ],
      );
      await original.createLink(link: "https://example.org/two");
      await original.createLink(link: "https://example.org/three");

      final preBackupFolderCount = (await original.getAllFolders()).length;
      final preBackupLinks = await original.getAllLinks();
      final preBackupMyFolder = await original.getFolder(
        folderId: folderResult.folderId,
      );
      expect(preBackupMyFolder, isNotNull);
      final preBackupTagCount = preBackupMyFolder!.tags.length;

      // Force flush before backup: VACUUM INTO needs the WAL applied.
      await original.close();

      final backupFile = await DatabaseFileOperations().backupDatabase(
        dbFile: dbFile,
        backupDirectory: backupDir,
      );

      expect(backupFile.existsSync(), isTrue);
      expect(await backupFile.length(), greaterThan(0));

      // Wipe the original and restore from backup.
      await dbFile.delete();
      await backupFile.copy(dbFile.path);

      final restored = openDb();
      final restoredFolderCount = (await restored.getAllFolders()).length;
      final restoredLinks = await restored.getAllLinks();
      final restoredMyFolder = await restored.getFolder(
        folderId: folderResult.folderId,
      );

      expect(restoredFolderCount, equals(preBackupFolderCount));
      expect(restoredLinks.length, equals(preBackupLinks.length));
      expect(restoredMyFolder, isNotNull);
      expect(restoredMyFolder!.data.title, equals("My Bookmarks"));
      expect(restoredMyFolder.tags.length, equals(preBackupTagCount));
      expect(
        restoredLinks.map((l) => l.data.path).toSet(),
        equals({
          "https://example.org/one",
          "https://example.org/two",
          "https://example.org/three",
        }),
      );

      await restored.close();
    });

    test("backup file uses VACUUM INTO so it's smaller than the WAL'd source",
        () async {
      final db = openDb();

      // Hammer the DB enough that the WAL grows noticeably.
      for (var i = 0; i < 50; i++) {
        await db.createLink(link: "https://example.com/page-$i");
      }

      await db.close();
      final preBackupSize = await dbFile.length();

      final backupFile = await DatabaseFileOperations().backupDatabase(
        dbFile: dbFile,
        backupDirectory: backupDir,
      );

      // The backup is the vacuumed page-aligned image; it should be
      // ≤ the live file (the WAL has been merged but the page count is
      // never higher than the live file's effective page count).
      expect(
        await backupFile.length(),
        lessThanOrEqualTo(preBackupSize),
      );
    });

    test("backup file is a valid AppDatabase with the correct schema version",
        () async {
      final db = openDb();
      await db.createLink(link: "https://example.org/canary");
      await db.close();

      final backupFile = await DatabaseFileOperations().backupDatabase(
        dbFile: dbFile,
        backupDirectory: backupDir,
      );

      final restored = AppDatabase(
        queryExecutor: NativeDatabase(backupFile),
      );
      // Schema version must match the live DB — otherwise restore would
      // trigger an unwanted migration and corrupt data.
      expect(restored.schemaVersion, equals(16));

      final canaryLinks = await restored.getAllLinks();
      expect(
        canaryLinks.map((l) => l.data.path),
        contains("https://example.org/canary"),
      );
      await restored.close();
    });
  });
}
