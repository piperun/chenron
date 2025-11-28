import 'package:flutter_test/flutter_test.dart';
import 'package:database/database.dart';
import 'package:database/extensions/tags/create.dart';
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
    // Clean up tags
    await database.delete(database.tags).go();
    await database.close();
  });

  group('TagExtensions.addTag()', () {
    test('creates new tag successfully', () async {
      final tagId = await database.addTag('flutter');

      expect(tagId, isNotEmpty);
      expect(tagId.length, equals(30));

      // Verify tag exists in database
      final tag = await (database.select(database.tags)
            ..where((tbl) => tbl.id.equals(tagId)))
          .getSingleOrNull();

      expect(tag, isNotNull);
      expect(tag!.name, equals('flutter'));
      expect(tag.color, isNull); // Verify default is null
    });

    test('creates new tag with color successfully', () async {
      final colorValue = 0xFFFF0000;
      final tagId = await database.addTag('red-tag', color: colorValue);

      expect(tagId, isNotEmpty);

      // Verify tag exists in database with color
      final tag = await (database.select(database.tags)
            ..where((tbl) => tbl.id.equals(tagId)))
          .getSingleOrNull();

      expect(tag, isNotNull);
      expect(tag!.name, equals('red-tag'));
      expect(tag.color, equals(colorValue));
    });

    test('creates multiple different tags', () async {
      final tagId1 = await database.addTag('dart');
      final tagId2 = await database.addTag('flutter');
      final tagId3 = await database.addTag('mobile');

      expect(tagId1, isNot(equals(tagId2)));
      expect(tagId2, isNot(equals(tagId3)));
      expect(tagId1, isNot(equals(tagId3)));

      // Verify all tags exist
      final allTags = await database.select(database.tags).get();
      expect(allTags.length, equals(3));

      final tagNames = allTags.map((t) => t.name).toSet();
      expect(tagNames, equals({'dart', 'flutter', 'mobile'}));
    });

    test('handles tag with special characters', () async {
      final tagId = await database.addTag('C++ Code');

      final tag = await (database.select(database.tags)
            ..where((tbl) => tbl.id.equals(tagId)))
          .getSingleOrNull();

      expect(tag, isNotNull);
      expect(tag!.name, equals('C++ Code'));
    });

    test('handles tag with numbers', () async {
      final tagId = await database.addTag('web3.0');

      final tag = await (database.select(database.tags)
            ..where((tbl) => tbl.id.equals(tagId)))
          .getSingleOrNull();

      expect(tag, isNotNull);
      expect(tag!.name, equals('web3.0'));
    });

    test('handles tag with emojis', () async {
      final tagId = await database.addTag('🚀 rocket');

      final tag = await (database.select(database.tags)
            ..where((tbl) => tbl.id.equals(tagId)))
          .getSingleOrNull();

      expect(tag, isNotNull);
      expect(tag!.name, equals('🚀 rocket'));
    });

    test('creates tag with very long name', () async {
      final longName = 'a' * 12;
      final tagId = await database.addTag(longName);

      final tag = await (database.select(database.tags)
            ..where((tbl) => tbl.id.equals(tagId)))
          .getSingleOrNull();

      expect(tag, isNotNull);
      expect(tag!.name, equals(longName));
    });

    test('returns consistent ID for same tag name (Idempotent)', () async {
      // First creation
      final tagId1 = await database.addTag('same-tag');

      // Second creation with same name
      final tagId2 = await database.addTag('same-tag');

      // Should return the same tag ID
      expect(tagId1, equals(tagId2));

      // Verify only one tag exists
      final allTags = await (database.select(database.tags)
            ..where((tbl) => tbl.name.equals('same-tag')))
          .get();

      expect(allTags.length, equals(1));
    });

    test('fails to create tag with empty name', () async {
      expect(
        () => database.addTag(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('fails to create tag with short name (min 3)', () async {
      expect(
        () => database.addTag('ab'), // 2 chars
        throwsA(isA<Exception>()),
      );
    });

    test('fails to create tag with long name (max 12)', () async {
      final longName = 'a' * 13;
      expect(
        () => database.addTag(longName),
        throwsA(isA<Exception>()),
      );
    });
  });
}
