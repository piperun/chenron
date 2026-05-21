import "dart:async";

import "package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart";

/// Auto-applied by `flutter test` to every test in this package's
/// `test/` directory. Wires `leak_tracker_flutter_testing` so any
/// widget / state / signal subscription that outlives its test gets
/// reported.
///
/// Start permissive: tests that leak will be flagged, not failed,
/// while we triage existing leaks. Flip `LeakTesting.settings` later
/// to `failTestOnLeaks` once the suite is clean so we don't regress.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  await testMain();
}
