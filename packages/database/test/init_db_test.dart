import "package:database/main.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  test(
      "AppDatabase with setupOnInit seeds the default folder on first creation",
      () async {
    final db = AppDatabase(
        databaseName: "test_init_db_default_folder",
        setupOnInit: true,
        debugMode: true);

    final folders = await db.select(db.folders).get();
    expect(folders, hasLength(1));
    expect(folders.single.title, "Default");

    await db.close();
  });

  test(
      "AppDatabase without setupOnInit does NOT seed the default folder",
      () async {
    final db = AppDatabase(
        databaseName: "test_init_db_no_default_folder",
        debugMode: true);

    final folders = await db.select(db.folders).get();
    expect(folders, isEmpty);

    await db.close();
  });
}
