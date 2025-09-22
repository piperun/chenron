import "dart:io";

import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:flutter_test/flutter_test.dart";
import "package:drift/native.dart";
import "package:chenron/database/database.dart";
import "package:integration_test/integration_test.dart";
import "package:path_provider/path_provider.dart";

import "../test_support/path_provider_fake.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    installFakePathProvider();
  });
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(databaseName: "test_db");
  });
  tearDown(() async {
    await database.close();
  });

  test("AppDatabase constructor initializes with no setup memory database", () {
    final db = AppDatabase(queryExecutor: NativeDatabase.memory());
    expect(db.schemaVersion, equals(1));
  });

  test("AppDatabase constructor initializes with no setup file database", () {
    final db = AppDatabase(databaseName: "test_db");
    expect(db.schemaVersion, equals(1));
  });

  // Helper function to remove the database
  Future<void> removeDatabaseFile(String databaseName) async {
    final databasePath = await getApplicationDocumentsDirectory();
    final file = File(databasePath.path + databaseName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  test("AppDatabase constructor with setupOnInit initializes item types",
      () async {
    final setupDatabase =
        AppDatabase(databaseName: "test_db", setupOnInit: true);

    final itemTypes = await setupDatabase.select(setupDatabase.itemTypes).get();
    final metadataTypes =
        await setupDatabase.select(setupDatabase.metadataTypes).get();
    print("item: $itemTypes\n metadata: $metadataTypes");
    expect(itemTypes.length, equals(FolderItemType.values.length),
        reason: "Number of item types should match the enum values");
    expect(metadataTypes.length, equals(MetadataTypeEnum.values.length),
        reason: "Number of metadata types should match the enum values");

    await database.close();
    await removeDatabaseFile("test_database_setup");
  });
}
