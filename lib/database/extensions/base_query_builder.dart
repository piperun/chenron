// Base class with only required methods
import "package:chenron/database/database.dart";
import "package:drift/drift.dart";
import "package:rxdart/rxdart.dart";

abstract class BaseRepository<T, M extends Set<Enum>> {
  final AppDatabase appDb;

  BaseRepository({required this.appDb});

  /// Returns the domain object [T] with the given [id], or null if not found.
  Future<T?> getOne({required String id, M modes});

  /// Returns a list of all domain objects [T].
  Future<List<T>> getAll({required M modes});
}

abstract class BaseWatchRepository<T, M extends Set<Enum>>
    extends BaseRepository<T, M> {
  BaseWatchRepository({required super.appDb});

  /// Watches (streams) a single domain object [T] with [id].
  /// Emits new values whenever the underlying table data changes.
  Stream<T?> watchOne({required String id, M modes});

  /// Watches all domain objects [T], emitting updates when rows change.
  Stream<List<T>> watchAll({required M modes});
}

abstract class ExtraRepository<T, M extends Set<Enum>>
    extends BaseRepository<T, M> {
  ExtraRepository({required super.appDb});

  /// Returns a list of all domain objects [T] matching the given [query].
  Future<List<T>> searchTable({required String query, M modes});
}

abstract class BaseQueryBuilder<T, R> {
  final AppDatabase appDb;
  final String? baseId;

  BaseQueryBuilder({
    required this.appDb,
    this.baseId,
  });

  // Skeleton methods
  Future<T?> querySingle();
  Future<List<T>> queryAll();
  Future<R?> buildResult(T? item);

  // Optional new method for building a shared query.
  // If you don’t want to force all subclasses to have “buildQuery,”
  // you might make this non-abstract or protected.
  Selectable<TypedResult> buildQuery({bool single = false}) {
    // By default, return an empty query or throw.
    // Child classes override this to do something meaningful.
    throw UnimplementedError("buildQuery is not implemented");
  }

  // Public methods
  Future<R?> getSingle() async {
    if (baseId == null) {
      throw ArgumentError("An id must be provided to get a single item");
    }

    final item = await querySingle();
    return item != null ? await buildResult(item) : null;
  }

  Future<List<R>> getAll() async {
    final items = await queryAll();
    final results = <R>[];
    R? result;
    for (final item in items) {
      result = await buildResult(item);
      if (result != null) {
        results.add(result);
      }
    }
    return results;
  }
}

mixin BaseWatchQueryBuilder<T, R> on BaseQueryBuilder<T, R> {
  Stream<T?> queryWatchSingle();
  Stream<List<T>> queryWatchAll();
  Stream<R?> buildStreamResult(Stream<T?> itemStream);

  Stream<R?> watchSingle() {
    if (baseId == null) {
      throw ArgumentError("An id must be provided for watching a single item");
    }
    return buildStreamResult(queryWatchSingle());
  }

  Stream<List<R>> watchAll() {
    return queryWatchAll().switchMap((items) {
      final streams = items.map((item) {
        return buildStreamResult(Stream.value(item))
            .where((r) => r != null)
            .map((r) => r!);
      });

      return streams.isEmpty
          ? Stream.value(<R>[])
          : Rx.combineLatestList(streams);
    });
  }
}
mixin ExtendedQueryBuilder<T, R> on BaseQueryBuilder<T, R> {
  Future<List<T>> querySearch(String query);

  Future<List<R>> searchItems(String query) async {
    final items = await querySearch(query);
    final results = <R>[];
    R? result;
    for (final item in items) {
      result = await buildResult(item);
      if (result != null) {
        results.add(result);
      }
    }
    return results;
  }
}

// A generic interface (or abstract class) that each table-specific builder must implement
abstract class IJoinBuilder<T extends Table, R> {
  // Takes a set of "includes" (e.g. tags, items, etc.) and returns joins
  List<Join> buildJoins(Set<IncludeOptions> includes);

  // Returns the base table (folders, links, etc.) associated with this builder
  TableInfo<T, R> get baseTable;
}

abstract class RowJoins<T extends Table, R> {
  // Takes a set of "includes" (e.g. tags, items, etc.) and returns joins
  List<Join> joins(Expression<String> relationId);

  R? readJoins(TypedResult? row);
}

abstract class RelationBuilder<T> {
  abstract final List<Join> joinList;
  void createJoins(Set<IncludeOptions> includes);
  List<T> buildRelations({
    required List<TypedResult?> rows,
    Set<IncludeOptions> includes,
  });
}
