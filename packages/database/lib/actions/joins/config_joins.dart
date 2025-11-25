import "package:database/actions/builders/config_result_builder_factory.dart";
import "package:database/actions/builders/result_builder.dart";
import "package:database/actions/joins/relation_builder.dart";
import "package:database/database.dart";
import "package:database/extensions/base_query_builder.dart";
import "package:database/schema/user_config_schema.dart";
import "package:database/models/db_result.dart";
import "package:drift/drift.dart";

class ConfigRelationBuilder<T extends DbResult> extends RelationBuilder<T> {
  ConfigRelationBuilder(ConfigDatabase db)
      : super(db, {
          ConfigIncludes.backupSettings: BackupSettingsJoins(db),
          ConfigIncludes.userThemes: UserThemesJoins(db),
        });

  @override
  List<Join> createQueryJoins(
      IncludeOptions<Enum> includeOptions, Expression<String> joinExp) {
    final joins = <Join>[];
    for (final option in includeOptions.options) {
      final join = rowJoins[option];
      if (join != null) {
        joins.addAll(join.createJoins(joinExp));
      }
    }
    return joins;
  }

  @override
  List<T> processQueryResults({
    required List<TypedResult?> rows,
    required TableInfo mainTable,
    required IncludeOptions<Enum> includeOptions,
  }) {
    final builderFactory = ConfigResultBuilderFactory(db as ConfigDatabase);
    final Map<String, ResultBuilder<T>> builders = {};

    // Process each row
    for (final row in rows.whereType<TypedResult>()) {
      final entity = row.readTable(mainTable);
      final entityId = (entity as dynamic).id as String;

      // Get or create builder for this entity
      final builder = builders.putIfAbsent(
          entityId,
          () =>
              builderFactory.createBuilder(row, mainTable) as ResultBuilder<T>);

      // Let the builder process this row
      builder.processRow(row, includeOptions.options);
    }

    // Build final results
    final results = builders.values.map((builder) => builder.build()).toList();
    return results;
  }
}

class BackupSettingsJoins implements RowJoins<BackupSettings, BackupSetting> {
  final ConfigDatabase db;

  BackupSettingsJoins(this.db);

  @override
  List<Join> createJoins(Expression<String> relationId) {
    return [
      leftOuterJoin(
          db.backupSettings, db.backupSettings.id.equalsExp(relationId)),
    ];
  }
}

class UserThemesJoins implements RowJoins<UserThemes, UserTheme> {
  final ConfigDatabase db;

  UserThemesJoins(this.db);

  @override
  List<Join> createJoins(Expression<String> relationId) {
    return [
      leftOuterJoin(
          db.userThemes, db.userThemes.userConfigId.equalsExp(relationId)),
    ];
  }
}


