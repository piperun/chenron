import "package:database/app_database.dart";
import "package:database/config_database.dart";
import "package:drift_dev/api/migrations_native.dart";
import "package:flutter_test/flutter_test.dart";

import "../generated_migrations/schema.dart" as app;
import "../generated_migrations/schema_v17.dart" as v17;
import "../generated_migrations_config/schema.dart" as config;
import "../generated_migrations_config/schema_v5.dart" as v5;

/// Canonical shape every stored timestamp must have after the v19 (app) /
/// v6 (config) migration: UTC ISO-8601 at millisecond precision.
final _canonical = RegExp(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$");

void main() {
  group("App DB timestamp normalization (v17 -> v19)", () {
    late SchemaVerifier verifier;

    setUpAll(() {
      verifier = SchemaVerifier(app.GeneratedHelper());
    });

    test("rewrites every legacy timestamp shape to canonical UTC ms",
        () async {
      final schema = await verifier.schemaAt(17);

      // Seed one representative legacy format per shape into the columns
      // the migration normalizes.
      final old = v17.DatabaseAtV17(schema.newConnection());

      // Space-separated, whole-second (SQLite CURRENT_TIMESTAMP shape).
      await old.customStatement(
        "INSERT INTO folders (id, created_at, updated_at, title, description) "
        "VALUES ('fld00000000000000000000000001', "
        "'2026-06-03 21:48:25', '2026-06-03 21:48:25', 'Title', 'Desc')",
      );

      // Microsecond precision with trailing Z (must truncate to ms).
      await old.customStatement(
        "INSERT INTO recent_access (entity_id, entity_type, last_accessed_at, access_count) "
        "VALUES ('e1', 'link', '2026-06-03T21:48:25.665123Z', 1)",
      );

      // Local-offset form WITH the space before the offset — the migration
      // must fold the offset into the UTC instant (21:48 +02:00 -> 19:48Z).
      await old.customStatement(
        "INSERT INTO activity_events (id, occurred_at, event_type, entity_type) "
        "VALUES ('act00000000000000000000000001', "
        "'2026-06-03T21:48:25.665180 +02:00', 'viewed', 'link')",
      );

      await old.close();

      final db = AppDatabase(queryExecutor: schema.newConnection());
      await verifier.migrateAndValidate(db, 19);

      final folder = await db
          .customSelect(
              "SELECT created_at, updated_at FROM folders WHERE id = 'fld00000000000000000000000001'")
          .getSingle();
      expect(folder.read<String>("created_at"), matches(_canonical));
      expect(folder.read<String>("updated_at"), matches(_canonical));

      final recent = await db
          .customSelect(
              "SELECT last_accessed_at FROM recent_access WHERE entity_id = 'e1'")
          .getSingle();
      final recentTs = recent.read<String>("last_accessed_at");
      expect(recentTs, matches(_canonical));
      // Microseconds truncated to milliseconds, not rounded.
      expect(recentTs, "2026-06-03T21:48:25.665Z");

      final activity = await db
          .customSelect(
              "SELECT occurred_at FROM activity_events WHERE id = 'act00000000000000000000000001'")
          .getSingle();
      final occurred = activity.read<String>("occurred_at");
      expect(occurred, matches(_canonical));
      // The +02:00 offset was applied: 21:48 local -> 19:48 UTC.
      expect(occurred, "2026-06-03T19:48:25.665Z");

      await db.close();
    });

    test("re-migrating an already-normalized v19 database changes nothing",
        () async {
      final schema = await verifier.schemaAt(17);

      final old = v17.DatabaseAtV17(schema.newConnection());
      await old.customStatement(
        "INSERT INTO activity_events (id, occurred_at, event_type, entity_type) "
        "VALUES ('act00000000000000000000000002', "
        "'2026-06-03T21:48:25.665180 +02:00', 'viewed', 'link')",
      );
      await old.close();

      // First migration normalizes the value.
      final db = AppDatabase(queryExecutor: schema.newConnection());
      await verifier.migrateAndValidate(db, 19);

      final firstPass = (await db
              .customSelect(
                  "SELECT occurred_at AS v FROM activity_events WHERE id = 'act00000000000000000000000002'")
              .getSingle())
          .read<String>("v");
      expect(firstPass, "2026-06-03T19:48:25.665Z");

      // Re-running the same idempotent UPDATE statements must be a no-op:
      // the guard skips rows already in canonical form.
      await db.customStatement(
        "UPDATE activity_events SET occurred_at = strftime('%Y-%m-%dT%H:%M:%fZ', occurred_at) "
        "WHERE occurred_at IS NOT NULL AND occurred_at <> strftime('%Y-%m-%dT%H:%M:%fZ', occurred_at)",
      );

      final secondPass = (await db
              .customSelect(
                  "SELECT occurred_at AS v FROM activity_events WHERE id = 'act00000000000000000000000002'")
              .getSingle())
          .read<String>("v");
      expect(secondPass, firstPass);

      await db.close();
    });
  });

  group("Config DB timestamp normalization (v5 -> v6)", () {
    late SchemaVerifier verifier;

    setUpAll(() {
      verifier = SchemaVerifier(config.GeneratedHelper());
    });

    test("normalizes config timestamps and rebuilds ms-precision triggers",
        () async {
      final schema = await verifier.schemaAt(5);

      final old = v5.DatabaseAtV5(schema.newConnection());
      // Space-second + microsecond + offset shapes across the config tables.
      await old.customStatement(
        "INSERT INTO user_configs (id, created_at, updated_at) "
        "VALUES ('cfg00000000000000000000000001', "
        "'2026-06-03 21:48:25', '2026-06-03T21:48:25.665123Z')",
      );
      await old.customStatement(
        "INSERT INTO user_themes "
        "(id, user_config_id, created_at, updated_at, name, primary_color, secondary_color) "
        "VALUES ('thm00000000000000000000000001', 'cfg00000000000000000000000001', "
        "'2026-06-03T21:48:25.665180 +02:00', '2026-06-03 21:48:25', "
        "'Theme', 1, 2)",
      );
      await old.customStatement(
        "INSERT INTO backup_settings (id, user_config_id, last_backup_timestamp) "
        "VALUES ('bks00000000000000000000000001', 'cfg00000000000000000000000001', "
        "'2026-06-03 21:48:25')",
      );
      await old.close();

      final db = ConfigDatabase(queryExecutor: schema.newConnection());
      await verifier.migrateAndValidate(db, 6);

      final cfg = await db
          .customSelect(
              "SELECT created_at, updated_at FROM user_configs WHERE id = 'cfg00000000000000000000000001'")
          .getSingle();
      expect(cfg.read<String>("created_at"), matches(_canonical));
      expect(cfg.read<String>("updated_at"), "2026-06-03T21:48:25.665Z");

      final thm = await db
          .customSelect(
              "SELECT created_at, updated_at FROM user_themes WHERE id = 'thm00000000000000000000000001'")
          .getSingle();
      // Offset folded into UTC.
      expect(thm.read<String>("created_at"), "2026-06-03T19:48:25.665Z");
      expect(thm.read<String>("updated_at"), matches(_canonical));

      final bks = await db
          .customSelect(
              "SELECT last_backup_timestamp FROM backup_settings WHERE id = 'bks00000000000000000000000001'")
          .getSingle();
      expect(bks.read<String>("last_backup_timestamp"), matches(_canonical));

      // The rebuilt trigger must now stamp millisecond precision. Touch a
      // row (without changing updated_at) so the trigger fires.
      await db.customStatement(
        "UPDATE user_configs SET dark_mode = 1 WHERE id = 'cfg00000000000000000000000001'",
      );
      final stamped = (await db
              .customSelect(
                  "SELECT updated_at AS v FROM user_configs WHERE id = 'cfg00000000000000000000000001'")
              .getSingle())
          .read<String>("v");
      expect(stamped, matches(_canonical),
          reason: "trigger should stamp canonical UTC ms, got <$stamped>");

      await db.close();
    });
  });
}
