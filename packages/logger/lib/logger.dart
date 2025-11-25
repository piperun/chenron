import "dart:io";
import "package:path/path.dart" as path;
import "package:flutter/foundation.dart";
import "package:logging/logging.dart";

final class LoggerImpl {
  static final LoggerImpl _instance = LoggerImpl._internal();
  factory LoggerImpl() => _instance;
  LoggerImpl._internal();

  final Map<String, Logger> _loggers = <String, Logger>{};
  bool _isSetup = false; // Flag to prevent multiple setups

  /// Configures the root logger listener.
  ///
  /// - Always prints to console if `kDebugMode` is true.
  /// - Writes to a file in [logDir] if `kDebugMode` is false, OR
  ///   if `kDebugMode` is true AND [logToFileInDebug] is true.
  void setupLogging({
    required Directory logDir,
    bool logToFileInDebug = false,
  }) {
    if (_isSetup) {
      // Avoid attaching multiple listeners if called again
      debugPrint("Warning: Logger setup attempted multiple times.");
      return;
    }

    Logger.root.level = Level.ALL; // Capture all levels

    Logger.root.onRecord.listen((record) {
      // 1. Console Logging (Always in Debug)
      if (kDebugMode) {
        // Standard console output format
        debugPrint(
            "${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}");
        if (record.error != null) {
          debugPrint("  ERROR: ${record.error}");
        }
        if (record.stackTrace != null) {
          // Consider printing only a summary or using devtools for full trace
          debugPrint("  STACKTRACE: ${record.stackTrace}");
        }
      }

      final bool shouldLogToFile =
          !kDebugMode || (kDebugMode && logToFileInDebug);

      if (shouldLogToFile) {
        try {
          // Ensure directory exists (belt-and-suspenders check)
          if (!logDir.existsSync()) {
            logDir.createSync(recursive: true);
            // Log this potentially unexpected creation to console
            debugPrint(
                "Warning: Log directory created by logger: ${logDir.path}");
          }

          // Simple filename based on timestamp - adjust if needed
          final fileName =
              "${record.time.toIso8601String().replaceAll(':', '-')}.log";
          final file = File(path.join(logDir.path, fileName));

          // Format message for file
          String fileMsg =
              "${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}\n";
          if (record.error != null) {
            fileMsg += "  ERROR: ${record.error}\n";
          }
          if (record.stackTrace != null) {
            fileMsg += "  STACKTRACE:\n${record.stackTrace}\n";
          }

          // Append to the file
          file.writeAsStringSync(
            fileMsg,
            mode: FileMode.append,
            flush: true, // Try to write immediately
          );
        } catch (e, s) {
          // If file logging fails, print error to console to avoid crashing
          debugPrint("!!! LOGGER FILE WRITE FAILED: $e");
          debugPrint("!!! StackTrace: $s");
        }
      }
    });

    _isSetup = true;
    // Use print for this initial confirmation as logger might not be fully ready
    debugPrint(
        "Logger setup complete. Log directory: ${logDir.path}. File logging in debug: $logToFileInDebug");
  }

  Logger getLogger(String source) {
    if (!_isSetup) {
      throw StateError(
          "Logger has not been initialized. Call setupLogging() before attempting to log.");
    }
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
