import "package:database/database.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:signals/signals.dart";

import "package:chenron/features/settings/service/config_service.dart";

part "backup_settings.freezed.dart";

/// Immutable snapshot of the user-editable backup preferences.
///
/// Named [BackupPreferences] rather than `BackupSettings` because the
/// database package already defines a `BackupSettings` Drift table
/// class; the name clash would shadow it at every import site.
@freezed
abstract class BackupPreferences with _$BackupPreferences {
  const factory BackupPreferences({
    String? backupInterval,
    String? backupPath,
  }) = _BackupPreferences;

  factory BackupPreferences.fromRow(BackupSetting row) => BackupPreferences(
        backupInterval: row.backupInterval,
        backupPath: row.backupPath,
      );
}

/// Reactive owner of the [BackupSetting] row.
///
/// Lives outside the uniform [SettingsSection] interface because it
/// hydrates from a different table (`BackupSettings`), not [UserConfig].
/// The coordinator composes it as a sibling.
class BackupSettingsNotifier {
  final ConfigService _service;

  BackupSettingsNotifier(this._service);

  final current = signal(const BackupPreferences());
  final saved = signal(const BackupPreferences());

  /// Tracks the row id so [save] can address the right record. Null
  /// before hydrate or when the user has no backup row yet.
  String? _rowId;

  bool get isDirty => current.value != saved.value;

  void update(BackupPreferences Function(BackupPreferences) transform) {
    current.value = transform(current.value);
  }

  /// Called by the coordinator after fetching the backup row.
  /// A null [row] resets the snapshot to defaults but disables [save].
  void hydrateBackup(BackupSetting? row) {
    if (row == null) {
      _rowId = null;
      current.value = const BackupPreferences();
      saved.value = const BackupPreferences();
      return;
    }
    _rowId = row.id;
    final snapshot = BackupPreferences.fromRow(row);
    current.value = snapshot;
    saved.value = snapshot;
  }

  /// Persist the current snapshot. Throws [StateError] if no row id is
  /// known — the row has to exist before edits can be saved.
  Future<void> save() async {
    final id = _rowId;
    if (id == null) {
      throw StateError(
          "Cannot save backup settings: no backup row hydrated.");
    }
    final s = current.value;
    await _service.updateBackupSettings(
      id: id,
      backupInterval: s.backupInterval,
      backupPath: s.backupPath,
      clearInterval: s.backupInterval == null,
    );
    saved.value = s;
  }
}
