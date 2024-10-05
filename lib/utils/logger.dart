import "dart:io";
import "package:path/path.dart" as path;
import "package:flutter/foundation.dart";
import "package:logging/logging.dart";

final class LoggerImpl {
  static final LoggerImpl _instance = LoggerImpl._internal();
  factory LoggerImpl() => _instance;
  LoggerImpl._internal();

  final _loggers = <String, Logger>{};

  void setupLogPath(String basePath) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        print("${record.level.name}: ${record.time}: ${record.message}");
      } else {
        final logDir = Directory(path.join(basePath, "log"));
        logDir.createSync(recursive: true);

        final fileName = "${record.time.toIso8601String()}.log";
        final file = File(path.join(logDir.path, fileName));

        file.writeAsStringSync(
          "${record.level.name}: ${record.time}: ${record.message}\n",
          mode: FileMode.append,
        );
      }
    });
  }

  Logger getLogger(String source) {
    return _loggers.putIfAbsent(source, () => Logger(source));
  }

  void shout(String source, Object? message,
      [Object? error, StackTrace? stackTrace]) {
    final logger = getLogger(source);
    logger.shout(message, error, stackTrace);
  }

  void severe(String source, Object? message,
      [Object? error, StackTrace? stackTrace]) {
    final logger = getLogger(source);
    logger.severe(message, error, stackTrace);
  }

  void warning(String source, Object? message,
      [Object? error, StackTrace? stackTrace]) {
    final logger = getLogger(source);
    logger.warning(message, error, stackTrace);
  }

  void info(String source, Object? message,
      [Object? error, StackTrace? stackTrace]) {
    final logger = getLogger(source);
    logger.info(message, error, stackTrace);
  }

  void config(String source, Object? message,
      [Object? error, StackTrace? stackTrace]) {
    final logger = getLogger(source);
    logger.config(message, error, stackTrace);
  }

  void fine(String source, Object? message,
      [Object? error, StackTrace? stackTrace]) {
    final logger = getLogger(source);
    logger.fine(message, error, stackTrace);
  }

  void finer(String source, Object? message,
      [Object? error, StackTrace? stackTrace]) {
    final logger = getLogger(source);
    logger.finer(message, error, stackTrace);
  }

  void finest(String source, Object? message,
      [Object? error, StackTrace? stackTrace]) {
    final logger = getLogger(source);
    logger.finest(message, error, stackTrace);
  }
}

// Global instance for easy access
final loggerGlobal = LoggerImpl();
