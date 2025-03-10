import "package:chenron/database/extensions/base_query_builder.dart";
import "package:chenron/database/actions/handlers/read_handler.dart";
import "package:chenron/database/database.dart";

extension FolderReadExtensions on AppDatabase {
  Future<Result<Folder>?> getFolder({
    required String folderId,
    Set<IncludeOptions> modes = const {},
  }) {
    return _FolderReadRepository(db: this).getOne(id: folderId, modes: modes);
  }

  Future<List<Result<Folder>>> getAllFolders({
    Set<IncludeOptions> modes = const {},
  }) async {
    return _FolderReadRepository(db: this).getAll(modes: modes);
  }

  Stream<Result<Folder>?> watchFolder({
    required String folderId,
    Set<IncludeOptions> modes = const {},
  }) {
    return _FolderReadRepository(db: this).watchOne(id: folderId, modes: modes);
  }

  Stream<List<Result<Folder>>> watchAllFolders({
    Set<IncludeOptions> modes = const {},
  }) {
    return _FolderReadRepository(db: this).watchAll(modes: modes);
  }

  Future<List<Result<Folder>>> searchFolders({
    required String query,
    Set<IncludeOptions> modes = const {},
  }) async {
    return _FolderReadRepository(db: this)
        .searchTable(query: query, modes: modes);
  }
}

class _FolderReadRepository extends BaseRepository<Folder, Set<IncludeOptions>>
    implements
        BaseWatchRepository<Folder, Set<IncludeOptions>>,
        ExtraRepository<Folder, Set<IncludeOptions>> {
  final AppDatabase db;
  final ReadDbHandler<Folder> readHandler;

  _FolderReadRepository({required this.db})
      : readHandler = ReadDbHandler<Folder>(db: db, table: db.folders),
        super(appDb: db);

  @override
  Future<Result<Folder>?> getOne({
    required String id,
    Set<IncludeOptions> modes = const {},
  }) async {
    return readHandler.getOne(
        predicate: db.folders.id.equals(id),
        joinExp: db.folders.id,
        includes: modes);
  }

  @override
  Future<List<Result<Folder>>> getAll({
    Set<IncludeOptions> modes = const {},
  }) async {
    return readHandler.getAll(
      includes: modes,
      joinExp: db.folders.id,
    );
  }

  @override
  Stream<Result<Folder>?> watchOne({
    required String id,
    Set<IncludeOptions> modes = const {},
  }) {
    return readHandler.watchOne(
        includes: modes,
        joinExp: db.folders.id,
        predicate: db.folders.id.equals(id));
  }

  @override
  Stream<List<Result<Folder>>> watchAll({
    Set<IncludeOptions> modes = const {},
  }) {
    return readHandler.watchAll(
      includes: modes,
      joinExp: db.folders.id,
    );
  }

  @override
  Future<List<Result<Folder>>> searchTable({
    required String query,
    Set<IncludeOptions> modes = const {},
  }) async {
    return readHandler.searchTable(
        query: query,
        includes: modes,
        joinExp: db.folders.id,
        searchColumn: db.folders.title);
  }
}
