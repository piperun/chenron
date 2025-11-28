import "package:database/database.dart";
import "package:database/extensions/base_query_builder.dart";
import "package:drift/drift.dart";
import "package:database/actions/joins/app_data_joins.dart";
import "package:database/actions/joins/config_joins.dart";

/// Base abstract class for relation builders
abstract class RelationBuilder<T extends DbResult> {
  final GeneratedDatabase db;
  final Map<Enum, RowJoins> rowJoins;

  RelationBuilder(this.db, this.rowJoins);

  /// Factory constructor for AppDatabase
  factory RelationBuilder.forAppDatabase(AppDatabase db) =
      AppDataRelationBuilder<T>;

  /// Factory constructor for ConfigDatabase
  factory RelationBuilder.forConfigDatabase(ConfigDatabase db) =
      ConfigRelationBuilder<T>;

  /// Creates joins for a query based on include options
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

  /// Process query results into domain objects
  List<T> processQueryResults({
    required List<TypedResult?> rows,
    required TableInfo mainTable,
    required IncludeOptions<Enum> includeOptions,
  });
}
