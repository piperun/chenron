import "package:database/database.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:signals/signals.dart";

import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/state/settings_section.dart";

part "storage_settings.freezed.dart";

/// Immutable snapshot of on-disk storage preferences. `null` for
/// [cacheDirectory] means "use the platform default temp dir".
@freezed
abstract class StorageSettings with _$StorageSettings {
  const factory StorageSettings({
    String? cacheDirectory,
  }) = _StorageSettings;

  factory StorageSettings.fromUserConfig(UserConfig config) =>
      StorageSettings(cacheDirectory: config.cacheDirectory);
}

class StorageSettingsNotifier implements SettingsSection {
  final ConfigService _service;

  /// Applies a newly-saved cache directory to the image cache so a changed
  /// location takes effect without a restart. Injected as a callback (rather
  /// than reaching the locator) to keep this notifier decoupled and
  /// unit-testable; `null` when no image cache is wired.
  final Future<void> Function(String? cacheDirectory)? _onCacheDirectorySaved;

  StorageSettingsNotifier(
    this._service, {
    Future<void> Function(String? cacheDirectory)? onCacheDirectorySaved,
  }) : _onCacheDirectorySaved = onCacheDirectorySaved;

  final current = signal(const StorageSettings());
  final saved = signal(const StorageSettings());

  @override
  bool get isDirty => current.value != saved.value;

  void update(StorageSettings Function(StorageSettings) transform) {
    current.value = transform(current.value);
  }

  @override
  void hydrate(UserConfig config) {
    final snapshot = StorageSettings.fromUserConfig(config);
    current.value = snapshot;
    saved.value = snapshot;
  }

  @override
  Future<void> save(String configId) async {
    final s = current.value;
    // The user-config update API treats null as "leave the column
    // untouched" and "" as "clear to NULL" — so a reset to the default
    // directory must be sent as "", or the old custom path would survive
    // in the database and resurrect on the next hydrate.
    await _service.updateStorageSection(
      configId: configId,
      cacheDirectory: s.cacheDirectory ?? "",
    );
    saved.value = s;
    // Point the image cache at the saved directory so the change takes
    // effect immediately. No-op if the directory is unchanged.
    await _onCacheDirectorySaved?.call(s.cacheDirectory);
  }
}
