import "package:database/database.dart";
import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter/material.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:signals/signals.dart";
import "package:vibe/vibe.dart";

import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/state/settings_section.dart";
import "package:chenron/features/settings/state/theme_choice.dart";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:chenron/features/theme/state/theme_utils.dart";
import "package:app_logger/app_logger.dart";

part "theme_settings.freezed.dart";

/// Immutable snapshot of the user's selected theme. The pair `(key,
/// type)` is what the database persists; the richer [ThemeChoice]
/// object is reconstructed from [ThemeSettingsNotifier.availableThemes]
/// for display.
@freezed
abstract class ThemeSettings with _$ThemeSettings {
  const factory ThemeSettings({
    String? selectedKey,
    @Default(ThemeType.system) ThemeType selectedType,
  }) = _ThemeSettings;

  factory ThemeSettings.fromUserConfig(UserConfig config) => ThemeSettings(
        selectedKey: config.selectedThemeKey,
        selectedType: ThemeType.values[config.selectedThemeType],
      );
}

/// Reactive owner of the theme section.
///
/// Implements [SettingsSection] but also carries a few signals that
/// aren't part of the persisted snapshot:
///   - [availableThemes] — list of pickable themes, loaded async
///   - [sortMode] — UI-only, not persisted
///
/// On [save] this both writes the config columns and tells the global
/// [ThemeNotifier] to apply the new theme immediately.
class ThemeSettingsNotifier implements SettingsSection {
  final ConfigService _service;
  final ThemeNotifier _themeApplier;

  ThemeSettingsNotifier(this._service, this._themeApplier);

  final current = signal(const ThemeSettings());
  final saved = signal(const ThemeSettings());

  final availableThemes = signal<List<ThemeChoice>>(const []);
  final sortMode = signal<ThemeSortMode>(ThemeSortMode.name);

  /// Resolves the current key/type back to a full [ThemeChoice] using
  /// [availableThemes]. Returns null while themes haven't loaded yet
  /// or if the persisted choice no longer exists in the list.
  late final Computed<ThemeChoice?> selectedChoice = Computed(() {
    final snap = current.value;
    final list = availableThemes.value;
    if (list.isEmpty) return null;
    for (final c in list) {
      if (c.key == snap.selectedKey && c.type == snap.selectedType) {
        return c;
      }
    }
    return list.first;
  });

  /// Themes sorted by [sortMode]. UI reads this rather than
  /// [availableThemes] directly.
  late final Computed<List<ThemeChoice>> sortedThemes = Computed(() {
    final list = [...availableThemes.value];
    switch (sortMode.value) {
      case ThemeSortMode.name:
        list.sort((a, b) => a.name.compareTo(b.name));
      case ThemeSortMode.colorCount:
        list.sort((a, b) => b.colorCount.compareTo(a.colorCount));
    }
    return list;
  });

  @override
  bool get isDirty => current.value != saved.value;

  /// Update the selected theme by [ThemeChoice]. UI calls this rather
  /// than manipulating the raw key/type.
  void select(ThemeChoice? choice) {
    if (choice == null) return;
    current.value = current.value.copyWith(
      selectedKey: choice.key,
      selectedType: choice.type,
    );
  }

  void setSortMode(ThemeSortMode mode) {
    sortMode.value = mode;
  }

  /// Build the full light/dark variants for a [choice], used by the
  /// preview swatch row.
  ThemeVariants? getPreviewVariants(ThemeChoice choice) {
    if (choice.type == ThemeType.system) {
      return getPredefinedTheme(choice.key);
    }
    if (choice.swatches.isEmpty) return null;
    return buildSeededVariants(
      primary: choice.swatches.first,
      secondary: choice.swatches.length > 1 ? choice.swatches[1] : null,
      tertiary: choice.swatches.length > 2 ? choice.swatches[2] : null,
      useSecondary: choice.swatches.length > 1,
      useTertiary: choice.swatches.length > 2,
    );
  }

  /// Load the full list of pickable themes: built-in FlexSchemes, the
  /// curated Nier theme, and any user-created custom themes from the
  /// config database.
  Future<void> loadAvailableThemes() async {
    final List<ThemeChoice> choices = [];

    // Curated Nier Automata theme with hand-picked swatches.
    const nierP = Color(0xFFD1CDB7);
    const nierS = Color(0xFF454138);
    const nierT = Color(0xFF38AAA1);
    choices.add(ThemeChoice(
      key: "nier",
      name: "Nier Automata",
      type: ThemeType.system,
      colorCount: countDistinctHues(nierP, nierS, nierT),
      swatches: distinctSwatches(nierP, nierS, nierT),
    ));

    for (final scheme in FlexScheme.values) {
      if (scheme == FlexScheme.custom) continue;
      final data = scheme.data;
      final p = data.light.primary;
      final s = data.light.secondary;
      final t = data.light.tertiary;
      choices.add(ThemeChoice(
        key: scheme.name,
        name: data.name,
        type: ThemeType.system,
        colorCount: countDistinctHues(p, s, t),
        swatches: distinctSwatches(p, s, t),
      ));
    }

    final customThemes = await _service.getAllUserThemes();
    for (final result in customThemes) {
      final d = result.data;
      final p = Color(d.primaryColor);
      final s = Color(d.secondaryColor);
      final t = d.tertiaryColor != null ? Color(d.tertiaryColor!) : s;
      choices.add(ThemeChoice(
        key: d.id,
        name: d.name,
        type: ThemeType.custom,
        colorCount: countDistinctHues(p, s, t),
        swatches: distinctSwatches(p, s, t),
      ));
    }

    availableThemes.value = choices;
    loggerGlobal.info(
        "ThemeSettingsNotifier", "Loaded ${choices.length} theme choices.");
  }

  @override
  void hydrate(UserConfig config) {
    final snapshot = ThemeSettings.fromUserConfig(config);
    current.value = snapshot;
    saved.value = snapshot;
  }

  @override
  Future<void> save(String configId) async {
    final s = current.value;
    final key = s.selectedKey;
    if (key == null) {
      throw StateError("Cannot save theme: no selected key.");
    }
    await _service.updateThemeSection(
      configId: configId,
      selectedThemeKey: key,
      selectedThemeType: s.selectedType,
    );
    await _themeApplier.changeTheme(key, s.selectedType);
    saved.value = s;
  }
}
