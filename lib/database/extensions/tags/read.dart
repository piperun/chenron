import "package:chenron/database/actions/handlers/read_handler.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/base_query_builder.dart";

extension TagReadExtensions on AppDatabase {
  /// Retrieves a single tag by its ID.
  Future<Result<Tag>?> getTag({
    required String tagId,
    IncludeItems modes = const {},
  }) {
    return _TagReadRepository(db: this).getOne(id: tagId, modes: modes);
  }

  /// Retrieves all tags. If [modes] contains relation options,
  /// related data can be loaded as well.
  Future<List<Result<Tag>>> getAllTags({
    IncludeItems modes = const {},
  }) {
    return _TagReadRepository(db: this).getAll(modes: modes);
  }

  /// Watches a single tag by its ID as a stream of Result
  Stream<Result<Tag>?> watchTag({
    required String tagId,
    IncludeItems modes = const {},
  }) {
    return _TagReadRepository(db: this).watchOne(id: tagId, modes: modes);
  }

  /// Watches all tags, returning them as a stream of Result lists.
  Stream<List<Result<Tag>>> watchAllTags({
    IncludeItems modes = const {},
  }) {
    return _TagReadRepository(db: this).watchAll(modes: modes);
  }

  /// Searches for tags by name (or another column if configured)
  /// matching the given [query].
  Future<List<Result<Tag>>> searchTags({
    required String query,
    IncludeItems modes = const {},
  }) {
    return _TagReadRepository(db: this).searchTable(query: query, modes: modes);
  }
}

class _TagReadRepository extends BaseRepository<Tag, IncludeItems>
    implements
        BaseWatchRepository<Tag, IncludeItems>,
        ExtraRepository<Tag, IncludeItems> {
  final AppDatabase db;
  final ReadDbHandler<Tag> readHandler;

  _TagReadRepository({required this.db})
      : readHandler = ReadDbHandler<Tag>(
          db: db,
          table: db.tags,
          // Optionally set a searchable column if you like (e.g., db.tags.name):
          // searchColumn: db.tags.name,
        ),
        super(appDb: db);

  @override
  Future<Result<Tag>?> getOne({
    required String id,
    IncludeItems modes = const {},
  }) async {
    return readHandler.getOne(
      includes: modes,
      predicate: db.tags.id.equals(id),
      joinExp: db.tags.id,
    );
  }

  @override
  Future<List<Result<Tag>>> getAll({
    IncludeItems modes = const {},
  }) async {
    return readHandler.getAll(
      includes: modes,
      joinExp: db.folders.id,
    );
  }

  @override
  Stream<Result<Tag>?> watchOne({
    required String id,
    IncludeItems modes = const {},
  }) {
    return readHandler.watchOne(
      includes: modes,
      joinExp: db.folders.id,
      predicate: db.tags.id.equals(id),
    );
  }

  @override
  Stream<List<Result<Tag>>> watchAll({
    IncludeItems modes = const {},
  }) {
    return readHandler.watchAll(
      includes: modes,
      joinExp: db.folders.id,
    );
  }

  @override
  Future<List<Result<Tag>>> searchTable({
    required String query,
    IncludeItems modes = const {},
  }) async {
    return readHandler.searchTable(
      query: query,
      includes: modes,
      joinExp: db.folders.id,
      searchColumn: null,
    );
  }
}
