import "package:database/app_database.dart";
import "package:drift_dev/api/migrations_native.dart";
import "package:flutter_test/flutter_test.dart";

import "generated_migrations/schema.dart";

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test("fresh database (onCreate) matches expected v12 schema", () async {
    final connection = await verifier.schemaAt(12);

    final db = AppDatabase(queryExecutor: connection.newConnection());
    await verifier.migrateAndValidate(db, 12);
    await db.close();
  });
}
