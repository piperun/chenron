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
