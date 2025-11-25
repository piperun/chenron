import 'package:flutter_test/flutter_test.dart';
import 'package:database/database.dart';
import 'package:database/extensions/tags/read.dart';
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
    await database.delete(database.tags).go();
    await database.close();
  });

  group('TagReadExtensions.getTag()', () {
    test('retrieves existing tag by ID', () async {
      final tagId = await database.addTag('flutter');

      final result = await database.getTag(tagId: tagId);

      expect(result, isNotNull);
      expect(result!.name, equals('flutter'));
    });

    test('returns null for non-existent tag', () async {
      final result = await database.getTag(tagId: 'non-existent-id');

      expect(result, isNull);
    });
  });

  group('TagReadExtensions.getAllTags()', () {
    test('retrieves all tags when multiple exist', () async {
      await database.addTag('dart');
      await database.addTag('flutter');
      await database.addTag('mobile');

      final results = await database.getAllTags();

      expect(results.length, equals(3));
      final tagNames = results.map((r) => r.name).toSet();
      expect(tagNames, equals({'dart', 'flutter', 'mobile'}));
    });

    test('returns empty list when no tags exist', () async {
      final results = await database.getAllTags();

      expect(results, isEmpty);
    });

    test('retrieves single tag', () async {
      await database.addTag('solo-tag');

      final results = await database.getAllTags();

      expect(results.length, equals(1));
      expect(results.first.name, equals('solo-tag'));
    });
  });

  group('TagReadExtensions.watchTag()', () {
    test('emits tag when it exists', () async {
      final tagId = await database.addTag('watch-me');

      final stream = database.watchTag(tagId: tagId);

      await expectLater(
        stream,
        emits(predicate<dynamic>((result) {
          return result != null && result.name == 'watch-me';
        })),
      );
    });

    test('emits null for non-existent tag', () async {
      final stream = database.watchTag(tagId: 'non-existent');

      await expectLater(stream, emits(null));
    });

    test('emits updates when tag is created', () async {
      final tagId = 'test-tag-id-123456789012345678';
      final stream = database.watchTag(tagId: tagId);

      // Initially should emit null
      await expectLater(stream, emits(null));

      // Create the tag manually
      await database.into(database.tags).insert(
            TagsCompanion.insert(id: tagId, name: 'new-tag'),
          );

      // Should now emit the tag
      await expectLater(
        stream,
        emits(predicate<dynamic>((result) {
          return result != null && result.name == 'new-tag';
        })),
      );
    });
  });

  group('TagReadExtensions.watchAllTags()', () {
    test('emits all tags initially', () async {
      await database.addTag('tag1');
      await database.addTag('tag2');

      final stream = database.watchAllTags();

      await expectLater(
        stream,
        emits(predicate<List>((results) {
          return results.length == 2;
        })),
      );
    });

    test('emits empty list when no tags exist', () async {
      final stream = database.watchAllTags();

      await expectLater(
        stream,
        emits(predicate<List>((results) => results.isEmpty)),
      );
    });

    test('emits updates when new tag is added', () async {
      final stream = database.watchAllTags();

      // Initially empty
      await expectLater(
        stream,
        emits(predicate<List>((results) => results.isEmpty)),
      );

      // Add a tag
      await database.addTag('dynamic-tag');

      // Should emit updated list
      await expectLater(
        stream,
        emits(predicate<List>((results) {
          return results.length == 1 && results.first.name == 'dynamic-tag';
        })),
      );
    });
  });

  group('TagReadExtensions.searchTags()', () {
    test('finds tags matching query', () async {
      await database.addTag('flutter');
      await database.addTag('dart');
      await database.addTag('flutter-mob');

      final results = await database.searchTags(query: 'flutter');

      expect(results.length, greaterThanOrEqualTo(1));
      expect(results.any((r) => r.name.contains('flutter')), isTrue);
    });

    test('returns empty list when no matches', () async {
      await database.addTag('dart');
      await database.addTag('kotlin');

      final results = await database.searchTags(query: 'nonexistent');

      expect(results, isEmpty);
    });

    test('search is case-insensitive', () async {
      await database.addTag('Flutter');

      final results = await database.searchTags(query: 'flutter');

      expect(results.isNotEmpty, isTrue);
    });

    test('finds multiple matching tags', () async {
      await database.addTag('web-dev');
      await database.addTag('web-design');
      await database.addTag('mobile-dev');

      final results = await database.searchTags(query: 'web');

      expect(results.length, greaterThanOrEqualTo(2));
      expect(results.every((r) => r.name.contains('web')), isTrue);
    });
  });
}
