import "package:core/patterns/include_options.dart";
import "package:database/main.dart";
import "package:database/models/db_result.dart";
import "package:database/src/core/joins/relation_builder.dart";

import "package:drift/drift.dart";

class ReadDbHandler<T extends DbResult> {
  final GeneratedDatabase db;
  final TableInfo table;
  final RelationBuilder<T> relationBuilder;

  ReadDbHandler({required this.db, required this.table})
      : relationBuilder = db is AppDatabase
            ? RelationBuilder<T>.forAppDatabase(db)
            : RelationBuilder<T>.forConfigDatabase(db as ConfigDatabase);

  Future<T?> getOne({
    required Expression<bool> predicate,
    required Expression<String> joinExp,
    required IncludeOptions<Enum> includeOptions,
  }) async {
    final query = _buildQuery(
      includeOptions: includeOptions,
      joinExp: joinExp,
      predicate: predicate,
    );
    final rows = await query.get();
    if (rows.isEmpty) {
      return null;
    }

    final List<T> results = relationBuilder.processQueryResults(
        includeOptions: includeOptions, mainTable: table, rows: rows);

    return results.isEmpty ? null : results.first;
  }

  Future<List<T>> getAll({
    required IncludeOptions<Enum> includeOptions,
    required Expression<String> joinExp,
  }) async {
    final query = _buildQuery(
      includeOptions: includeOptions,
      joinExp: joinExp,
    );
    final rows = await query.get();

    final List<T> results = relationBuilder.processQueryResults(
        includeOptions: includeOptions, mainTable: table, rows: rows);
    return results;
  }

  Stream<T?> watchOne({
    required Expression<bool> predicate,
    required Expression<String> joinExp,
    required IncludeOptions<Enum> includeOptions,
  }) {
    final query = _buildQuery(
      includeOptions: includeOptions,
      joinExp: joinExp,
      predicate: predicate,
    );

    return query.watch().map((rows) {
      final List<T> results = relationBuilder.processQueryResults(
          includeOptions: includeOptions, mainTable: table, rows: rows);
      if (results.isEmpty) return null;
      return results.first;
    });
  }

  Stream<List<T>> watchAll({
    required IncludeOptions<Enum> includeOptions,
    required Expression<String> joinExp,
  }) {
    final query = _buildQuery(
      includeOptions: includeOptions,
      joinExp: joinExp,
    );

    return query.watch().map((rows) => relationBuilder.processQueryResults(
        includeOptions: includeOptions, mainTable: table, rows: rows));
  }

  Future<List<T>> searchTable({
    required String query,
    required Expression<String> joinExp,
    required GeneratedColumn<String>? searchColumn,
    required IncludeOptions<Enum> includeOptions,
  }) async {
    if (searchColumn == null) {
      throw Exception("Search column cannot be null");
    }

    final folders = _buildQuery(
      includeOptions: includeOptions,
      joinExp: joinExp,
      predicate: searchColumn.like("%$query%"),
    );

    final rows = await folders.get();
    return relationBuilder.processQueryResults(
        includeOptions: includeOptions, mainTable: table, rows: rows);
  }

  // Utility method that builds a query with common options
  JoinedSelectStatement<HasResultSet, dynamic> _buildQuery({
    required IncludeOptions<Enum> includeOptions,
    required Expression<String> joinExp,
    Expression<bool>? predicate,
  }) {
    final List<Join<HasResultSet, dynamic>> joinsList =
        relationBuilder.createQueryJoins(includeOptions, joinExp);
    final query = db.select(table).join(joinsList);
    if (predicate != null) {
      query.where(predicate);
    }
    return query;
  }
}
