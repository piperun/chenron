import "package:chenron/database/actions/builders/result_builder.dart";
import "package:chenron/database/actions/builders/result/user_config_result_builder.dart";
import "package:chenron/database/database.dart";
import "package:chenron/models/db_result.dart";
import "package:drift/drift.dart";

class ConfigResultBuilderFactory {
  final ConfigDatabase _db;

  ConfigResultBuilderFactory(this._db);

  ResultBuilder<DbResult> createBuilder(TypedResult row, TableInfo mainTable) {
    final entity = row.readTable(mainTable);

    if (entity is UserConfig) {
      return UserConfigResultBuilder(entity, _db);
    }

    throw ArgumentError(
        'Unsupported config entity type: ${entity.runtimeType}');
  }
}
