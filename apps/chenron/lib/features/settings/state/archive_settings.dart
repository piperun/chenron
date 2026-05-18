import "package:database/database.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:signals/signals.dart";

import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/state/settings_section.dart";

part "archive_settings.freezed.dart";

/// Immutable snapshot of the archive-related user settings.
///
/// Equality is structural (Freezed), which is what powers the
/// `current != saved` dirty check on [ArchiveSettingsNotifier].
@freezed
abstract class ArchiveSettings with _$ArchiveSettings {
  const factory ArchiveSettings({
    @Default(false) bool defaultArchiveIs,
    @Default(false) bool defaultArchiveOrg,
    String? archiveOrgS3AccessKey,
    String? archiveOrgS3SecretKey,
  }) = _ArchiveSettings;

  factory ArchiveSettings.fromUserConfig(UserConfig config) => ArchiveSettings(
        defaultArchiveIs: config.defaultArchiveIs,
        defaultArchiveOrg: config.defaultArchiveOrg,
        archiveOrgS3AccessKey: config.archiveOrgS3AccessKey,
        archiveOrgS3SecretKey: config.archiveOrgS3SecretKey,
      );
}

/// Reactive owner of the [ArchiveSettings] section.
class ArchiveSettingsNotifier implements SettingsSection {
  final ConfigService _service;

  ArchiveSettingsNotifier(this._service);

  final current = signal(const ArchiveSettings());
  final saved = signal(const ArchiveSettings());

  @override
  bool get isDirty => current.value != saved.value;

  /// Apply [transform] to the current snapshot. UI calls this with
  /// `(s) => s.copyWith(defaultArchiveOrg: value)` rather than going
  /// through per-field setters.
  void update(ArchiveSettings Function(ArchiveSettings) transform) {
    current.value = transform(current.value);
  }

  @override
  void hydrate(UserConfig config) {
    final snapshot = ArchiveSettings.fromUserConfig(config);
    current.value = snapshot;
    saved.value = snapshot;
  }

  @override
  Future<void> save(String configId) async {
    final s = current.value;
    await _service.updateArchiveSection(
      configId: configId,
      defaultArchiveIs: s.defaultArchiveIs,
      defaultArchiveOrg: s.defaultArchiveOrg,
      archiveOrgS3AccessKey: s.archiveOrgS3AccessKey?.trim(),
      archiveOrgS3SecretKey: s.archiveOrgS3SecretKey?.trim(),
    );
    saved.value = s;
  }
}
