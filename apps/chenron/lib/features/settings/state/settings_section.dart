import "package:database/database.dart";

/// Contract for an isolated slice of the settings page.
///
/// Each section owns its own `current` (being edited) and `saved` (last
/// persisted) snapshot signals. The coordinator composes sections and
/// fans out [hydrate] / [save] without knowing about individual fields.
abstract interface class SettingsSection {
  /// True when [current] differs from [saved]. Used by both the
  /// per-section "you've changed this" badge and the global
  /// hasUnsavedChanges check.
  bool get isDirty;

  /// Copy the loaded [UserConfig] into both [current] and [saved] so the
  /// section starts clean.
  ///
  /// Sections that read from other sources (SharedPreferences, the
  /// BackupSettings table, the theme list) intentionally do not
  /// implement this contract and stay outside the uniform interface.
  void hydrate(UserConfig config);

  /// Persist [current] via the section's own service. The section is
  /// responsible for advancing [saved] to mirror the new persisted
  /// state on success.
  Future<void> save(String configId);
}
