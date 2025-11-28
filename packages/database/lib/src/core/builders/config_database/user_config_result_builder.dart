import "package:database/main.dart";
import "package:database/models/db_result.dart";
import "package:drift/drift.dart";
import "package:database/src/core/builders/result_builder.dart";

class UserConfigResultBuilder implements ResultBuilder<UserConfigResult> {
  final UserConfig _userConfig;
  BackupSetting? _backupSettings;
  final List<UserTheme> _userThemes = [];
  final ConfigDatabase _db;

  UserConfigResultBuilder(this._userConfig, this._db);

  @override
  String get entityId => _userConfig.id;

  @override
  void processRow(TypedResult row, Set<Enum> includeOptions) {
    if (includeOptions.contains(ConfigIncludes.backupSettings)) {
      final backup = row.readTableOrNull(_db.backupSettings);
      if (backup != null) {
        _backupSettings = backup;
      }
    }

    if (includeOptions.contains(ConfigIncludes.userThemes)) {
      final theme = row.readTableOrNull(_db.userThemes);
      if (theme != null && !_userThemes.any((t) => t.id == theme.id)) {
        _userThemes.add(theme);
      }
    }
  }

  @override
  UserConfigResult build() {
    return UserConfigResult(
      data: _userConfig,
      backupSettings: _backupSettings,
      userThemes: _userThemes.isEmpty ? null : _userThemes,
    );
  }
}
