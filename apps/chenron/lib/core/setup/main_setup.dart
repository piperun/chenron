// lib/initialization/app_setupr.dart

import "package:chenron/locator.dart";
import "package:chenron/services/drift_metadata_persistence.dart";
import "package:basedir/directory.dart";
import "package:cache_manager/cache_manager.dart";
import "package:database/database.dart";
import "package:database/main.dart" show ConfigIncludes;
import "package:app_logger/app_logger.dart";

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

  static Future<void> setup({String? customAppDbPath}) async {
    // Check if GetIt was reset (indicates test scenario requiring re-init)
    final getItWasReset =
        _setupDone && !locator.isRegistered<Signal<AppDatabaseHandler>>();

    if (_setupDone && !getItWasReset) {
      loggerGlobal.warning(
          "MainSetup", "setup() called more than once.");
      return;
    }

    if (getItWasReset) {
      // GetIt was reset, allow re-initialization
      _setupDone = false;
      if (kDebugMode) {
        debugPrint("MainSetup: GetIt was reset, re-initializing...");
      }
    }

    if (kDebugMode) {
      debugPrint("MainSetup: Starting initialization...");
    }

    try {
      _setupLocator();

      // Resolve base directories first — everything else depends on them.
      final BaseDirectories<ChenronDir> baseDirs =
          await _resolveBaseDirectory();

      // Logging and database setup are independent — run in parallel.
      await Future.wait([
        _setupLogging(baseDirs),
        _setupConfig(baseDirs, customAppDbPath: customAppDbPath),
      ]);
      loggerGlobal.info(
          "MainSetup", "Logging and database setup complete.");

      // Theme registry is fast and synchronous.
      initializeThemeRegistry();
      loggerGlobal.info("MainSetup", "Theme registry initialized.");

      _setupDone = true;
      loggerGlobal.info("MainSetup",
          "Core initialization complete. Deferred tasks pending.");
    } catch (error, stackTrace) {
      // Catch any error bubbling up from the setup steps
      final errorMsg = "Core application initialization failed.";
      // Use debugPrint as a fallback in case logger itself failed during setup
      if (kDebugMode) {
        debugPrint(
            "!!! FATAL INITIALIZATION ERROR: $errorMsg\nError: $error\nStackTrace: $stackTrace");
      }
      // Attempt to log using the logger as well, it might partially work
      loggerGlobal.severe("MainSetup", errorMsg, error, stackTrace);

      // Re-throw a specific exception to signal failure to main.dart
      throw InitializationException(errorMsg,
          cause: error, stackTrace: stackTrace);
    }
  }

  /// Non-critical tasks that run after the UI is visible.
  /// Both are already guarded with try-catch and marked non-fatal.
  static Future<void> runDeferredTasks() async {
    await _startBackupScheduler();
    final appDbHandler = locator.get<Signal<AppDatabaseHandler>>();
    await _recordDailySnapshot(appDbHandler.value.appDatabase);
    loggerGlobal.info("MainSetup", "Deferred tasks complete.");
  }

  static void _setupLocator() {
    try {
      locatorSetup();
    } catch (e, s) {
      // Failure here is likely fatal and happens before logger is ready
      if (kDebugMode) {
        debugPrint(
            "!!! FATAL ERROR: Locator setup failed.\nError: $e\nStackTrace: $s");
      }
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
      if (kDebugMode) {
        debugPrint("!!! FATAL ERROR: $errorMsg\nError: $e\nStackTrace: $s");
      }
      throw InitializationException(errorMsg, cause: e, stackTrace: s);
    }
  }

  static Future<void> _setupConfig(
    BaseDirectories<ChenronDir> baseDirs, {
    String? customAppDbPath,
  }) async {
    try {
      final configHandler = locator.get<Signal<ConfigDatabaseFileHandler>>();
      final databaseLocation = DatabaseLocation(
        databaseDirectory: baseDirs.dir(ChenronDir.database),
        databaseFilename: "config.sqlite",
      );
      configHandler.value.databaseLocation = databaseLocation;
      configHandler.value.createDatabase(setupOnInit: true);

      // Initialize AppDatabase — use custom path if provided and valid,
      // otherwise fall back to the default base directory.
      final appDbHandler = locator.get<Signal<AppDatabaseHandler>>();
      final Directory appDbDir;
      if (customAppDbPath != null &&
          Directory(customAppDbPath).existsSync()) {
        appDbDir = Directory(customAppDbPath);
        loggerGlobal.info("MainSetup",
            "Using custom app database path: $customAppDbPath");
      } else {
        appDbDir = baseDirs.dir(ChenronDir.database);
        if (customAppDbPath != null) {
          loggerGlobal.warning("MainSetup",
              "Custom db path '$customAppDbPath' not found, using default.");
        }
      }
      final appDatabaseLocation = DatabaseLocation(
        databaseDirectory: appDbDir,
        databaseFilename: "app.sqlite",
      );
      appDbHandler.value.databaseLocation = appDatabaseLocation;
      await appDbHandler.value.createDatabase(setupOnInit: true);

      // Connect the metadata cache to the drift database.
      MetadataCache.init(
        DriftMetadataPersistence(appDbHandler.value.appDatabase),
      );
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
      if (kDebugMode) {
        debugPrint("!!! ERROR: $errorMsg\nError: $e\nStackTrace: $s");
      }
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

  static const _defaultBackupIntervalHours = 8;

  static int _parseIntervalHours(String cronExpression) {
    // Hourly pattern: "0 0 */N * * *"
    final hourMatch =
        RegExp(r"^0 0 \*/(\d+) \* \* \*$").firstMatch(cronExpression);
    if (hourMatch != null) return int.parse(hourMatch.group(1)!);

    // Daily pattern: "0 0 0 */N * *"
    final dayMatch =
        RegExp(r"^0 0 0 \*/(\d+) \* \*$").firstMatch(cronExpression);
    if (dayMatch != null) return int.parse(dayMatch.group(1)!) * 24;

    // "0 0 0 * * *" = once per day (24h)
    if (cronExpression == "0 0 0 * * *") return 24;

    return _defaultBackupIntervalHours;
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
