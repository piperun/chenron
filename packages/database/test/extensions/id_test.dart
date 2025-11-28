import 'package:database/features.dart';
import 'package:flutter_test/flutter_test.dart';
import "package:database/main.dart";
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

  group('GlobalIdGenerator Extension', () {
    test('generateId() produces non-empty ID', () {
      final id = database.generateId();
      expect(id, isNotEmpty);
    });

    test('generateId() produces unique IDs', () {
      final id1 = database.generateId();
      final id2 = database.generateId();
      final id3 = database.generateId();

      expect(id1, isNot(equals(id2)));
      expect(id2, isNot(equals(id3)));
      expect(id1, isNot(equals(id3)));
    });

    test('generateId() default length is 30 characters', () {
      final id = database.generateId();
      expect(id.length, equals(30));
    });

    test('generateId() respects custom length parameter', () {
      final id10 = database.generateId(length: 10);
      final id20 = database.generateId(length: 20);
      final id50 = database.generateId(length: 50);

      expect(id10.length, equals(10));
      expect(id20.length, equals(20));
      expect(id50.length, equals(50));
    });

    test('generateId() produces valid CUID2 format', () {
      final id = database.generateId();

      // CUID2 should only contain alphanumeric characters (lowercase)
      final validPattern = RegExp(r'^[a-z0-9]+$');
      expect(validPattern.hasMatch(id), isTrue);
    });

    test('generateId() produces many unique IDs', () {
      final ids = <String>{};
      for (int i = 0; i < 1000; i++) {
        ids.add(database.generateId());
      }

      // All 1000 IDs should be unique
      expect(ids.length, equals(1000));
    });
  });
}
