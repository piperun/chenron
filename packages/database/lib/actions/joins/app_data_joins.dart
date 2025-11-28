import "package:database/actions/builders/result_builder.dart";
import "package:database/actions/builders/result_builder_factory.dart";
import "package:database/actions/joins/relation_builder.dart";
import "package:database/actions/joins/tag.dart";
import "package:database/actions/joins/item.dart";
import "package:database/database.dart";
import "package:drift/drift.dart";

class AppDataRelationBuilder<T extends DbResult> extends RelationBuilder<T> {
  AppDataRelationBuilder(AppDatabase db)
      : super(db, {
          AppDataInclude.tags: TagJoins(db),
          AppDataInclude.items: ItemJoins(db),
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
    final builderFactory = ResultBuilderFactory(db as AppDatabase);
    final Map<String, ResultBuilder<T>> builders = {};

    for (final row in rows.whereType<TypedResult>()) {
      final entity = row.readTable(mainTable);
      final entityId = (entity as dynamic).id as String;

      final builder = builders.putIfAbsent(
          entityId,
          () =>
              builderFactory.createBuilder(row, mainTable) as ResultBuilder<T>);

      builder.processRow(row, includeOptions.options);
    }

    final results = builders.values.map((builder) => builder.build()).toList();
    return results;
  }
}


