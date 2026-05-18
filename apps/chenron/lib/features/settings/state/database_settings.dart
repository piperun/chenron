import "package:signals/signals.dart";

import "package:chenron/features/settings/service/data_settings_service.dart";

/// Reactive owner of the custom AppDatabase path (stored in
/// SharedPreferences, not the config database).
///
/// Sits outside the [SettingsSection] uniform interface because it has
/// its own load/save path (no [UserConfig] involved). The coordinator
/// composes it as a sibling and includes it in the global dirty check.
class DatabaseSettingsNotifier {
  final DataSettingsService _service;

  DatabaseSettingsNotifier(this._service);

  /// Path currently shown in the UI; null means "use default".
  final current = signal<String?>(null);

  /// Last value successfully persisted; powers the dirty check.
  final saved = signal<String?>(null);

  bool get isDirty => current.value != saved.value;

  void update(String? newPath) {
    current.value = newPath;
  }

  Future<void> load() async {
    final value = await _service.getCustomDatabasePath();
    current.value = value;
    saved.value = value;
  }

  Future<void> save() async {
    final value = current.value;
    await _service.setCustomDatabasePath(value);
    saved.value = value;
  }
}
