import "package:chenron/database/actions/joins/item.dart";
import "package:chenron/database/actions/joins/tag.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/base_query_builder.dart";
import "package:chenron/models/item.dart";
import "package:drift/drift.dart";

class Result<T> {
  final T data;
  Set<Tag> tags;
  Set<FolderItem> items;
  Result({
    required this.data,
    Set<Tag>? tags,
    Set<FolderItem>? items,
  })  : tags = tags ?? {},
        items = items ?? {};
}

class ReadDbHandler<T> {
  final AppDatabase db;
  final TableInfo table;
  NewRelationBuilder<T> testBuilder;
  ReadDbHandler({required this.db, required this.table})
      : testBuilder = NewRelationBuilder(db);
  Future<Result<T>?> getOne({
    required Expression<bool> predicate,
    required Expression<String> joinExp,
    IncludeItems includes = const {},
  }) async {
    List<Join<HasResultSet, dynamic>> joinsList =
        testBuilder.createQueryJoins(includes, joinExp);
    final query = db.select(table).join(joinsList)..where(predicate);
    final rows = await query.get();
    if (rows.isEmpty) {
      return null;
    }
    final List<Result<T>> results = testBuilder.processQueryResults(
        includes: includes, mainTable: table, rows: rows);

    return results.isEmpty ? null : results.first;
  }

  Future<List<Result<T>>> getAll({
    IncludeItems includes = const {},
    required Expression<String> joinExp,
  }) async {
    List<Join<HasResultSet, dynamic>> joinsList =
        testBuilder.createQueryJoins(includes, joinExp);
    final query = db.select(table).join(joinsList);
    final rows = await query.get();
    final List<Result<T>> results = testBuilder.processQueryResults(
        includes: includes, mainTable: table, rows: rows);
    return results;
  }

  Stream<Result<T>?> watchOne({
    required Expression<bool> predicate,
    required Expression<String> joinExp,
    IncludeItems includes = const {},
  }) {
    List<Join<HasResultSet, dynamic>> joinsList =
        testBuilder.createQueryJoins(includes, joinExp);
    final query = db.select(table).join(joinsList)..where(predicate);

    return query.watch().map((rows) {
      final List<Result<T>> results = testBuilder.processQueryResults(
          includes: includes, mainTable: table, rows: rows);
      if (results.isEmpty) return null;
      return results.first;
    });
  }

  Stream<List<Result<T>>> watchAll({
    IncludeItems includes = const {},
    required Expression<String> joinExp,
  }) {
    List<Join<HasResultSet, dynamic>> joinsList =
        testBuilder.createQueryJoins(includes, joinExp);
    final query = db.select(table).join(joinsList);
    return query.watch().map((rows) => testBuilder.processQueryResults(
        includes: includes, mainTable: table, rows: rows));
  }

  Future<List<Result<T>>> searchTable({
    required String query,
    required Expression<String> joinExp,
    required GeneratedColumn<String>? searchColumn,
    IncludeItems includes = const {},
  }) async {
    if (searchColumn == null) {
      throw Exception("Search column cannot be null");
    }
    List<Join<HasResultSet, dynamic>> joinsList =
        testBuilder.createQueryJoins(includes, joinExp);
    final folders = (db.select(table).join(joinsList))
      ..where(searchColumn.like("%$query%"));

    final rows = await folders.get();
    return testBuilder.processQueryResults(
        includes: includes, mainTable: table, rows: rows);
  }

  //unimplemented for now, incase data gets big enough to require segmented fetching instead of joining
  Future<R?> getOneSegmented<$Table extends Table, R extends DataClass>(
    TableInfo<$Table, R> table,
    Expression<bool> Function($Table t) filter,
  ) async {
    return (db.select(table)..where(filter)).getSingleOrNull();
  }

// NOTE: Might be used later if we want to remove more duplicate code
  Selectable<TypedResult> _buildQuery({
    required IncludeItems includes,
    required Expression<String> joinExp,
    required Expression<bool> predicate,
    String? folderId,
  }) {
    List<Join<HasResultSet, dynamic>> joinsList =
        testBuilder.createQueryJoins(includes, joinExp);
    final query = db.select(table).join(joinsList);
    if (folderId != null) {
      query.where(predicate);
    }
    return query;
  }
}

class NewRelationBuilder<T> {
  final AppDatabase db;
  final Map<IncludeOptions, RowJoins> rowJoins;

  NewRelationBuilder(this.db)
      : rowJoins = {
          IncludeOptions.tags: TagJoins(db),
          IncludeOptions.items: ItemJoins(db),
        };

  List<Join> createQueryJoins(
      IncludeItems includes, Expression<String> joinExp) {
    final joins = <Join>[];
    if (includes.contains(IncludeOptions.tags)) {
      joins.addAll(rowJoins[IncludeOptions.tags]!.createJoins(joinExp));
    }
    if (includes.contains(IncludeOptions.items)) {
      joins.addAll(rowJoins[IncludeOptions.items]!.createJoins(joinExp));
    }
    return joins;
  }

  List<Result<T>> processQueryResults({
    required List<TypedResult?> rows,
    required TableInfo mainTable,
    required IncludeItems includes,
  }) {
    final resultMap = <String, Result<T>>{};

    for (final row in rows.whereType<TypedResult>()) {
      final entityData = row.readTable(mainTable) as T;
      final entityId = (entityData as dynamic).id as String;

      final result =
          resultMap.putIfAbsent(entityId, () => Result<T>(data: entityData));

      for (final include in includes) {
        final join = rowJoins[include];
        if (join == null) continue;

        switch (include) {
          case IncludeOptions.tags:
            final tag = join.readJoins(row);
            if (tag != null) result.tags.add(tag as Tag);
            break;
          case IncludeOptions.items:
            final item = join.readJoins(row);
            if (item != null) result.items.add(item as FolderItem);
            break;
        }
      }
    }

    return resultMap.values.toList();
  }
}
