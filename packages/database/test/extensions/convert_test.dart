import 'package:flutter_test/flutter_test.dart';
import 'package:database/database.dart';
import 'package:database/extensions/convert.dart';
import 'package:database/models/item.dart';
import 'package:chenron_mockups/chenron_mockups.dart';

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
    await database.close();
  });

  group('ConvertLinkToItem Extension', () {
    test('toFolderItem() converts Link without tags', () {
      final link = Link(
        id: 'link123',
        path: 'https://example.com',
        createdAt: DateTime(2024, 1, 1),
      );

      final folderItem = link.toFolderItem('item456');

      expect(folderItem.id, equals('link123'));
      expect(folderItem.itemId, equals('item456'));
      expect(folderItem.type, equals(FolderItemType.link));
      expect(folderItem.tags, isEmpty);
      expect(folderItem, isA<LinkItem>());
      final linkItem = folderItem as LinkItem;
      expect(linkItem.createdAt, equals(DateTime(2024, 1, 1)));
      expect(linkItem.url, equals('https://example.com'));
    });

    test('toFolderItem() converts Link with tags', () {
      final link = Link(
        id: 'link123',
        path: 'https://flutter.dev',
        createdAt: DateTime(2024, 2, 1),
      );

      final tags = [
        Tag(id: 'tag1', name: 'flutter', createdAt: DateTime.now()),
        Tag(id: 'tag2', name: 'dart', createdAt: DateTime.now()),
      ];

      final folderItem = link.toFolderItem('item789', tags: tags);

      expect(folderItem.id, equals('link123'));
      expect(folderItem.itemId, equals('item789'));
      expect(folderItem.type, equals(FolderItemType.link));
      expect(folderItem.tags.length, equals(2));
      expect(folderItem.tags[0].id, equals('tag1'));
      expect(folderItem.tags[1].id, equals('tag2'));
    });

    test('toFolderItem() includes archive URLs in content', () {
      final link = Link(
        id: 'link123',
        path: 'https://example.com',
        createdAt: DateTime(2024, 1, 1),
        archiveOrgUrl: 'https://web.archive.org/example',
        archiveIsUrl: 'https://archive.is/example',
      );

      final folderItem = link.toFolderItem(null);

      expect(folderItem, isA<LinkItem>());
      final linkItem = folderItem as LinkItem;
      expect(linkItem.url, equals('https://example.com'));
      expect(linkItem.archiveOrg, equals('https://web.archive.org/example'));
      expect(linkItem.archiveIs, equals('https://archive.is/example'));
    });

    test('toFolderItem() handles null itemId', () {
      final link = Link(
        id: 'link123',
        path: 'https://example.com',
        createdAt: DateTime(2024, 1, 1),
      );

      final folderItem = link.toFolderItem(null);

      expect(folderItem.itemId, isNull);
    });
  });

  group('ConvertDocumentToItem Extension', () {
    test('toFolderItem() converts Document without tags', () {
      final document = Document(
        id: 'doc123',
        title: 'Test Document',
        filePath: 'documents/doc123.md',
        fileType: DocumentFileType.markdown,
        createdAt: DateTime(2024, 3, 1),
        updatedAt: DateTime(2024, 3, 1),
      );

      final folderItem = document.toFolderItem('item456');

      expect(folderItem.id, equals('doc123'));
      expect(folderItem.itemId, equals('item456'));
      expect(folderItem.type, equals(FolderItemType.document));
      expect(folderItem.tags, isEmpty);
      // Verify it's a document item
      expect(folderItem, isA<DocumentItem>());
      final docItem = folderItem as DocumentItem;
      expect(docItem.createdAt, equals(DateTime(2024, 3, 1)));
      expect(docItem.title, equals('Test Document'));
      expect(docItem.filePath, equals('documents/doc123.md'));
    });

    test('toFolderItem() converts Document with tags', () {
      final document = Document(
        id: 'doc123',
        title: 'Tagged Document',
        filePath: 'documents/doc123.md',
        fileType: DocumentFileType.markdown,
        createdAt: DateTime(2024, 4, 1),
        updatedAt: DateTime(2024, 4, 1),
      );

      final tags = [
        Tag(id: 'tag1', name: 'notes', createdAt: DateTime.now()),
        Tag(id: 'tag2', name: 'important', createdAt: DateTime.now()),
        Tag(id: 'tag3', name: 'work', createdAt: DateTime.now()),
      ];

      final folderItem = document.toFolderItem('item999', tags: tags);

      expect(folderItem.id, equals('doc123'));
      expect(folderItem.itemId, equals('item999'));
      expect(folderItem.type, equals(FolderItemType.document));
      expect(folderItem.tags.length, equals(3));
      expect(folderItem.tags.map((t) => t.name).toList(),
          equals(['notes', 'important', 'work']));
    });

    test('toFolderItem() handles null itemId for Document', () {
      final document = Document(
        id: 'doc123',
        title: 'Test',
        filePath: 'documents/doc123.md',
        fileType: DocumentFileType.markdown,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final folderItem = document.toFolderItem(null);

      expect(folderItem.itemId, isNull);
    });

    test('toFolderItem() preserves document structure in MapContent', () {
      final document = Document(
        id: 'doc456',
        title: 'Complex Title',
        filePath: 'documents/doc456.md',
        fileType: DocumentFileType.markdown,
        createdAt: DateTime(2024, 5, 1),
        updatedAt: DateTime(2024, 5, 1),
      );

      final folderItem = document.toFolderItem('item123');

      // Verify it's a document item
      expect(folderItem, isA<DocumentItem>());
      final docItem = folderItem as DocumentItem;
      expect(docItem.title, equals('Complex Title'));
      expect(docItem.filePath, equals('documents/doc456.md'));
    });
  });
}
