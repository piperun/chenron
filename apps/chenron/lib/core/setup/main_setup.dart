// lib/initialization/app_setupr.dart
// ignore_for_file: avoid_print

import "package:chenron/locator.dart";
import "package:basedir/directory.dart";
import "package:database/database.dart";
import "package:database/main.dart" show ConfigIncludes;
import "package:logger/logger.dart";

import "package:chenron/features/theme/state/theme_utils.dart";
import "package:flutter/foundation.dart";
import "package:signals/signals_flutter.dart";
import "dart:io";
import "package:chenron/base_dirs/schema.dart";

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
    // Check if GetIt was reset (indicates test scenario requiring re-init)
    final getItWasReset =
        _setupDone && !locator.isRegistered<Signal<AppDatabaseHandler>>();

    if (_setupDone && !getItWasReset) {
      print("Warning: MainSetup.setup() called more than once.");
      return;
    }

    if (getItWasReset) {
      // GetIt was reset, allow re-initialization
      _setupDone = false;
      if (kDebugMode) {
        print("MainSetup: GetIt was reset, re-initializing...");
      }
    }

    if (kDebugMode) {
      print("MainSetup: Starting initialization...");
    }

    try {
      _setupLocator();

      // 2. Resolve Base Directories (Critical for subsequent steps)
      final BaseDirectories<ChenronDir> baseDirs =
          await _resolveBaseDirectory();
      // 4. Setup Logging (Now that config might be ready and dirs are known)
      await _setupLogging(baseDirs);
      // Logger should be fully functional now (including file logging if enabled)
      loggerGlobal.info("MainSetup", "Logging setup complete.");
      // 3. Setup Configuration Database
      await _setupConfig(baseDirs);
      loggerGlobal.info("MainSetup", "Config database setup complete.");
      // 4b. Start backup scheduler
      await _startBackupScheduler();
      loggerGlobal.info("MainSetup", "Backup scheduler initialized.");
      // 5. Initialize Theme Registry
      initializeThemeRegistry();
      loggerGlobal.info("MainSetup", "Theme registry initialized.");

      _setupDone = true;
      loggerGlobal.info(
          "MainSetup", "Initialization sequence completed successfully.");
    } catch (error, stackTrace) {
      // Catch any error bubbling up from the setup steps
      final errorMsg = "Core application initialization failed.";
      // Use print as a fallback in case logger itself failed during setup

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

      print(
          "!!! FATAL ERROR: Locator setup failed.\nError: $e\nStackTrace: $s");
      throw InitializationException("Locator setup failed",
          cause: e, stackTrace: s);
    }
  }

  static Future<BaseDirectories<ChenronDir>> _resolveBaseDirectory() async {
    try {
      final baseDirsFuture =
          locator.get<Signal<Future<BaseDirectories<ChenronDir>?>>>();
      final baseDirs = await baseDirsFuture.value;

      if (baseDirs == null) {
        throw Exception("Base directory future resolved to null.");
      }
      return baseDirs;
    } catch (e, s) {
      const errorMsg = "Failed to resolve base directories.";

      print("!!! FATAL ERROR: $errorMsg\nError: $e\nStackTrace: $s");
      throw InitializationException(errorMsg, cause: e, stackTrace: s);
    }
  }

  static Future<void> _setupConfig(BaseDirectories<ChenronDir> baseDirs) async {
    try {
      final configHandler = locator.get<Signal<ConfigDatabaseFileHandler>>();
      final databaseLocation = DatabaseLocation(
        databaseDirectory: baseDirs.dir(ChenronDir.database),
        databaseFilename: "config.sqlite",
      );
      configHandler.value.databaseLocation = databaseLocation;
      configHandler.value.createDatabase(setupOnInit: true);

      // Initialize AppDatabase similarly
      final appDbHandler = locator.get<Signal<AppDatabaseHandler>>();
      final appDatabaseLocation = DatabaseLocation(
        databaseDirectory: baseDirs.dir(ChenronDir.database),
        databaseFilename: "app.sqlite",
      );
      appDbHandler.value.databaseLocation = appDatabaseLocation;
      await appDbHandler.value.createDatabase(setupOnInit: true);

      // Record a daily statistics snapshot if the last one is older than 24h
      await _recordDailySnapshot(appDbHandler.value.appDatabase);
    } catch (e, s) {
      const errorMsg = "Configuration database setup failed.";
      loggerGlobal.severe("MainSetup", errorMsg, e, s);
      throw InitializationException(errorMsg, cause: e, stackTrace: s);
    }
  }

  static Future<void> _setupLogging(
      BaseDirectories<ChenronDir> baseDirs) async {
    try {
      final logDir = Directory(baseDirs.dir(ChenronDir.log).path);

      // Ensure the directory exists *before* setting up the logger
      // (setupLogging might assume it exists)
      if (!logDir.existsSync()) {
        loggerGlobal.warning("MainSetup",
            "Log directory does not exist, attempting to create: ${logDir.path}");
        await logDir.create(recursive: true);
      }

      // Call the actual logger setup
      loggerGlobal.setupLogging(logDir: logDir, logToFileInDebug: false);
    } catch (e, s) {
      const errorMsg = "Logging setup failed.";
      print("!!! ERROR: $errorMsg\nError: $e\nStackTrace: $s");
      throw InitializationException(errorMsg, cause: e, stackTrace: s);
    }
  }

  static Future<void> _startBackupScheduler() async {
    try {
      final configHandler = locator.get<Signal<ConfigDatabaseFileHandler>>();
      final configDb = configHandler.value.configDatabase;

      final configResult = await configDb.getUserConfig(
        includeOptions:
            const IncludeOptions({ConfigIncludes.backupSettings}),
      );

      final backupConfig = configResult?.backupSettings;
      if (backupConfig == null) {
        loggerGlobal.info(
            "MainSetup", "No backup settings found, skipping scheduler.");
        return;
      }

      final scheduler = locator.get<DatabaseBackupScheduler>();
      final cronExpression = backupConfig.backupInterval;

      if (cronExpression != null && cronExpression.isNotEmpty) {
        final lastBackup = backupConfig.lastBackupTimestamp;
        final now = DateTime.now();
        final intervalHours = _parseIntervalHours(cronExpression);

        await scheduler.start(
          cronExpression: cronExpression,
          backupSettingsId: backupConfig.id,
        );

        if (lastBackup == null ||
            now.difference(lastBackup).inHours >= intervalHours) {
          loggerGlobal.info("MainSetup",
              "Running catch-up backup (last: $lastBackup, interval: ${intervalHours}h)");
          await scheduler.runBackup();
        }
      }
    } catch (e) {
      // Non-fatal — don't block app startup
      loggerGlobal.warning(
          "MainSetup", "Failed to start backup scheduler: $e");
    }
  }

  static int _parseIntervalHours(String cronExpression) {
    return switch (cronExpression) {
      "0 0 */4 * * *" => 4,
      "0 0 */8 * * *" => 8,
      "0 0 */12 * * *" => 12,
      "0 0 0 * * *" => 24,
      _ => 8,
    };
  }

  static Future<void> _recordDailySnapshot(AppDatabase db) async {
    try {
      final latest = await db.getLatestStatistics();
      final now = DateTime.now();
      final shouldRecord = latest == null ||
          now.difference(latest.recordedAt).inHours >= 24;

      if (shouldRecord) {
        await db.recordStatisticsSnapshot();
        loggerGlobal.fine("MainSetup", "Recorded daily statistics snapshot.");
      }
    } catch (e) {
      // Non-fatal — don't block app startup
      loggerGlobal.warning(
          "MainSetup", "Failed to record statistics snapshot: $e");
    }
  }
}
