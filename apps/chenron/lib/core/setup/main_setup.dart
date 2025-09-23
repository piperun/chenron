// lib/initialization/app_setupr.dart
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:basedir/directory.dart";
import "package:chenron/utils/logger.dart";
import "package:chenron/database/extensions/operations/config_file_handler.dart";
import "package:flutter/foundation.dart";
import "package:signals/signals_flutter.dart"; // Or core if no Flutter needed here
import "dart:io"; // For Directory

class InitializationException implements Exception {
  final String message;
  final dynamic cause;
  final StackTrace? stackTrace;

  InitializationException(this.message, {this.cause, this.stackTrace});

  @override
  String toString() {
    String output = "InitializationException: $message";
    if (cause != null) {
      output += "\nCause: $cause";
    }
    // Note: Printing stack trace here might be too verbose for toString,
    // better to log it separately.
    return output;
  }
}

class MainSetup {
  static bool _setupDone = false;

  static Future<void> setup() async {
    if (_setupDone) {
      // ignore: avoid_print
      print("Warning: MainSetup.setup() called more than once.");
      return;
    }

    if (kDebugMode) {
      print("MainSetup: Starting initialization...");
    }

    try {
      _setupLocator();

      // 2. Resolve Base Directories (Critical for subsequent steps)
      final ChenronDirectories baseDir = await _resolveBaseDirectory();
      // 4. Setup Logging (Now that config might be ready and dirs are known)
      await _setupLogging(baseDir);
      // Logger should be fully functional now (including file logging if enabled)
      loggerGlobal.info("MainSetup", "Logging setup complete.");
      // 3. Setup Configuration Database
      await _setupConfig(baseDir);
      loggerGlobal.info("MainSetup", "Config database setup complete.");

      _setupDone = true;
      loggerGlobal.info(
          "MainSetup", "Initialization sequence completed successfully.");
    } catch (error, stackTrace) {
      // Catch any error bubbling up from the setup steps
      final errorMsg = "Core application initialization failed.";
      // Use print as a fallback in case logger itself failed during setup
      // ignore: avoid_print
      print(
          "!!! FATAL INITIALIZATION ERROR: $errorMsg\nError: $error\nStackTrace: $stackTrace");
      // Attempt to log using the logger as well, it might partially work
      loggerGlobal.severe("MainSetup", errorMsg, error, stackTrace);

      // Re-throw a specific exception to signal failure to main.dart
      throw InitializationException(errorMsg,
          cause: error, stackTrace: stackTrace);
    }
  }

  static void _setupLocator() {
    try {
      locatorSetup();
    } catch (e, s) {
      // Failure here is likely fatal and happens before logger is ready
      // ignore: avoid_print
      print(
          "!!! FATAL ERROR: Locator setup failed.\nError: $e\nStackTrace: $s");
      throw InitializationException("Locator setup failed",
          cause: e, stackTrace: s);
    }
  }

  static Future<ChenronDirectories> _resolveBaseDirectory() async {
    try {
      final baseDirFuture = locator.get<Signal<Future<ChenronDirectories?>>>();
      final baseDir = await baseDirFuture.value;

      if (baseDir == null) {
        throw Exception("Base directory future resolved to null.");
      }
      return baseDir;
    } catch (e, s) {
      const errorMsg = "Failed to resolve base directories.";
      // ignore: avoid_print
      print("!!! FATAL ERROR: $errorMsg\nError: $e\nStackTrace: $s");
      throw InitializationException(errorMsg, cause: e, stackTrace: s);
    }
  }

  static Future<void> _setupConfig(ChenronDirectories baseDir) async {
    try {
      final configHandler = locator.get<Signal<ConfigDatabaseFileHandler>>();
      final databaseLocation = DatabaseLocation(
        databaseDirectory: baseDir.configDir,
        databaseFilename: "config.sqlite",
      );
      configHandler.value.databaseLocation = databaseLocation;
      configHandler.value.createDatabase(setupOnInit: true);
    } catch (e, s) {
      const errorMsg = "Configuration database setup failed.";
      loggerGlobal.severe(
          "MainSetup", errorMsg, e, s); // Logger might be partially ready
      throw InitializationException(errorMsg,
          cause: e, stackTrace: s); // Re-throw as fatal
    }
  }

  static Future<void> _setupLogging(ChenronDirectories baseDir) async {
    try {
      final logDir = Directory(baseDir.logDir.path);

      // Ensure the directory exists *before* setting up the logger
      // (setupLogging might assume it exists)
      if (!await logDir.exists()) {
        loggerGlobal.warning("MainSetup",
            "Log directory does not exist, attempting to create: ${logDir.path}");
        await logDir.create(recursive: true);
      }

      // Call the actual logger setup
      loggerGlobal.setupLogging(logDir: logDir, logToFileInDebug: false);
      // Note: setupLogging itself has internal error handling for file writes,
      // but the initial setup (like listener attachment) could fail.
    } catch (e, s) {
      const errorMsg = "Logging setup failed.";
      // Use print as logger setup itself failed.
      // ignore: avoid_print
      print("!!! ERROR: $errorMsg\nError: $e\nStackTrace: $s");
      // Don't use loggerGlobal here as it's the thing that failed.
      // Decide if this is fatal. Usually yes, as logging is crucial.
      throw InitializationException(errorMsg, cause: e, stackTrace: s);
    }
  }
}
