import "package:database/database.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";

/// Tripwire for schema-version bumps.
///
/// These assertions hardcode the CURRENT `schemaVersion` on purpose. Bumping
/// `AppDatabase`/`ConfigDatabase.schemaVersion` (i.e. adding a migration)
/// trips this test in the **database package's own** pre-commit run — the
/// commit that actually makes the change — forcing a conscious review of
/// everything that must move in lockstep: the migration + its tests, the
/// regenerated drift snapshots, and the backup/restore schema canary over in
/// `apps/chenron` (a different package whose tests the bump commit does NOT
/// stage, so its per-package pre-commit never runs them — that cross-package
/// gap is exactly how a stale canary once reached CI red instead of failing
/// locally). Update the expected number here once that review is done.
///
/// Reading `schemaVersion` is a plain constant getter — it never opens the
/// database — so this stays fast.
void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  test("AppDatabase.schemaVersion is 19", () {
    final db = AppDatabase(databaseName: "schema_ver_app", debugMode: true);
    addTearDown(db.close);
    expect(db.schemaVersion, 19,
        reason: "schema bumped — review the migration, its tests, the drift "
            "snapshots, and apps/chenron's backup/restore canary, then bump "
            "this number");
  });

  test("ConfigDatabase.schemaVersion is 6", () {
    final db =
        ConfigDatabase(databaseName: "schema_ver_config", debugMode: true);
    addTearDown(db.close);
    expect(db.schemaVersion, 6,
        reason: "config schema bumped — review the migration, its tests, and "
            "the drift snapshots, then bump this number");
  });
}
