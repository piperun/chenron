import "package:database/actions/builders/result_builder.dart";
import "package:database/actions/builders/app_database/folder_result_builder.dart";
import "package:database/actions/builders/app_database/link_result_builder.dart";
import "package:database/actions/builders/app_database/document_result_builder.dart";
import "package:database/actions/builders/app_database/tag_result_builder.dart";
import "package:database/database.dart";
import "package:database/models/db_result.dart";
import "package:drift/drift.dart";

class ResultBuilderFactory {
  final AppDatabase _db;

  ResultBuilderFactory(this._db);

  ResultBuilder<DbResult> createBuilder(TypedResult row, TableInfo mainTable) {
    final entity = row.readTable(mainTable);

    if (entity is Folder) {
      return FolderResultBuilder(entity, _db);
    } else if (entity is Link) {
      return LinkResultBuilder(entity, _db);
    } else if (entity is Document) {
      return DocumentResultBuilder(entity, _db);
    } else if (entity is Tag) {
      return TagResultBuilder(entity, _db);
    }

    throw ArgumentError("Unsupported entity type: ${entity.runtimeType}");
  }
}


