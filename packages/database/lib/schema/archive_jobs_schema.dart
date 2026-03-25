import "package:drift/drift.dart";

/// Queue of pending/in-progress archive operations.
///
/// Jobs are created when a folder is saved with links. A background
/// processor picks them up and runs archiving asynchronously.
@TableIndex(name: "archive_jobs_status_created_idx", columns: {#status, #createdAt})
class ArchiveJobs extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get linkId => text()();
  TextColumn get url => text()();
  TextColumn get service => text()(); // "archive_org" or "archive_is"
  TextColumn get status =>
      text().withDefault(const Constant("queued"))(); // queued, in_progress, completed, failed
  TextColumn get resultUrl => text().nullable()();
  TextColumn get error => text().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
