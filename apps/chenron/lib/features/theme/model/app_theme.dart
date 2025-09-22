import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

/// Base color palette typedef for theme colors
///
/// This defines the structure that all theme color palettes should follow.
/// Field names should describe the semantic purpose of the color,
/// not its specific hue or Material role.
typedef ThemeColorPalette = ({
  Color primary,
  Color primaryVariant,
  Color secondary,
  Color secondaryVariant,
  Color surface,
  Color background,
  Color error,
  Color onPrimary,
  Color onSecondary,
  Color onSurface,
  Color onBackground,
  Color onError,
});

/// Abstract base class for theme color definitions
///
/// Implementations should provide static color palettes
/// and follow the naming convention of the specific theme.
abstract class BaseThemeColors {
  BaseThemeColors._();

  /// The main color palette for this theme
  static const ThemeColorPalette palette = (
    primary: Colors.blue,
    primaryVariant: Colors.blueAccent,
    secondary: Colors.orange,
    secondaryVariant: Colors.orangeAccent,
    surface: Colors.white,
    background: Colors.grey,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
  );
}

/// Abstract base class for app themes
///
/// All theme implementations should extend this class and provide
/// the required theme data and metadata.
abstract class BaseAppTheme {
  /// Unique key that is stored in the database
  String get key;

  /// Localised or human‑readable name for the theme
  String get name;

  /// Optional description of the theme
  String get description => "";

  /// Whether this theme supports both light and dark modes
  bool get supportsDarkMode => true;

  /// The FlexSchemeData that defines the color scheme
  FlexSchemeData get schemeData;

  /// Light theme colors from the scheme
  FlexSchemeColor get lightColors => schemeData.light;

  /// Dark theme colors from the scheme
  FlexSchemeColor get darkColors => schemeData.dark;

  /// Sub-theme configuration data
  FlexSubThemesData get subThemeData => const FlexSubThemesData();

  /// Light theme data
  ThemeData get lightTheme {
    return FlexThemeData.light(
      colors: lightColors,
      surfaceMode: FlexSurfaceMode.level,
      blendLevel: 8,
      subThemesData: subThemeData,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    );
  }

  /// Dark theme data
  ThemeData get darkTheme {
    return FlexThemeData.dark(
      colors: darkColors,
      surfaceMode: FlexSurfaceMode.level,
      blendLevel: 15,
      subThemesData: subThemeData,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    );
  }
}

/// Theme variants containing both light and dark themes
typedef ThemeVariants = ({ThemeData light, ThemeData dark});

/// Extension to easily get theme variants from BaseAppTheme
extension ThemeVariantsExtension on BaseAppTheme {
  /// Get both light and dark theme variants
  ThemeVariants get variants => (light: lightTheme, dark: darkTheme);
}

/// Draft theme implementation for user-created themes
///
/// This class allows users to create custom themes by providing
/// their own color schemes and configurations.
class DraftTheme extends BaseAppTheme {
  final String _key;
  final String _name;
  final String _description;
  final FlexSchemeData _schemeData;
  final FlexSubThemesData _subThemeData;
  final bool _supportsDarkMode;

  DraftTheme({
    required String key,
    required String name,
    required FlexSchemeData schemeData,
    String description = "",
    FlexSubThemesData? subThemeData,
    bool supportsDarkMode = true,
  })  : _key = key,
        _name = name,
        _description = description,
        _schemeData = schemeData,
        _subThemeData = subThemeData ?? const FlexSubThemesData(),
        _supportsDarkMode = supportsDarkMode;

  @override
  String get key => _key;

  @override
  String get name => _name;

  @override
  String get description => _description;

  @override
  bool get supportsDarkMode => _supportsDarkMode;

  @override
  FlexSchemeData get schemeData => _schemeData;

  @override
  FlexSubThemesData get subThemeData => _subThemeData;

  /// Create a draft theme from seed colors
  factory DraftTheme.fromSeedColors({
    required String key,
    required String name,
    required Color lightSeed,
    Color? darkSeed,
    String description = "",
    FlexSubThemesData? subThemeData,
  }) {
    final lightScheme = FlexSchemeColor.from(
      primary: lightSeed,
      brightness: Brightness.light,
    );

    final darkScheme = FlexSchemeColor.from(
      primary: darkSeed ?? lightSeed,
      brightness: Brightness.dark,
    );

    final schemeData = FlexSchemeData(
      name: name,
      description: description,
      light: lightScheme,
      dark: darkScheme,
    );

    return DraftTheme(
      key: key,
      name: name,
      description: description,
      schemeData: schemeData,
      subThemeData: subThemeData,
    );
  }

  /// Create a copy of this theme with modified properties
  DraftTheme copyWith({
    String? key,
    String? name,
    String? description,
    FlexSchemeData? schemeData,
    FlexSubThemesData? subThemeData,
    bool? supportsDarkMode,
  }) {
    return DraftTheme(
      key: key ?? _key,
      name: name ?? _name,
      description: description ?? _description,
      schemeData: schemeData ?? _schemeData,
      subThemeData: subThemeData ?? _subThemeData,
      supportsDarkMode: supportsDarkMode ?? _supportsDarkMode,
    );
  }
}
