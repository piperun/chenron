import 'package:drift/drift.dart';

class Folders extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get title => text().withLength(min: 6, max: 30)();
  TextColumn get description => text().withLength(min: 0, max: 1000)();

  @override
  Set<Column> get primaryKey => {id};
}

class Links extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get url => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}

class Documents extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get title => text().withLength(min: 6, max: 30)();
  BlobColumn get content => blob()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get name => text().withLength(min: 3, max: 12).unique()();

  @override
  Set<Column> get primaryKey => {id};
}
