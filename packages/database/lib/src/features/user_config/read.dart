import "package:core/patterns/include_options.dart";
import "package:database/main.dart";
import "package:database/models/db_result.dart";
import "package:database/src/core/builders/base_query_builder.dart";
import "package:database/src/core/handlers/read_handler.dart";

extension UserConfigReadExtensions on ConfigDatabase {
  // Simplified user config methods
  Future<UserConfigResult?> getUserConfig({
    IncludeOptions<ConfigIncludes> includeOptions =
        const IncludeOptions.empty(),
  }) async {
    final results = await _UserConfigReadRepository(db: this).getAll(
      includeOptions: includeOptions,
    );
    return results.isEmpty ? null : results.first;
  }

  Stream<UserConfigResult?> watchUserConfig({
    IncludeOptions<ConfigIncludes> includeOptions =
        const IncludeOptions.empty(),
  }) {
    return _UserConfigReadRepository(db: this)
        .watchAll(
          includeOptions: includeOptions,
        )
        .map((results) => results.isEmpty ? null : results.first);
  }

  // User theme methods matching exactly how folder works
  Future<UserThemeResult?> getUserTheme({
    required String themeKey,
    IncludeOptions<Enum> includeOptions = const IncludeOptions.empty(),
  }) {
    return _UserThemeReadRepository(db: this).getOne(
      id: themeKey,
      includeOptions: includeOptions,
    );
  }

  Future<List<UserThemeResult>> getAllUserThemes({
    IncludeOptions<Enum> includeOptions = const IncludeOptions.empty(),
  }) {
    return _UserThemeReadRepository(db: this).getAll(
      includeOptions: includeOptions,
    );
  }

  Stream<UserThemeResult?> watchUserTheme({
    required String themeId,
    IncludeOptions<Enum> includeOptions = const IncludeOptions.empty(),
  }) {
    return _UserThemeReadRepository(db: this).watchOne(
      id: themeId,
      includeOptions: includeOptions,
    );
  }

  Stream<List<UserThemeResult>> watchAllUserThemes({
    IncludeOptions<Enum> includeOptions = const IncludeOptions.empty(),
  }) {
    return _UserThemeReadRepository(db: this).watchAll(
      includeOptions: includeOptions,
    );
  }

  Future<List<UserThemeResult>> searchUserThemes({
    required String query,
    IncludeOptions<Enum> includeOptions = const IncludeOptions.empty(),
  }) {
    return _UserThemeReadRepository(db: this).searchTable(
      query: query,
      includeOptions: includeOptions,
    );
  }
}

class _UserConfigReadRepository
    extends BaseRepository<IncludeOptions<ConfigIncludes>>
    implements BaseWatchRepository<IncludeOptions<ConfigIncludes>> {
  final ConfigDatabase db;
  final ReadDbHandler<UserConfigResult> readHandler;

  _UserConfigReadRepository({required this.db})
      : readHandler =
            ReadDbHandler<UserConfigResult>(db: db, table: db.userConfigs),
        super(appDb: db);

  @override
  Future<UserConfigResult?> getOne({
    required String id,
    IncludeOptions<ConfigIncludes> includeOptions =
        const IncludeOptions.empty(),
  }) async {
    return readHandler.getOne(
      predicate: db.userConfigs.id.equals(id),
      joinExp: db.userConfigs.id,
      includeOptions: includeOptions,
    );
  }

  @override
  Future<List<UserConfigResult>> getAll({
    IncludeOptions<ConfigIncludes> includeOptions =
        const IncludeOptions.empty(),
  }) async {
    return readHandler.getAll(
      includeOptions: includeOptions,
      joinExp: db.userConfigs.id,
    );
  }

  @override
  Stream<UserConfigResult?> watchOne({
    required String id,
    IncludeOptions<ConfigIncludes> includeOptions =
        const IncludeOptions.empty(),
  }) {
    return readHandler.watchOne(
      includeOptions: includeOptions,
      joinExp: db.userConfigs.id,
      predicate: db.userConfigs.id.equals(id),
    );
  }

  @override
  Stream<List<UserConfigResult>> watchAll({
    IncludeOptions<ConfigIncludes> includeOptions =
        const IncludeOptions.empty(),
  }) {
    return readHandler.watchAll(
      includeOptions: includeOptions,
      joinExp: db.userConfigs.id,
    );
  }
}

// Repository for user theme operations using Result pattern
class _UserThemeReadRepository extends BaseRepository<IncludeOptions<Enum>>
    implements
        BaseWatchRepository<IncludeOptions<Enum>>,
        ExtraRepository<IncludeOptions<Enum>> {
  final ConfigDatabase db;
  final ReadDbHandler<UserThemeResult> readHandler;

  _UserThemeReadRepository({required this.db})
      : readHandler =
            ReadDbHandler<UserThemeResult>(db: db, table: db.userThemes),
        super(appDb: db);

  @override
  Future<UserThemeResult?> getOne({
    required String id,
    IncludeOptions<Enum> includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.getOne(
      predicate: db.userThemes.id.equals(id),
      joinExp: db.userThemes.id,
      includeOptions: includeOptions,
    );
  }

  @override
  Future<List<UserThemeResult>> getAll({
    IncludeOptions<Enum> includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.getAll(
      includeOptions: includeOptions,
      joinExp: db.userThemes.id,
    );
  }

  @override
  Stream<UserThemeResult?> watchOne({
    required String id,
    IncludeOptions<Enum> includeOptions = const IncludeOptions.empty(),
  }) {
    return readHandler.watchOne(
      includeOptions: includeOptions,
      joinExp: db.userThemes.id,
      predicate: db.userThemes.id.equals(id),
    );
  }

  @override
  Stream<List<UserThemeResult>> watchAll({
    IncludeOptions<Enum> includeOptions = const IncludeOptions.empty(),
  }) {
    return readHandler.watchAll(
      includeOptions: includeOptions,
      joinExp: db.userThemes.id,
    );
  }

  @override
  Future<List<UserThemeResult>> searchTable({
    required String query,
    IncludeOptions<Enum> includeOptions = const IncludeOptions.empty(),
  }) async {
    return readHandler.searchTable(
      query: query,
      includeOptions: includeOptions,
      joinExp: db.userThemes.id,
      searchColumn: db.userThemes.name,
    );
  }
}
