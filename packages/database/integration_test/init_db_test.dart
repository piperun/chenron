import "dart:io";

import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:flutter_test/flutter_test.dart";
import "package:drift/native.dart";
import "package:database/database.dart";
import "package:integration_test/integration_test.dart";
import "package:path_provider/path_provider.dart";

import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(databaseName: "test_db", debugMode: true);
  });
  tearDown(() async {
    await database.close();
  });

  test("AppDatabase constructor initializes with no setup memory database", () {
    final db = AppDatabase(queryExecutor: NativeDatabase.memory());
    expect(db.schemaVersion, equals(1));
  });

  test("AppDatabase constructor initializes with no setup file database", () {
    final db = AppDatabase(databaseName: "test_db", debugMode: true);
    expect(db.schemaVersion, equals(1));
  });

  // Helper function to remove the database
  Future<void> removeDatabaseFile(String databaseName) async {
    final databasePath = await getApplicationDocumentsDirectory();
    final file = File(databasePath.path + databaseName);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  test("AppDatabase constructor with setupOnInit initializes item types",
      () async {
    final setupDatabase = AppDatabase(
        databaseName: "test_db", setupOnInit: true, debugMode: true);
    await setupDatabase.setup();

    final itemTypesTable = setupDatabase.itemTypes;
    final itemTypes = await setupDatabase.select(itemTypesTable).get();
    final metadataTypesTable = setupDatabase.metadataTypes;
    final metadataTypes = await setupDatabase.select(metadataTypesTable).get();
    // Debug output: item: $itemTypes\n metadata: $metadataTypes
    expect(itemTypes.length, equals(FolderItemType.values.length),
        reason: "Number of item types should match the enum values");
    expect(metadataTypes.length, equals(MetadataTypeEnum.values.length),
        reason: "Number of metadata types should match the enum values");

    await database.close();
    await removeDatabaseFile("test_database_setup");
  });
}




