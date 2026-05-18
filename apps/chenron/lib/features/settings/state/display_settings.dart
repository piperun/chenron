import "package:database/database.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:signals/signals.dart";

import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/state/settings_section.dart";

part "display_settings.freezed.dart";

/// Immutable snapshot of viewer / display preferences plus the cache
/// directory override. `null` for [cacheDirectory] means "use the
/// platform default temp dir".
@freezed
abstract class DisplaySettings with _$DisplaySettings {
  const factory DisplaySettings({
    @Default(0) int timeDisplayFormat,
    @Default(0) int itemClickAction,
    String? cacheDirectory,
    @Default(true) bool showDescription,
    @Default(true) bool showImages,
    @Default(true) bool showTags,
    @Default(true) bool showCopyLink,
  }) = _DisplaySettings;

  factory DisplaySettings.fromUserConfig(UserConfig config) => DisplaySettings(
        // UserConfig now exposes these as enums (intEnum<T>); the
        // settings snapshot still holds the int index for the UI's
        // existing radio + segmented-button bindings.
        timeDisplayFormat: config.timeDisplayFormat.index,
        itemClickAction: config.itemClickAction.index,
        cacheDirectory: config.cacheDirectory,
        showDescription: config.showDescription,
        showImages: config.showImages,
        showTags: config.showTags,
        showCopyLink: config.showCopyLink,
      );
}

class DisplaySettingsNotifier implements SettingsSection {
  final ConfigService _service;

  DisplaySettingsNotifier(this._service);

  final current = signal(const DisplaySettings());
  final saved = signal(const DisplaySettings());

  @override
  bool get isDirty => current.value != saved.value;

  void update(DisplaySettings Function(DisplaySettings) transform) {
    current.value = transform(current.value);
  }

  @override
  void hydrate(UserConfig config) {
    final snapshot = DisplaySettings.fromUserConfig(config);
    current.value = snapshot;
    saved.value = snapshot;
  }

  @override
  Future<void> save(String configId) async {
    final s = current.value;
    await _service.updateDisplaySection(
      configId: configId,
      timeDisplayFormat: s.timeDisplayFormat,
      itemClickAction: s.itemClickAction,
      cacheDirectory: s.cacheDirectory,
      showDescription: s.showDescription,
      showImages: s.showImages,
      showTags: s.showTags,
      showCopyLink: s.showCopyLink,
    );
    saved.value = s;
  }
}
