import "package:chenron/database/actions/joins/factory.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/base_query_builder.dart";
import "package:drift/drift.dart";

class ReadDbHandler<T> {
  final AppDatabase db;
  final TableInfo table;
  RelationBuilder<T> builder;
  ReadDbHandler({required this.db, required this.table})
      : builder = RelationFactory<T>(db).getRelationBuilder(table);
  Future<T?> getOne({
    required Expression<bool> predicate,
    IncludeItems includes = const {},
  }) async {
    builder.createJoins(includes);
    final query = db.select(table).join(builder.joinList)..where(predicate);
    final rows = await query.get();
    if (rows.isEmpty) {
      return null;
    }

    final results = builder.buildRelations(includes: includes, rows: rows);
    return results.isEmpty ? null : results.first;
  }

  Future<List<T>> getAll({
    IncludeItems includes = const {},
  }) async {
    builder.createJoins(includes);
    final query = db.select(table).join(builder.joinList);
    final rows = await query.get();
    final results = builder.buildRelations(includes: includes, rows: rows);
    return results;
  }

  Stream<T?> watchOne({
    required Expression<bool> predicate,
    IncludeItems includes = const {},
  }) {
    builder.createJoins(includes);
    final query = db.select(table).join(builder.joinList)..where(predicate);

    return query.watch().map((rows) {
      final results = builder.buildRelations(
        includes: includes,
        rows: rows,
      );
      if (results.isEmpty) return null;
      return results.first;
    });
  }

  Stream<List<T>> watchAll({
    IncludeItems includes = const {},
  }) {
    builder.createJoins(includes);
    final query = db.select(db.folders).join(builder.joinList);
    return query.watch().map((rows) => builder.buildRelations(
          includes: includes,
          rows: rows,
        ));
  }

  Future<List<T>> searchTable({
    required String query,
    Set<IncludeOptions> includes = const {},
  }) async {
    builder.createJoins(includes);
    final folders = (db.select(db.folders).join(builder.joinList))
      ..where(db.folders.title.like("%$query%"));

    final rows = await folders.get();
    return builder.buildRelations(
      includes: includes,
      rows: rows,
    );
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
    required Set<IncludeOptions> includes,
    String? folderId,
  }) {
    builder.createJoins(includes);
    final query = db.select(db.folders).join(builder.joinList);
    if (folderId != null) {
      query.where(db.folders.id.equals(folderId));
    }
    return query;
  }
}
