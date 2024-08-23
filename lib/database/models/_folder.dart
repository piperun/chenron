import 'package:drift/drift.dart';

class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get type =>
      text()(); // To store the type of data (link, document, folder)
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

class FolderTags extends Table {
  IntColumn get folderId => integer().references(Folders, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {folderId, tagId}
      ];
}

class Links extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId => integer().references(Folders, #id)();
  TextColumn get url => text()();
  TextColumn get comment => text()();
}

class LinkTags extends Table {
  IntColumn get linkId => integer().references(Links, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {linkId, tagId}
      ];
}

class Documents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId => integer().references(Folders, #id)();
  TextColumn get title => text()();
  BlobColumn get content => blob()(); // Store binary data or JSON as a blob
}
