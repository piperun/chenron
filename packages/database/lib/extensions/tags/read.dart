import "package:database/actions/handlers/read_handler.dart";
import "package:database/database.dart";
import "package:database/extensions/base_query_builder.dart";
import "package:database/models/db_result.dart";

extension TagReadExtensions on AppDatabase {
  /// Retrieves a single tag by its ID.
  Future<TagResult?> getTag({
    required String tagId,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _TagReadRepository(db: this)
        .getOne(id: tagId, includeOptions: includeOptions);
  }

  /// Retrieves all tags. If [modes] contains relation options,
  /// related data can be loaded as well.
  Future<List<TagResult>> getAllTags({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _TagReadRepository(db: this).getAll(includeOptions: includeOptions);
  }

  /// Watches a single tag by its ID as a stream of Result
  Stream<TagResult?> watchTag({
    required String tagId,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _TagReadRepository(db: this)
        .watchOne(id: tagId, includeOptions: includeOptions);
  }

  /// Watches all tags, returning them as a stream of Result lists.
  Stream<List<TagResult>> watchAllTags({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _TagReadRepository(db: this)
        .watchAll(includeOptions: includeOptions);
  }

  /// Searches for tags by name (or another column if configured)
  /// matching the given [query].
  Future<List<TagResult>> searchTags({
    required String query,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return _TagReadRepository(db: this)
        .searchTable(query: query, includeOptions: includeOptions);
  }
}

class _TagReadRepository extends BaseRepository<IncludeOptions>
    implements
        BaseWatchRepository<IncludeOptions>,
        ExtraRepository<IncludeOptions> {
  final AppDatabase db;
  final ReadDbHandler<TagResult> readHandler;

  _TagReadRepository({required this.db})
      : readHandler = ReadDbHandler<TagResult>(
          db: db,
          table: db.tags,
        ),
        super(appDb: db);

  @override
  Future<TagResult?> getOne({
    required String id,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.getOne(
      includeOptions: includeOptions,
      predicate: db.tags.id.equals(id),
      joinExp: db.tags.id,
    );
  }

  @override
  Future<List<TagResult>> getAll({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.getAll(
      includeOptions: includeOptions,
      joinExp: db.tags.id,
    );
  }

  @override
  Stream<TagResult?> watchOne({
    required String id,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return readHandler.watchOne(
      includeOptions: includeOptions,
      joinExp: db.tags.id,
      predicate: db.tags.id.equals(id),
    );
  }

  @override
  Stream<List<TagResult>> watchAll({
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) {
    return readHandler.watchAll(
      includeOptions: includeOptions,
      joinExp: db.tags.id,
    );
  }

  @override
  Future<List<TagResult>> searchTable({
    required String query,
    IncludeOptions includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.searchTable(
      query: query,
      includeOptions: includeOptions,
      joinExp: db.tags.id,
      searchColumn: null,
    );
  }
}


