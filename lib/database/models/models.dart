import 'package:drift/drift.dart';

class Folders extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get title => text().withLength(min: 6, max: 30)();
  TextColumn get description => text().withLength(min: 0, max: 1000)();

  @override
  Set<Column> get primaryKey => {id};
}

class Links extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get url => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}

class Documents extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get title => text().withLength(min: 6, max: 30)();
  BlobColumn get content => blob()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get name => text().withLength(min: 3, max: 12).unique()();

  @override
  Set<Column> get primaryKey => {id};
}

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
