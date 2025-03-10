import "package:chenron/database/extensions/base_query_builder.dart";
import "package:chenron/database/actions/handlers/read_handler.dart";
import "package:chenron/database/database.dart";

extension LinkReadExtensions on AppDatabase {
  Future<Result<Link>?> getLink({
    required String linkId,
    IncludeItems modes = const {},
  }) {
    return _LinkReadRepository(db: this).getOne(id: linkId, modes: modes);
  }

  Future<List<Result<Link>>> getAllLinks({
    IncludeItems modes = const {},
  }) async {
    return _LinkReadRepository(db: this).getAll(modes: modes);
  }

  Stream<Result<Link>?> watchLink({
    required String linkId,
    IncludeItems modes = const {},
  }) {
    return _LinkReadRepository(db: this).watchOne(id: linkId, modes: modes);
  }

  Stream<List<Result<Link>>> watchAllLinks({
    IncludeItems modes = const {},
  }) {
    return _LinkReadRepository(db: this).watchAll(modes: modes);
  }

  Future<List<Result<Link>>> searchLinks({
    required String query,
    IncludeItems modes = const {},
  }) async {
    return _LinkReadRepository(db: this)
        .searchTable(query: query, modes: modes);
  }
}

class _LinkReadRepository extends BaseRepository<Link, IncludeItems>
    implements
        BaseWatchRepository<Link, IncludeItems>,
        ExtraRepository<Link, IncludeItems> {
  final AppDatabase db;
  final ReadDbHandler<Link> readHandler;

  _LinkReadRepository({required this.db})
      : readHandler = ReadDbHandler<Link>(db: db, table: db.links),
        super(appDb: db);

  @override
  Future<Result<Link>?> getOne({
    required String id,
    IncludeItems modes = const {},
  }) async {
    return readHandler.getOne(
      includes: modes,
      predicate: db.links.id.equals(id),
      joinExp: db.links.id,
    );
  }

  @override
  Future<List<Result<Link>>> getAll({
    IncludeItems modes = const {},
  }) async {
    return readHandler.getAll(
      includes: modes,
      joinExp: db.links.id,
    );
  }

  @override
  Stream<Result<Link>?> watchOne({
    required String id,
    IncludeItems modes = const {},
  }) {
    return readHandler.watchOne(
        includes: modes,
        joinExp: db.links.id,
        predicate: db.links.id.equals(id));
  }

  @override
  Stream<List<Result<Link>>> watchAll({
    IncludeItems modes = const {},
  }) {
    return readHandler.watchAll(
      includes: modes,
      joinExp: db.links.id,
    );
  }

  @override
  Future<List<Result<Link>>> searchTable({
    required String query,
    IncludeItems modes = const {},
  }) async {
    return readHandler.searchTable(
      query: query,
      includes: modes,
      joinExp: db.links.id,
      searchColumn: db.links.content,
    );
  }
}
