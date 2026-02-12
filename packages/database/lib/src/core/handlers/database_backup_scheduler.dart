import "package:cron/cron.dart";
import "package:crypto/crypto.dart";
import "package:database/src/core/handlers/config_file_handler.dart";
import "package:database/src/core/handlers/database_file_handler.dart";
import "package:database/src/features/backup_settings/update.dart";
import "package:app_logger/app_logger.dart";

class DatabaseBackupScheduler {
  final AppDatabaseHandler databaseHandler;
  final ConfigDatabaseFileHandler configHandler;

  Cron? _cron;
  String? _currentInterval;
  String? _backupSettingsId;
  String? _lastBackupChecksum;

  DatabaseBackupScheduler({
    required this.databaseHandler,
    required this.configHandler,
  });

  bool get isRunning => _cron != null;
  String? get currentInterval => _currentInterval;

  /// Start or restart the scheduler with a cron expression.
  /// Pass null to stop scheduling (backup disabled).
  Future<void> start({
    required String? cronExpression,
    required String backupSettingsId,
  }) async {
    await stop();

    _backupSettingsId = backupSettingsId;

    if (cronExpression == null || cronExpression.isEmpty) {
      loggerGlobal.info(
          "DatabaseBackupScheduler", "Backup scheduling disabled.");
      return;
    }

    _currentInterval = cronExpression;
    _cron = Cron();
    _cron!.schedule(Schedule.parse(cronExpression), () async {
      await runBackup();
    });

    loggerGlobal.info("DatabaseBackupScheduler",
        "Backup scheduler started with interval: $cronExpression");
  }

  /// Run a backup immediately (used at startup catch-up or on-demand).
  ///
  /// After creating the backup file, computes its SHA-256 checksum and
  /// compares against the previous backup. If the checksums match the
  /// backup file is deleted to avoid accumulating identical copies.
  Future<void> runBackup() async {
    try {
      final backupFile = await databaseHandler.backupDatabase();

      if (backupFile != null) {
        final bytes = await backupFile.readAsBytes();
        final checksum = sha256.convert(bytes).toString();

        if (checksum == _lastBackupChecksum) {
          await backupFile.delete();
          loggerGlobal.info("DatabaseBackupScheduler",
              "Backup skipped — database unchanged since last backup.");
          return;
        }

        _lastBackupChecksum = checksum;
      }

      if (_backupSettingsId != null) {
        await configHandler.configDatabase.updateBackupSettings(
          id: _backupSettingsId!,
          lastBackupTimestamp: DateTime.now(),
        );
      }

      loggerGlobal.info(
          "DatabaseBackupScheduler", "Database backup completed.");
    } catch (e) {
      loggerGlobal.warning("DatabaseBackupScheduler",
          "Error during scheduled database backup: $e");
    }
  }

  /// Stop the scheduler.
  Future<void> stop() async {
    await _cron?.close();
    _cron = null;
    _currentInterval = null;
    _lastBackupChecksum = null;
  }
}
