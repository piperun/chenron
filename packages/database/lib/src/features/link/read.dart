import "package:core/patterns/include_options.dart";
import "package:database/main.dart";
import "package:database/models/db_result.dart";
import "package:database/src/core/builders/base_query_builder.dart";
import "package:database/src/core/handlers/read_handler.dart";

extension LinkReadExtensions on AppDatabase {
  Future<LinkResult?> getLink({
    required String linkId,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _LinkReadRepository(db: this)
        .getOne(id: linkId, includeOptions: includeOptions);
  }

  Future<List<LinkResult>> getAllLinks({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return _LinkReadRepository(db: this).getAll(includeOptions: includeOptions);
  }

  Stream<LinkResult?> watchLink({
    required String linkId,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _LinkReadRepository(db: this)
        .watchOne(id: linkId, includeOptions: includeOptions);
  }

  Stream<List<LinkResult>> watchAllLinks({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _LinkReadRepository(db: this)
        .watchAll(includeOptions: includeOptions);
  }

  Future<List<LinkResult>> searchLinks({
    required String query,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return _LinkReadRepository(db: this)
        .searchTable(query: query, includeOptions: includeOptions);
  }
}

class _LinkReadRepository extends BaseRepository<IncludeOptions>
    implements
        BaseWatchRepository<IncludeOptions>,
        ExtraRepository<IncludeOptions> {
  final AppDatabase db;
  final ReadDbHandler<LinkResult> readHandler;

  _LinkReadRepository({required this.db})
      : readHandler = ReadDbHandler<LinkResult>(db: db, table: db.links),
        super(appDb: db);

  @override
  Future<LinkResult?> getOne({
    required String id,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.getOne(
      includeOptions: includeOptions,
      predicate: db.links.id.equals(id),
      joinExp: db.links.id,
    );
  }

  @override
  Future<List<LinkResult>> getAll({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.getAll(
      includeOptions: includeOptions,
      joinExp: db.links.id,
    );
  }

  @override
  Stream<LinkResult?> watchOne({
    required String id,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return readHandler.watchOne(
        includeOptions: includeOptions,
        joinExp: db.links.id,
        predicate: db.links.id.equals(id));
  }

  @override
  Stream<List<LinkResult>> watchAll({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return readHandler.watchAll(
      includeOptions: includeOptions,
      joinExp: db.links.id,
    );
  }

  @override
  Future<List<LinkResult>> searchTable({
    required String query,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.searchTable(
      query: query,
      includeOptions: includeOptions,
      joinExp: db.links.id,
      searchColumn: db.links.path,
    );
  }
}
