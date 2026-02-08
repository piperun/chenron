import "package:core/patterns/include_options.dart";
import "package:database/main.dart";
import "package:database/models/db_result.dart";
import "package:database/src/core/builders/base_query_builder.dart";
import "package:database/src/core/handlers/read_handler.dart";

extension FolderReadExtensions on AppDatabase {
  Future<FolderResult?> getFolder({
    required String folderId,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _FolderReadRepository(db: this).getOne(
      id: folderId,
      includeOptions: includeOptions,
    );
  }

  Future<List<FolderResult>> getAllFolders({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return _FolderReadRepository(db: this)
        .getAll(includeOptions: includeOptions);
  }

  Stream<FolderResult?> watchFolder({
    required String folderId,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _FolderReadRepository(db: this).watchOne(
      id: folderId,
      includeOptions: includeOptions,
    );
  }

  Stream<List<FolderResult>> watchAllFolders({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _FolderReadRepository(db: this)
        .watchAll(includeOptions: includeOptions);
  }

  /// Returns the ID of the "Default" folder, or the first folder if
  /// no folder is titled "Default". Returns null only if no folders exist.
  Future<String?> getDefaultFolderId() async {
    final byTitle = await (select(folders)
          ..where((f) => f.title.equals("Default"))
          ..limit(1))
        .getSingleOrNull();
    if (byTitle != null) return byTitle.id;

    final first = await (select(folders)..limit(1)).getSingleOrNull();
    return first?.id;
  }

  Future<List<FolderResult>> searchFolders({
    required String query,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return _FolderReadRepository(db: this).searchTable(
      query: query,
      includeOptions: includeOptions,
    );
  }
}

class _FolderReadRepository extends BaseRepository<IncludeOptions>
    implements
        BaseWatchRepository<IncludeOptions>,
        ExtraRepository<IncludeOptions> {
  final AppDatabase db;
  final ReadDbHandler<FolderResult> readHandler;

  _FolderReadRepository({required this.db})
      : readHandler = ReadDbHandler<FolderResult>(db: db, table: db.folders),
        super(appDb: db);

  @override
  Future<FolderResult?> getOne({
    required String id,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.getOne(
        predicate: db.folders.id.equals(id),
        joinExp: db.folders.id,
        includeOptions: includeOptions);
  }

  @override
  Future<List<FolderResult>> getAll({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.getAll(
      includeOptions: includeOptions,
      joinExp: db.folders.id,
    );
  }

  @override
  Stream<FolderResult?> watchOne({
    required String id,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return readHandler.watchOne(
        includeOptions: includeOptions,
        joinExp: db.folders.id,
        predicate: db.folders.id.equals(id));
  }

  @override
  Stream<List<FolderResult>> watchAll({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return readHandler.watchAll(
      includeOptions: includeOptions,
      joinExp: db.folders.id,
    );
  }

  @override
  Future<List<FolderResult>> searchTable({
    required String query,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.searchTable(
        query: query,
        includeOptions: includeOptions,
        joinExp: db.folders.id,
        searchColumn: db.folders.title);
  }
}
