import "package:chenron/database/database.dart" show ThemeType;
import "package:chenron/database/extensions/operations/config_file_handler.dart";
import "package:chenron/features/theme/service/theme_service.dart";
import "package:chenron/features/theme/utils/theme_utils.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/db_result.dart";
import "package:chenron/utils/logger.dart";
import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

ThemeServiceDB? _themeService;

typedef ThemeVariants = ({ThemeData light, ThemeData dark});

class ThemeController {
  final Signal<ThemeMode> themeModeSignal = Signal<ThemeMode>(ThemeMode.system);
  final Signal<ThemeVariants> currentThemeSignal = Signal<ThemeVariants>((
    light: FlexThemeData.light(scheme: FlexScheme.blueWhale),
    dark: FlexThemeData.dark(scheme: FlexScheme.blueWhale),
  ));
  Future<void> initialize() async {
    try {
      await locator.allReady();
      final configHandlerSignal =
          locator.get<Signal<ConfigDatabaseFileHandler>>();
      final configDb = configHandlerSignal.value.configDatabase;

      _themeService = await ThemeServiceDB.init(database: configDb);
      if (_themeService != null) {
        themeModeSignal.value = await getThemeMode();
        await setCurrentTheme();
      }
    } catch (error, stackTrace) {
      debugPrintStack(
          stackTrace: stackTrace,
          label: "Error initializing ThemeController: $error");
    }
  }

  Future<void> changeThemeMode({required bool isDark}) async {
    themeModeSignal.value = isDark ? ThemeMode.dark : ThemeMode.light;
    await _themeService?.changeThemeMode(isDark: !isDark);
  }

  Future<void> changeTheme(String themeKey, ThemeType themeType) async {
    return _themeService?.changeTheme(themeKey, themeType);
  }

  Future<void> setCurrentTheme() async {
    final UserThemeResult? theme = await _themeService?.getCurrentTheme();
    if (theme == null) return;
    if (_themeService?.configData.data.selectedThemeType ==
        ThemeType.custom.index) {
      currentThemeSignal.value = generateSeedTheme(
        primaryColor: theme.data.primaryColor,
        secondaryColor: theme.data.secondaryColor,
        tertiaryColor: theme.data.tertiaryColor,
        seedType: theme.data.seedType,
      );
    } else {
      currentThemeSignal.value = getPredefinedTheme(
              _themeService?.configData.data.selectedThemeKey ?? "") ??
          (
            light: FlexThemeData.light(scheme: FlexScheme.blueWhale),
            dark: FlexThemeData.dark(scheme: FlexScheme.blueWhale)
          );
    }
  }

  Future<ThemeMode> getThemeMode() async {
    return _themeService?.configData.data.darkMode == true
        ? ThemeMode.dark
        : ThemeMode.light;
  }
}

/// Builds a FlexColorScheme-based light/dark pair from seed data stored
/// in the database.
///
/// [primaryColor] must always be provided.
/// [secondaryColor] and [tertiaryColor] may be null in DB (optional).
///
/// [seedType] comes from `UserThemes.seedType`:
///   0 = no key-color seeding (keyColors parameter is omitted)
///   1 = use primary as key color
///   2 = use primary + secondary
///   3 = use primary + secondary + tertiary
ThemeVariants generateSeedTheme({
  required int primaryColor,
  required int secondaryColor,
  int? tertiaryColor,
  required int seedType,
}) {
  final FlexSchemeColor customColors = FlexSchemeColor(
    primary: Color(primaryColor),
    secondary: Color(secondaryColor),
    tertiary: tertiaryColor != null ? Color(tertiaryColor) : null,
  );

  FlexColorScheme lightScheme;
  FlexColorScheme darkScheme;

  if (seedType > 0) {
    final FlexKeyColors keyColorSettings = FlexKeyColors(
      useKeyColors: true,
      useSecondary: seedType >= 2,
      useTertiary: seedType >= 3,
    );

    lightScheme = FlexColorScheme.light(
      colors: customColors,
      keyColors: keyColorSettings,
    );
    darkScheme = FlexColorScheme.dark(
      colors: customColors,
      keyColors: keyColorSettings,
    );
  } else {
    lightScheme = FlexColorScheme.light(
      colors: customColors,
    );
    darkScheme = FlexColorScheme.dark(
      colors: customColors,
    );
  }

  return (
    light: lightScheme.toTheme,
    dark: darkScheme.toTheme,
  );
}
