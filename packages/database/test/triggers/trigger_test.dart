import 'package:database/main.dart';
import 'package:database/models/document_file_type.dart';
import 'package:database/models/folder.dart';
import 'package:database/models/item.dart';
import 'package:database/src/features/document/handlers/insert_handler.dart';
import 'package:database/src/features/folder/create.dart';
import 'package:flutter_test/flutter_test.dart' as matcher;
import 'package:flutter_test/flutter_test.dart';

import 'package:chenron_mockups/chenron_mockups.dart';
import 'package:drift/drift.dart';

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() {
    database = AppDatabase(
      databaseName: "test_db",
      setupOnInit: true,
      debugMode: true,
    );
  });

  tearDown(() async {
    await database.delete(database.folders).go();
    await database.delete(database.documents).go();
    await database.close();
  });

  group('Folder updatedAt Trigger', () {
    test('updatedAt changes automatically when folder is updated', () async {
      // Create a folder
      final folderDraft = FolderDraft(
        title: 'Test Folder',
        description: 'Testing triggers',
      );
      final result = await database.createFolder(folderInfo: folderDraft);

      // Get original folder
      final originalFolder = await (database.select(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId)))
          .getSingle();

      final originalUpdatedAt = originalFolder.updatedAt;

      // Wait to ensure timestamp differs
      await Future.delayed(const Duration(milliseconds: 1000));

      // Update the folder WITHOUT explicitly setting updatedAt
      await (database.update(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId)))
          .write(const FoldersCompanion(title: Value('Updated Title')));

      // Get updated folder
      final updatedFolder = await (database.select(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId)))
          .getSingle();

      // Verify updatedAt has changed
      expect(
          updatedFolder.updatedAt.isAfter(originalUpdatedAt), matcher.isTrue);
      expect(updatedFolder.title, equals('Updated Title'));
    });

    test('updatedAt does NOT change when explicitly set to old value',
        () async {
      // Create a folder
      final folderDraft = FolderDraft(
        title: 'Test Folder',
        description: 'Testing triggers',
      );
      final result = await database.createFolder(folderInfo: folderDraft);

      // Get original folder
      final originalFolder = await (database.select(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId)))
          .getSingle();

      final originalUpdatedAt = originalFolder.updatedAt;

      await Future.delayed(const Duration(milliseconds: 1000));

      // Update the folder while EXPLICITLY setting updatedAt to the old value
      // The trigger condition "WHEN NEW.updated_at = OLD.updated_at" should prevent update
      await (database.update(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId)))
          .write(FoldersCompanion(
        title: const Value('Explicitly Set Title'),
        updatedAt: Value(originalUpdatedAt), // Explicitly set to old value
      ));

      // Get updated folder
      final updatedFolder = await (database.select(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId)))
          .getSingle();

      // Verify updatedAt has stayed the same because we explicitly set it
      expect(updatedFolder.updatedAt, equals(originalUpdatedAt));
      expect(updatedFolder.title, equals('Explicitly Set Title'));
    });

    test('multiple updates increment updatedAt correctly', () async {
      final folderDraft = FolderDraft(
        title: 'Test Folder',
        description: 'Testing triggers',
      );
      final result = await database.createFolder(folderInfo: folderDraft);

      final folder1 = await (database.select(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId)))
          .getSingle();

      await Future.delayed(const Duration(milliseconds: 1000));

      await (database.update(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId)))
          .write(const FoldersCompanion(title: Value('Update 1')));

      final folder2 = await (database.select(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId)))
          .getSingle();

      await Future.delayed(const Duration(milliseconds: 1000));

      await (database.update(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId)))
          .write(const FoldersCompanion(title: Value('Update 2')));

      final folder3 = await (database.select(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId)))
          .getSingle();

      expect(folder2.updatedAt.isAfter(folder1.updatedAt), matcher.isTrue);
      expect(folder3.updatedAt.isAfter(folder2.updatedAt), matcher.isTrue);
    });
  });

  group('Document updatedAt Trigger', () {
    test('updatedAt changes automatically when document is updated', () async {
      final doc = FolderItem.document(
        title: 'Original Title',
        filePath: '/path/to/doc.pdf',
        fileType: DocumentFileType.pdf,
      ) as DocumentItem;

      late String docId;
      await database.batch((batch) {
        final results = database.insertDocuments(batch: batch, docs: [doc]);
        docId = results.first.documentId;
      });

      final originalDoc = await (database.select(database.documents)
            ..where((tbl) => tbl.id.equals(docId)))
          .getSingle();

      final originalUpdatedAt = originalDoc.updatedAt;

      await Future.delayed(const Duration(milliseconds: 1000));

      // Update without explicitly setting updatedAt
      await (database.update(database.documents)
            ..where((tbl) => tbl.id.equals(docId)))
          .write(const DocumentsCompanion(title: Value('New Title')));

      final updatedDoc = await (database.select(database.documents)
            ..where((tbl) => tbl.id.equals(docId)))
          .getSingle();

      expect(updatedDoc.updatedAt.isAfter(originalUpdatedAt), matcher.isTrue);
      expect(updatedDoc.title, equals('New Title'));
    });

    test('updatedAt does NOT change when explicitly set to a different value',
        () async {
      final doc = FolderItem.document(
        title: 'Original Title',
        filePath: '/path/to/doc.pdf',
        fileType: DocumentFileType.pdf,
      ) as DocumentItem;

      late String docId;
      await database.batch((batch) {
        final results = database.insertDocuments(batch: batch, docs: [doc]);
        docId = results.first.documentId;
      });

      final originalDoc = await (database.select(database.documents)
            ..where((tbl) => tbl.id.equals(docId)))
          .getSingle();

      final originalUpdatedAt = originalDoc.updatedAt;
      final manualUpdatedAt =
          originalUpdatedAt.subtract(const Duration(days: 1));

      await Future.delayed(const Duration(milliseconds: 1000));

      // Update while explicitly setting updatedAt to a DIFFERENT value
      // The trigger condition "WHEN NEW.updated_at = OLD.updated_at" should prevent update
      // because NEW (manualUpdatedAt) != OLD (originalUpdatedAt)
      await (database.update(database.documents)
            ..where((tbl) => tbl.id.equals(docId)))
          .write(DocumentsCompanion(
        title: const Value('Explicitly Set Title'),
        updatedAt: Value(manualUpdatedAt),
      ));

      final updatedDoc = await (database.select(database.documents)
            ..where((tbl) => tbl.id.equals(docId)))
          .getSingle();

      expect(updatedDoc.updatedAt, equals(manualUpdatedAt));
      expect(updatedDoc.title, equals('Explicitly Set Title'));
    });
  });
}
