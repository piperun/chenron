import "package:drift/drift.dart";

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
  TextColumn get filePath =>
      text().unique()(); // Relative path to document file
  TextColumn get mimeType => text()(); // 'text/markdown' or 'text/typst'
  IntColumn get fileSize => integer().nullable()(); // File size in bytes
  TextColumn get checksum => text().nullable()(); // SHA-256 hash for integrity

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

@TableIndex(name: "items_folder_item_idx", columns: {#folderId, #itemId})
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
