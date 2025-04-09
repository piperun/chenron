import 'package:drift/drift.dart';
import 'package:chenron/database/actions/builders/result_builder.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/models/db_result.dart';

class UserConfigResultBuilder implements ResultBuilder<UserConfigResult> {
  final UserConfig _userConfig;
  BackupSetting? _backupSettings;
  ArchiveSetting? _archiveSetting;
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

    if (includeOptions.contains(ConfigIncludes.archiveSettings)) {
      final archive = row.readTableOrNull(_db.archiveSettings);
      if (archive != null) {
        _archiveSetting = archive;
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
      archiveSetting: _archiveSetting,
      userThemes: _userThemes.isEmpty ? null : _userThemes,
    );
  }
}
