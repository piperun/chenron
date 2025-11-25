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
      expect(folderItem.createdAt, equals(DateTime(2024, 1, 1)));

      // Verify path is StringContent
      expect(folderItem.path, isA<StringContent>());
      final path = folderItem.path as StringContent;
      expect(path.value, equals('https://example.com'));
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

      final path = folderItem.path as StringContent;
      expect(path.value, equals('https://example.com'));
      expect(path.archiveOrg, equals('https://web.archive.org/example'));
      expect(path.archiveIs, equals('https://archive.is/example'));
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
        path: 'This is the body content',
        createdAt: DateTime(2024, 3, 1),
      );

      final folderItem = document.toFolderItem('item456');

      expect(folderItem.id, equals('doc123'));
      expect(folderItem.itemId, equals('item456'));
      expect(folderItem.type, equals(FolderItemType.document));
      expect(folderItem.tags, isEmpty);
      expect(folderItem.createdAt, equals(DateTime(2024, 3, 1)));

      // Verify path is MapContent
      expect(folderItem.path, isA<MapContent>());
      final path = folderItem.path as MapContent;
      expect(path.value['title'], equals('Test Document'));
      expect(path.value['body'], equals('This is the body content'));
    });

    test('toFolderItem() converts Document with tags', () {
      final document = Document(
        id: 'doc123',
        title: 'Tagged Document',
        path: 'Content here',
        createdAt: DateTime(2024, 4, 1),
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
        path: 'Content',
        createdAt: DateTime(2024, 1, 1),
      );

      final folderItem = document.toFolderItem(null);

      expect(folderItem.itemId, isNull);
    });

    test('toFolderItem() preserves document structure in MapContent', () {
      final document = Document(
        id: 'doc456',
        title: 'Complex Title',
        path: 'Complex body with\nmultiple lines\nand special chars: @#\$%',
        createdAt: DateTime(2024, 5, 1),
      );

      final folderItem = document.toFolderItem('item123');

      final path = folderItem.path as MapContent;
      expect(path.value.keys.length, equals(2));
      expect(path.value.containsKey('title'), isTrue);
      expect(path.value.containsKey('body'), isTrue);
      expect(path.value['title'], equals('Complex Title'));
      expect(
          path.value['body'],
          equals(
              'Complex body with\nmultiple lines\nand special chars: @#\$%'));
    });
  });
}
