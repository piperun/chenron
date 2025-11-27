import "package:database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:logger/logger.dart";
import "package:cron/cron.dart";
import "package:signals/signals_flutter.dart";

// Initialize the Cron instance
final Cron cron = Cron();

void scheduleBackup() {
  // yes I am too noob for cron or maybe I'm just lazy screw ya'll it's feature freeze time 🧊
  cron.schedule(Schedule.parse(Schedule(hours: 8, minutes: 0).toCronString()),
      () async {
    await backupDatabase();
  });
}

Future<void> backupDatabase() async {
  // Your backupDatabase implementation
  final appDatabaseHandler =
      locator.get<Signal<AppDatabaseHandler>>().value;
  try {
    final result = await appDatabaseHandler.backupDatabase();
    if (result != null) {
      loggerGlobal.info("AppDatabaseBackupScheduler",
          "Backup at ${DateTime.now()} successful: ${result.path}");
    }
  } catch (e) {
    loggerGlobal.info("AppDatabaseBackupScheduler",
        "An error occurred during database backup: $e");
  }
}

