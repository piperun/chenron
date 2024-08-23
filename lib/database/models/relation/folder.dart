import 'package:drift/drift.dart';
import 'package:chenron/database/models/models.dart';

class FolderLinks extends Table {
  TextColumn get folderId => text().references(Folders, #id)();
  TextColumn get linkId => text().references(Links, #id)();

  @override
  Set<Column> get primaryKey => {folderId, linkId};
}

class FolderDocuments extends Table {
  TextColumn get folderId => text().references(Folders, #id)();
  TextColumn get documentId => text().references(Documents, #id)();

  @override
  Set<Column> get primaryKey => {folderId, documentId};
}

class FolderTags extends Table {
  TextColumn get folderId => text().references(Folders, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {folderId, tagId};
}

class FolderTrees extends Table {
  @ReferenceName('parentFolder')
  TextColumn get parentId => text().references(Folders, #id)();
  @ReferenceName('childFolder')
  TextColumn get childId => text().references(Folders, #id)();
  @override
  Set<Column> get primaryKey => {parentId, childId};
}
