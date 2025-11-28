import "package:database/main.dart";
import "package:database/models/db_result.dart";
import "package:drift/drift.dart";
import "package:database/src/core/builders/result_builder.dart";
// Should contain ConfigDatabase, UserTheme, UserConfig, and potentially ConfigIncludes enum
// Should contain UserThemeResult

/// Builds a [UserThemeResult] from query rows.
///
/// This builder expects [UserTheme] as the main entity and can optionally
/// include the related [UserConfig] if joined and specified in includeOptions.
class UserThemeResultBuilder implements ResultBuilder<UserThemeResult> {
  final UserTheme _userTheme; // The primary entity for this builder instance
  UserConfig? _userConfig; // The related UserConfig, if included
  final ConfigDatabase _db;

  UserThemeResultBuilder(this._userTheme, this._db);

  @override
  String get entityId => _userTheme.id;

  @override
  void processRow(TypedResult row, Set<Enum> includeOptions) {
    // Check if the parent UserConfig was joined and requested
    // Assumes 'ConfigIncludes.userConfig' exists in your include options enum
    if (includeOptions.contains(ConfigIncludes.userConfig)) {
      final config = row.readTableOrNull(_db.userConfigs);
      if (config != null) {
        // Since a theme belongs to only one config, we can just assign it.
        // If multiple rows somehow had different configs (shouldn't happen with correct joins),
        // this would take the last one processed.
        _userConfig = config;
      }
    }

    // Add processing for any other potential related entities joined to UserTheme here
    // (Currently, none are defined in the provided schema besides UserConfig)
  }

  @override
  UserThemeResult build() {
    // Construct the final UserThemeResult object
    // Assumes UserThemeResult has 'data' and an optional 'userConfig' field
    return UserThemeResult(
      data: _userTheme,
      userConfigId: _userConfig
          ?.id, // Will be null if not included via options or not found in the row
    );
  }
}
