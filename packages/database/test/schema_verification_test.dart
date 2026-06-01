import "package:database/app_database.dart";
import "package:database/config_database.dart";
import "package:drift_dev/api/migrations_native.dart";
import "package:flutter_test/flutter_test.dart";

import "generated_migrations/schema.dart" as app;
import "generated_migrations/schema_v16.dart" as v16;
import "generated_migrations_config/schema.dart" as config;

void main() {
  group("AppDatabase schema verification", () {
    late SchemaVerifier verifier;

    setUpAll(() {
      verifier = SchemaVerifier(app.GeneratedHelper());
    });

    test("migrating from v12 produces the current v17 schema", () async {
      final connection = await verifier.schemaAt(12);
      final db = AppDatabase(queryExecutor: connection.newConnection());
      await verifier.migrateAndValidate(db, 17);
      await db.close();
    });

    test("migrating from v14 produces the current v17 schema", () async {
      final connection = await verifier.schemaAt(14);
      final db = AppDatabase(queryExecutor: connection.newConnection());
      await verifier.migrateAndValidate(db, 17);
      await db.close();
    });

    test("migrating from v15 produces the current v17 schema", () async {
      final connection = await verifier.schemaAt(15);
      final db = AppDatabase(queryExecutor: connection.newConnection());
      await verifier.migrateAndValidate(db, 17);
      await db.close();
    });

    test("migrating from v16 produces the current v17 schema", () async {
      final connection = await verifier.schemaAt(16);
      final db = AppDatabase(queryExecutor: connection.newConnection());
      await verifier.migrateAndValidate(db, 17);
      await db.close();
    });

    test("v16 -> v17 collapses pre-existing duplicate metadata relations",
        () async {
      final schema = await verifier.schemaAt(16);

      // Seed two identical tag relations (same item/metadata/type, distinct
      // ids) — only possible before the v17 unique index exists.
      final id1 = "rel${"0" * 26}1";
      final id2 = "rel${"0" * 26}2";
      final oldDb = v16.DatabaseAtV16(schema.newConnection());
      await oldDb.customStatement(
        "INSERT INTO metadata_records (id, type_id, item_id, metadata_id) "
        "VALUES ('$id1', 0, 'item-1', 'tag-1')",
      );
      await oldDb.customStatement(
        "INSERT INTO metadata_records (id, type_id, item_id, metadata_id) "
        "VALUES ('$id2', 0, 'item-1', 'tag-1')",
      );
      await oldDb.close();

      // Run the real migration to the current version.
      final db = AppDatabase(queryExecutor: schema.newConnection());
      await verifier.migrateAndValidate(db, 17);

      // The duplicate must be gone, exactly one survivor remains, and the
      // new unique index must now reject a re-inserted duplicate.
      final remaining = await db
          .customSelect("SELECT COUNT(*) AS c FROM metadata_records")
          .getSingle();
      expect(remaining.read<int>("c"), 1);

      await db.customStatement(
        "INSERT OR IGNORE INTO metadata_records (id, type_id, item_id, metadata_id) "
        "VALUES ('re${"0" * 27}3', 0, 'item-1', 'tag-1')",
      );
      final afterReinsert = await db
          .customSelect("SELECT COUNT(*) AS c FROM metadata_records")
          .getSingle();
      expect(afterReinsert.read<int>("c"), 1);

      await db.close();
    });
  });

  group("ConfigDatabase schema verification", () {
    late SchemaVerifier verifier;

    setUpAll(() {
      verifier = SchemaVerifier(config.GeneratedHelper());
    });

    test("fresh database matches the v5 schema", () async {
      final connection = await verifier.schemaAt(5);
      final db = ConfigDatabase(queryExecutor: connection.newConnection());
      await verifier.migrateAndValidate(db, 5);
      await db.close();
    });
  });
}
