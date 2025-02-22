import "package:chenron/database/actions/joins/factory.dart";
import "package:chenron/database/actions/relations/folder.dart";
import "package:chenron/database/extensions/base_query_builder.dart";
import "package:chenron/models/item.dart";
import "package:chenron/database/database.dart";
import "package:drift/drift.dart";

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

  _FolderReadRepository({required this.db})
      : folderRelationBuilder = RelationFactory(db)
            .getRelationBuilder(db.folders) as FolderRelationBuilder,
        super(appDb: db);

  @override
  Future<FolderResult?> getOne({
    required String id,
    Set<IncludeOptions> modes = const {},
  }) async {
    folderRelationBuilder.createJoins(modes);
    final query = db.select(db.folders).join(folderRelationBuilder.joinList)
      ..where(db.folders.id.equals(id));
    final rows = await query.get();
    if (rows.isEmpty) {
      return null;
    }

    final results =
        folderRelationBuilder.buildRelations(includes: modes, rows: rows);
    return results.isEmpty ? null : results.first;
  }

  @override
  Future<List<FolderResult>> getAll({
    Set<IncludeOptions> modes = const {},
  }) async {
    folderRelationBuilder.createJoins(modes);
    final query = db.select(db.folders).join(folderRelationBuilder.joinList);
    final rows = await query.get();

    return folderRelationBuilder.buildRelations(includes: modes, rows: rows);
  }

  @override
  Stream<FolderResult?> watchOne({
    required String id,
    Set<IncludeOptions> modes = const {},
  }) {
    folderRelationBuilder.createJoins(modes);
    final query = db.select(db.folders).join(folderRelationBuilder.joinList)
      ..where(db.folders.id.equals(id));

    return query.watch().map((rows) {
      final results = folderRelationBuilder.buildRelations(
        includes: modes,
        rows: rows,
      );
      if (results.isEmpty) return null;
      return results.first;
    });
  }

  @override
  Stream<List<FolderResult>> watchAll({
    Set<IncludeOptions> modes = const {},
  }) {
    folderRelationBuilder.createJoins(modes);
    final query = db.select(db.folders).join(folderRelationBuilder.joinList);
    return query.watch().map((rows) => folderRelationBuilder.buildRelations(
          includes: modes,
          rows: rows,
        ));
  }

  @override
  Future<List<FolderResult>> searchTable({
    required String query,
    Set<IncludeOptions> modes = const {},
  }) async {
    folderRelationBuilder.createJoins(modes);
    final folders = (db.select(db.folders).join(folderRelationBuilder.joinList))
      ..where(db.folders.title.like("%$query%"));

    final rows = await folders.get();
    return folderRelationBuilder.buildRelations(
      includes: modes,
      rows: rows,
    );
  }

  ///  This method is not used and will be removed in a future version
  @Deprecated("use RelationBuilder")
  Selectable<TypedResult> _buildQuery({
    required Set<IncludeOptions> modes,
    String? folderId,
  }) {
    folderRelationBuilder.createJoins(modes);
    final query = db.select(db.folders).join(folderRelationBuilder.joinList);
    if (folderId != null) {
      query.where(db.folders.id.equals(folderId));
    }
    return query;
  }
}
