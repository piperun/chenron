import "package:drift/drift.dart";

/// Queue of pending/in-progress background operations.
///
/// Originally introduced as the archive job queue; generalized to also
/// track metadata fetches and other background work.
///
/// - Archive jobs are created when a folder is saved with links. A
///   background processor picks them up and runs archiving asynchronously.
/// - Metadata fetch entries are written by [MetadataFactory] for failures
///   and first-time fetches so the user can see what scraping failed.
///
/// [linkId] is nullable: not every job is tied to a single link. The
/// startup metadata refresh pass iterates the metadata cache (keyed by
/// URL), not the links table, so there's no canonical linkId.
@TableIndex(
    name: "background_jobs_status_created_idx",
    columns: {#status, #createdAt})
class BackgroundJobs extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get linkId => text().nullable()();
  TextColumn get url => text()();
  TextColumn get service =>
      text()(); // "archive_org", "archive_is", "metadata_fetch"
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
