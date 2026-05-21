/// Declarative per-theme settings.
///
/// A theme exposes a list of [ThemeSetting] entries to declare which
/// knobs the user can adjust at runtime (e.g. Nier's "Grid overlay"
/// toggle). The host app reads the schema, renders one tile per entry,
/// persists user choices, and passes the resulting option map back into
/// `VibeTheme.build(options)` so the theme can react.
///
/// Each setting carries a [defaultValue] so a theme works unchanged
/// even when the user has never opened the settings page.
sealed class ThemeSetting<T> {
  const ThemeSetting({
    required this.key,
    required this.label,
    this.description,
    required this.defaultValue,
  });

  /// Stable key used as both the option-map key and the
  /// SharedPreferences sub-key (e.g. `theme.nier.gridOverlay`).
  final String key;

  /// Short human-readable label shown next to the toggle.
  final String label;

  /// Optional longer description shown beneath [label].
  final String? description;

  /// Value used when the user hasn't picked anything yet.
  final T defaultValue;
}

/// A boolean theme option — renders as a switch tile in the host app.
class BoolThemeSetting extends ThemeSetting<bool> {
  /// Declare a boolean knob with stable [key] and starting
  /// [defaultValue].
  const BoolThemeSetting({
    required super.key,
    required super.label,
    super.description,
    required super.defaultValue,
  });
}

/// A multi-choice theme option backed by a Dart [Enum]. The host app
/// renders it as a segmented control or dropdown, calling [labelFor]
/// for each option's display string.
class EnumThemeSetting<T extends Enum> extends ThemeSetting<T> {
  /// Declare an enum knob over [options] with starting [defaultValue].
  const EnumThemeSetting({
    required super.key,
    required super.label,
    super.description,
    required super.defaultValue,
    required this.options,
    required this.labelFor,
  });

  /// All selectable enum values, in display order.
  final List<T> options;

  /// Maps each enum value to its human-readable label.
  final String Function(T) labelFor;
}
