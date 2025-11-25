import "package:database/actions/builders/result_builder.dart";
import "package:database/actions/builders/config_database/user_config_result_builder.dart";
import "package:database/actions/builders/config_database/user_theme_result_builder.dart";
import "package:database/database.dart";
import "package:database/models/db_result.dart";
import "package:drift/drift.dart";

class ConfigResultBuilderFactory {
  final ConfigDatabase _db;

  ConfigResultBuilderFactory(this._db);

  ResultBuilder<DbResult> createBuilder(TypedResult row, TableInfo mainTable) {
    if (mainTable == _db.userConfigs) {
      final userConfig = row.readTable(_db.userConfigs);
      return UserConfigResultBuilder(userConfig, _db);
    } else if (mainTable == _db.backupSettings) {
      // Handle BackupSettings if it can be a main entity
      // return BackupSettingsResultBuilder(...);
      throw UnimplementedError(
          "Builder for BackupSettings as main entity not implemented.");
    } else if (mainTable == _db.userThemes) {
      final userTheme = row.readTable(_db.userThemes);
      return UserThemeResultBuilder(userTheme, _db);
    }
    // Add cases for other potential main tables (e.g., ArchiveSettings)

    throw ArgumentError(
        "Unsupported config entity type for mainTable: ${mainTable.entityName}");
  }
}


