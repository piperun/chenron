import "package:database/database.dart";
import "package:drift/drift.dart";

abstract class BaseRepository<M extends IncludeOptions<Enum>> {
  final GeneratedDatabase appDb;

  BaseRepository({required this.appDb});

  /// Returns the domain object [T] with the given [id], or null if not found.
  Future<DbResult?> getOne({required String id, M includeOptions});

  /// Returns a list of all domain objects [T].
  Future<List<DbResult>> getAll({required M includeOptions});
}

abstract class BaseWatchRepository<M extends IncludeOptions<Enum>>
    extends BaseRepository<M> {
  BaseWatchRepository({required super.appDb});

  /// Watches (streams) a single domain object [T] with [id].
  /// Emits new values whenever the underlying table data changes.
  Stream<DbResult?> watchOne({required String id, M includeOptions});

  /// Watches all domain objects [T], emitting updates when rows change.
  Stream<List<DbResult>> watchAll({required M includeOptions});
}

abstract class ExtraRepository<M extends IncludeOptions<Enum>>
    extends BaseRepository<M> {
  ExtraRepository({required super.appDb});

  /// Returns a list of all domain objects [T] matching the given [query].
  Future<List<DbResult>> searchTable({required String query, M includeOptions});
}

abstract class RowJoins<T extends Table, R> {
  /// Create join operations for the given relation ID expression
  List<Join> createJoins(Expression<String> relationId);
}
