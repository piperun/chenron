import "dart:async";
import "dart:io";

import "package:app_logger/app_logger.dart";
import "package:logging/logging.dart";

void installTestLogger() {
  final dir = Directory.systemTemp.createTempSync("chenron_test_logs");
  loggerGlobal.setupLogging(
    logDir: dir,
    logToFileInDebug: false,
    level: Level.WARNING,
  );
}

/// Captures records emitted through [loggerGlobal] into [records] *without*
/// printing them to the console.
///
/// Use instead of [installTestLogger] in tests that deliberately trigger
/// errors: it keeps the expected SEVERE stack traces out of the test output
/// (no `setupLogging` console listener is attached) while letting the test
/// assert that the error was actually logged.
///
/// ```dart
/// late TestLogCapture logs;
/// setUp(() => logs = TestLogCapture.start());
/// tearDown(() => logs.stop());
/// // ... trigger an error ...
/// expect(logs.severe, hasLength(1));
/// ```
class TestLogCapture {
  /// Begin capturing every record emitted on the logging hierarchy. Pair with
  /// [stop] in `tearDown`.
  TestLogCapture.start() {
    Logger.root.level = Level.ALL;
    _sub = Logger.root.onRecord.listen(records.add);
  }

  /// All captured records, in emission order.
  final List<LogRecord> records = <LogRecord>[];
  late final StreamSubscription<LogRecord> _sub;

  /// Captured records at [Level.SEVERE] or above.
  Iterable<LogRecord> get severe =>
      records.where((r) => r.level >= Level.SEVERE);

  /// Stop capturing and release the subscription.
  Future<void> stop() => _sub.cancel();
}
