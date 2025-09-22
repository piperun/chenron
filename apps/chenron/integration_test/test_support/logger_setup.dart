import 'dart:io';

import 'package:chenron/utils/logger.dart';

void installTestLogger() {
  final dir = Directory.systemTemp.createTempSync('chenron_test_logs');
  loggerGlobal.setupLogging(logDir: dir, logToFileInDebug: false);
}