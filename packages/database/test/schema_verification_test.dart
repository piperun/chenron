import "package:database/app_database.dart";
import "package:database/config_database.dart";
import "package:drift_dev/api/migrations_native.dart";
import "package:flutter_test/flutter_test.dart";

import "generated_migrations/schema.dart" as app;
import "generated_migrations_config/schema.dart" as config;

void main() {
  group("AppDatabase schema verification", () {
    late SchemaVerifier verifier;

    setUpAll(() {
      verifier = SchemaVerifier(app.GeneratedHelper());
    });

    test("migrating from v12 produces the current v16 schema", () async {
      final connection = await verifier.schemaAt(12);
      final db = AppDatabase(queryExecutor: connection.newConnection());
      await verifier.migrateAndValidate(db, 16);
      await db.close();
    });

    test("migrating from v14 produces the current v16 schema", () async {
      final connection = await verifier.schemaAt(14);
      final db = AppDatabase(queryExecutor: connection.newConnection());
      await verifier.migrateAndValidate(db, 16);
      await db.close();
    });

    test("migrating from v15 produces the current v16 schema", () async {
      final connection = await verifier.schemaAt(15);
      final db = AppDatabase(queryExecutor: connection.newConnection());
      await verifier.migrateAndValidate(db, 16);
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
