import "package:database/extensions/base_query_builder.dart";
import "package:database/actions/handlers/read_handler.dart";
import "package:database/database.dart";

extension DocumentReadExtensions on AppDatabase {
  Future<DocumentResult?> getDocument({
    required String documentId,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _DocumentReadRepository(db: this)
        .getOne(id: documentId, includeOptions: includeOptions);
  }

  Future<List<DocumentResult>> getAllDocuments({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return _DocumentReadRepository(db: this)
        .getAll(includeOptions: includeOptions);
  }

  Stream<DocumentResult?> watchDocument({
    required String documentId,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _DocumentReadRepository(db: this)
        .watchOne(id: documentId, includeOptions: includeOptions);
  }

  Stream<List<DocumentResult>> watchAllDocuments({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _DocumentReadRepository(db: this)
        .watchAll(includeOptions: includeOptions);
  }

  Future<List<DocumentResult>> searchDocuments({
    required String query,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return _DocumentReadRepository(db: this)
        .searchTable(query: query, includeOptions: includeOptions);
  }
}

class _DocumentReadRepository extends BaseRepository<IncludeOptions>
    implements
        BaseWatchRepository<IncludeOptions>,
        ExtraRepository<IncludeOptions> {
  final AppDatabase db;
  final ReadDbHandler<DocumentResult> readHandler;

  _DocumentReadRepository({required this.db})
      : readHandler =
            ReadDbHandler<DocumentResult>(db: db, table: db.documents),
        super(appDb: db);

  @override
  Future<DocumentResult?> getOne({
    required String id,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.getOne(
      includeOptions: includeOptions,
      predicate: db.documents.id.equals(id),
      joinExp: db.documents.id,
    );
  }

  @override
  Future<List<DocumentResult>> getAll({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.getAll(
      includeOptions: includeOptions,
      joinExp: db.documents.id,
    );
  }

  @override
  Stream<DocumentResult?> watchOne({
    required String id,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return readHandler.watchOne(
        includeOptions: includeOptions,
        joinExp: db.documents.id,
        predicate: db.documents.id.equals(id));
  }

  @override
  Stream<List<DocumentResult>> watchAll({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return readHandler.watchAll(
      includeOptions: includeOptions,
      joinExp: db.documents.id,
    );
  }

  @override
  Future<List<DocumentResult>> searchTable({
    required String query,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.searchTable(
      query: query,
      includeOptions: includeOptions,
      joinExp: db.documents.id,
      searchColumn: db.documents.title,
    );
  }
}
