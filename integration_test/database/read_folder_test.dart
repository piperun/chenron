import 'dart:async';

import 'package:chenron/data_struct/item.dart';
import 'package:chenron/database/extensions/folder/update.dart';
import 'package:chenron/test_lib/folder_factory.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder/read.dart';
import 'package:chenron/database/extensions/folder/create.dart';

void main() {
  late AppDatabase database;
  late FolderTestData activeFolder;
  late FolderTestData inactiveFolder;

  setUp(() async {
    database = AppDatabase(databaseName: "test_db");
    activeFolder = FolderTestDataFactory.createActiveFolder();
    inactiveFolder = FolderTestDataFactory.createInactiveFolder();

    await database.addFolder(
      folderInfo: activeFolder.folder,
      tags: activeFolder.tags,
      items: activeFolder.items,
    );

    await database.addFolder(
      folderInfo: inactiveFolder.folder,
      tags: inactiveFolder.tags,
      items: inactiveFolder.items,
    );
  });
  tearDown(() async {
    await database.delete(database.folders).go();
    await database.delete(database.items).go();
    await database.delete(database.metadataRecords).go();
    await database.delete(database.tags).go();
    await database.delete(database.links).go();
    await database.delete(database.documents).go();
    await database.close();
  });

  group('getFolder() Operations', () {
    test('returns null when folder is not found', () async {
      final result = await database.getFolder('non_existent_id');

      expect(result, isNull);
    });
    test('should get a single folder with no tags or items', () async {
      final retrievedFolder = await database.getFolder(activeFolder.folder.id,
          mode: IncludeFolderData.none);

      expect(retrievedFolder, isNotNull);
      expect(retrievedFolder!.folder.id, equals(activeFolder.folder.id));
      expect(retrievedFolder.folder.title, equals(activeFolder.folder.title));
      expect(retrievedFolder.folder.description,
          equals(activeFolder.folder.description));
    });

    test('should get folder with only tags', () async {
      final folderWithTags = await database.getFolder(activeFolder.folder.id,
          mode: IncludeFolderData.tags);

      expect(folderWithTags, isNotNull);
      expect(folderWithTags!.tags, isNotNull);
      expect(folderWithTags.tags.length, equals(activeFolder.tags.length));

      for (int i = 0; i < folderWithTags.tags.length; i++) {
        expect(folderWithTags.tags[i].name, equals(activeFolder.tags[i].value));
      }
    });
    test('should get folder with only items', () async {
      final folderWithItems = await database.getFolder(activeFolder.folder.id,
          mode: IncludeFolderData.items);

      expect(folderWithItems, isNotNull);
      expect(folderWithItems!.items, isNotNull);
      expect(folderWithItems.items.length, equals(activeFolder.items.length));

      expect(
          folderWithItems.items.any((item) => item.type == FolderItemType.link),
          isTrue);
      expect(
          folderWithItems.items
              .any((item) => item.type == FolderItemType.document),
          isTrue);
    });
    test('should get folder with both items and tags', () async {
      final folderWithAll = await database.getFolder(activeFolder.folder.id,
          mode: IncludeFolderData.all);

      expect(folderWithAll, isNotNull);
      expect(folderWithAll!.items, isNotNull);
      expect(folderWithAll.items.length, equals(activeFolder.items.length));
      expect(folderWithAll, isNotNull);
      expect(folderWithAll.tags, isNotNull);
      expect(folderWithAll.tags.length, equals(activeFolder.tags.length));

      for (int i = 0; i < folderWithAll.tags.length; i++) {
        expect(folderWithAll.tags[i].name, equals(activeFolder.tags[i].value));
      }

      expect(
          folderWithAll.items.any((item) => item.type == FolderItemType.link),
          isTrue);
      expect(
          folderWithAll.items
              .any((item) => item.type == FolderItemType.document),
          isTrue);
    });
  });

  group("getAllFolders() Operations", () {
    test('should get all folders with no items or tags', () async {
      final allFolders =
          await database.getAllFolders(mode: IncludeFolderData.none);

      expect(allFolders, isNotEmpty);
      for (var folder in allFolders) {
        expect(folder.folder.id, isNotNull);
        expect(folder.folder.title, isNotNull);
        expect(folder.folder.description, isNotNull);
        expect(folder.folder.createdAt, isNotNull);
        expect(folder.items, isEmpty);
        expect(folder.tags, isEmpty);
      }
    });
    test('should get all folders with only tags', () async {
      final allFolders =
          await database.getAllFolders(mode: IncludeFolderData.tags);

      expect(allFolders.length, equals(2));

      final testFolders = [activeFolder, inactiveFolder];

      for (int i = 0; i < allFolders.length; i++) {
        final retrievedFolder = allFolders[i];
        final expectedFolder = testFolders[i];

        expect(retrievedFolder.folder.id, equals(expectedFolder.folder.id));
        expect(
            retrievedFolder.folder.title, equals(expectedFolder.folder.title));
        expect(retrievedFolder.folder.description,
            equals(expectedFolder.folder.description));
        expect(retrievedFolder.folder.createdAt, isNotNull);
        expect(retrievedFolder.items, isEmpty);
        expect(retrievedFolder.tags, isNotEmpty);

        for (int j = 0; j < retrievedFolder.tags.length; j++) {
          expect(retrievedFolder.tags[j].name,
              equals(expectedFolder.tags[j].value));
        }
      }
    });
    test('should get all folders with only items', () async {
      final allFolders =
          await database.getAllFolders(mode: IncludeFolderData.items);

      expect(allFolders.length, equals(2));

      final testFolders = [activeFolder, inactiveFolder];

      for (int i = 0; i < allFolders.length; i++) {
        final retrievedFolder = allFolders[i];
        final expectedFolder = testFolders[i];

        expect(retrievedFolder.folder.id, equals(expectedFolder.folder.id));
        expect(
            retrievedFolder.folder.title, equals(expectedFolder.folder.title));
        expect(retrievedFolder.folder.description,
            equals(expectedFolder.folder.description));
        expect(retrievedFolder.folder.createdAt, isNotNull);
        expect(retrievedFolder.items, isNotEmpty);
        expect(retrievedFolder.tags, isEmpty);

        for (int j = 0; j < retrievedFolder.items.length; j++) {
          expect(retrievedFolder.items[j].content,
              equals(expectedFolder.items[j].content));
        }
      }
    });
    test('should get all folders with both items and tags', () async {
      final allFolders =
          await database.getAllFolders(mode: IncludeFolderData.all);

      expect(allFolders.length, equals(2));

      final testFolders = [activeFolder, inactiveFolder];

      for (int i = 0; i < allFolders.length; i++) {
        final retrievedFolder = allFolders[i];
        final expectedFolder = testFolders[i];

        expect(retrievedFolder.folder.id, equals(expectedFolder.folder.id));
        expect(
            retrievedFolder.folder.title, equals(expectedFolder.folder.title));
        expect(retrievedFolder.folder.description,
            equals(expectedFolder.folder.description));
        expect(retrievedFolder.folder.createdAt, isNotNull);
        expect(retrievedFolder.items, isNotEmpty);
        expect(retrievedFolder.tags, isNotEmpty);

        for (int j = 0; j < retrievedFolder.tags.length; j++) {
          expect(retrievedFolder.tags[j].name,
              equals(expectedFolder.tags[j].value));
        }

        for (int n = 0; n < retrievedFolder.items.length; n++) {
          if (retrievedFolder.items[n] is Link &&
              expectedFolder.items[n] is Link) {
            expect((retrievedFolder.items[n] as Link).content,
                equals((expectedFolder.items[n] as Link).content));
          }
          if (retrievedFolder.items[n] is Document &&
              expectedFolder.items[n] is Document) {
            expect((retrievedFolder.items[n] as Document).content,
                equals((expectedFolder.items[n] as Document).content));
          }
        }
      }
    });
  });
  group("watchFolder() Operations", () {
    test("emits null when folder is not found", () async {
      final stream = database.watchFolder(folderId: 'non_existent_id');
      expect(stream, emits(null));
    });
    test("should watch a single folder with no tags or items", () async {
      final stream = database.watchFolder(
          folderId: activeFolder.folder.id, mode: IncludeFolderData.none);

      expect(
          stream,
          emitsThrough(predicate<FolderResult>((result) =>
              result.folder.id == activeFolder.folder.id &&
              result.folder.title == activeFolder.folder.title &&
              result.folder.description == activeFolder.folder.description &&
              result.tags.isEmpty &&
              result.items.isEmpty)));
    });

    test("should watch folder with only tags", () async {
      final stream = database.watchFolder(
          folderId: activeFolder.folder.id, mode: IncludeFolderData.tags);

      expect(
          stream,
          emitsThrough(predicate<FolderResult>((result) =>
              result.tags.length == activeFolder.tags.length &&
              result.tags.every(
                  (tag) => activeFolder.tags.any((t) => t.value == tag.name)) &&
              result.items.isEmpty)));
    });

    test("should watch folder with only items", () async {
      final stream = database.watchFolder(
          folderId: activeFolder.folder.id, mode: IncludeFolderData.items);

      expect(
          stream,
          emitsThrough(predicate<FolderResult>((result) =>
              result.items.length == activeFolder.items.length &&
              result.items.any((item) => item.type == FolderItemType.link) &&
              result.items
                  .any((item) => item.type == FolderItemType.document) &&
              result.tags.isEmpty)));
    });

    test("should watch folder with both items and tags", () async {
      final stream = database.watchFolder(
          folderId: activeFolder.folder.id, mode: IncludeFolderData.all);

      expect(
          stream,
          emitsThrough(predicate<FolderResult>((result) =>
              result.tags.length == activeFolder.tags.length &&
              result.tags.every(
                  (tag) => activeFolder.tags.any((t) => t.value == tag.name)) &&
              result.items.length == activeFolder.items.length &&
              result.items.any((item) => item.type == FolderItemType.link) &&
              result.items
                  .any((item) => item.type == FolderItemType.document))));
    });
  });
  group("watchAllFolders() Operations", () {});
}
