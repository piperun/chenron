import "package:chenron/database/actions/joins/factory.dart";
import "package:chenron/database/actions/relations/folder.dart";
import "package:chenron/database/extensions/base_query_builder.dart";
import "package:chenron/database/actions/handlers/read_handler.dart";
import "package:chenron/models/item.dart";
import "package:chenron/database/database.dart";

class FolderResult {
  final Folder folder;
  List<Tag> tags = [];
  List<FolderItem> items = [];

  FolderResult({required this.folder});
}

extension FolderReadExtensions on AppDatabase {
  Future<FolderResult?> getFolder({
    required String folderId,
    Set<IncludeOptions> modes = const {},
  }) {
    return _FolderReadRepository(db: this).getOne(id: folderId, modes: modes);
  }

  Future<List<FolderResult>> getAllFolders({
    Set<IncludeOptions> modes = const {},
  }) async {
    return _FolderReadRepository(db: this).getAll(modes: modes);
  }

  Stream<FolderResult?> watchFolder({
    required String folderId,
    Set<IncludeOptions> modes = const {},
  }) {
    return _FolderReadRepository(db: this).watchOne(id: folderId, modes: modes);
  }

  Stream<List<FolderResult>> watchAllFolders({
    Set<IncludeOptions> modes = const {},
  }) {
    return _FolderReadRepository(db: this).watchAll(modes: modes);
  }

  Future<List<FolderResult>> searchFolders({
    required String query,
    Set<IncludeOptions> modes = const {},
  }) async {
    return _FolderReadRepository(db: this)
        .searchTable(query: query, modes: modes);
  }
}

class _FolderReadRepository
    extends BaseRepository<FolderResult, Set<IncludeOptions>>
    implements
        BaseWatchRepository<FolderResult, Set<IncludeOptions>>,
        ExtraRepository<FolderResult, Set<IncludeOptions>> {
  final AppDatabase db;
  final FolderRelationBuilder folderRelationBuilder;
  final ReadDbHandler<FolderResult> readHandler;

  _FolderReadRepository({required this.db})
      : folderRelationBuilder = RelationFactory(db)
            .getRelationBuilder(db.folders) as FolderRelationBuilder,
        readHandler = ReadDbHandler<FolderResult>(db: db, table: db.folders),
        super(appDb: db);

  @override
  Future<FolderResult?> getOne({
    required String id,
    Set<IncludeOptions> modes = const {},
  }) async {
    return readHandler.getOne(
        predicate: db.folders.id.equals(id), includes: modes);
  }

  @override
  Future<List<FolderResult>> getAll({
    Set<IncludeOptions> modes = const {},
  }) async {
    return readHandler.getAll(includes: modes);
  }

  @override
  Stream<FolderResult?> watchOne({
    required String id,
    Set<IncludeOptions> modes = const {},
  }) {
    return readHandler.watchOne(
        includes: modes, predicate: db.folders.id.equals(id));
  }

  @override
  Stream<List<FolderResult>> watchAll({
    Set<IncludeOptions> modes = const {},
  }) {
    return readHandler.watchAll(includes: modes);
  }

  @override
  Future<List<FolderResult>> searchTable({
    required String query,
    Set<IncludeOptions> modes = const {},
  }) async {
    return readHandler.searchTable(query: query, includes: modes);
  }
}
