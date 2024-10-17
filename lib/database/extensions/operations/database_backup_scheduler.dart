import "package:cron/cron.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/utils/logger.dart";

class DatabaseBackupScheduler {
  final AppDatabaseHandler databaseHandler;
  Cron? _cron;

  DatabaseBackupScheduler({required this.databaseHandler});

  void start() {
    _cron = Cron();
    // Schedule the backup to run every 8 hours
    _cron!.schedule(Schedule.parse("0 0 */8 * * *"), () async {
      try {
        await databaseHandler.backupDatabase();
        loggerGlobal.info(
          "DatabaseBackupScheduler",
          "Database backup completed successfully.",
        );
      } catch (e) {
        loggerGlobal.warning(
          "DatabaseBackupScheduler",
          "An error occurred during scheduled database backup: $e",
        );
      }
    });
  }

  void stop() {
    _cron?.close();
    _cron = null;
  }
}
