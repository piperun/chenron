import "package:drift/drift.dart";
import "package:database/models/document_file_type.dart";

@TableIndex(name: "folder_title", columns: {#title})
class Folders extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get title => text().withLength(min: 6, max: 30)();
  TextColumn get description => text().withLength(min: 0, max: 1000)();
  IntColumn get color => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Links extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get path => text().withLength(min: 10, max: 2048).unique()();
  TextColumn get archiveOrgUrl =>
      text().withLength(min: 10, max: 2048).nullable()();
  TextColumn get archiveIsUrl =>
      text().withLength(min: 10, max: 2048).nullable()();
  TextColumn get localArchivePath =>
      text().withLength(min: 10, max: 2048).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: "document_title", columns: {#title})
class Documents extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get title => text().withLength(min: 6, max: 100)();
  TextColumn get filePath => text().unique()();
  TextColumn get fileType => textEnum<DocumentFileType>()();
  IntColumn get fileSize => integer().nullable()();
  TextColumn get checksum => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get name => text().withLength(min: 3, max: 12).unique()();
  IntColumn get color => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: "items_folder_item_idx", columns: {#folderId, #itemId}, unique: true)
class Items extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get folderId => text().references(Folders, #id)();
  TextColumn get itemId => text()();
  IntColumn get typeId => integer().references(ItemTypes, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

class ItemTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class MetadataRecords extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get typeId => integer().references(MetadataTypes, #id)();
  TextColumn get itemId => text()();
  TextColumn get metadataId => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MetadataTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class Statistics extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  // Item counts
  IntColumn get totalLinks => integer().withDefault(const Constant(0))();
  IntColumn get totalDocuments => integer().withDefault(const Constant(0))();
  IntColumn get totalTags => integer().withDefault(const Constant(0))();
  IntColumn get totalFolders => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tracks individual user activity events (create, delete, view, edit, archive)
class ActivityEvents extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  DateTimeColumn get occurredAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get eventType => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Persistent cache of fetched web metadata (OG title, description, image).
/// Keyed by URL — this is a cache table, not a relational entity.
class WebMetadataEntries extends Table {
  TextColumn get url => text()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get image => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {url};
}

/// Tracks when each item was last accessed (for "recently viewed" features)
class RecentAccess extends Table {
  TextColumn get entityId => text()();
  TextColumn get entityType => text()();
  DateTimeColumn get lastAccessedAt => dateTime()();
  IntColumn get accessCount => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {entityId, entityType};
}
