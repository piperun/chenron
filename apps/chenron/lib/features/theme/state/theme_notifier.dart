import "dart:async";

import "package:database/database.dart";
import "package:chenron/features/theme/state/theme_cache.dart";
import "package:chenron/features/theme/state/theme_service.dart";
import "package:chenron/features/theme/state/theme_utils.dart";
import "package:chenron/locator.dart";
import "package:app_logger/app_logger.dart";
import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:signals/signals_flutter.dart";
import "package:vibe/vibe.dart";

ThemeServiceDB? _themeService;

class ThemeNotifier {
  final Signal<ThemeVariants> currentThemeSignal = Signal<ThemeVariants>((
    light: FlexThemeData.light(scheme: FlexScheme.materialBaseline),
    dark: FlexThemeData.dark(scheme: FlexScheme.materialBaseline),
  ));

  bool _seeded = false;

  /// Sets the initial theme from the SharedPreferences cache.
  /// Only applies once — `initialize()` overwrites with the DB value.
  void seedCachedTheme(ThemeVariants theme) {
    if (!_seeded) {
      currentThemeSignal.value = theme;
      _seeded = true;
    }
  }

  Future<void> initialize() async {
    try {
      await locator.allReady();
      final configHandlerSignal =
          locator.get<Signal<ConfigDatabaseLifecycle>>();
      final configDb = configHandlerSignal.value.configDatabase;

      _themeService = await ThemeServiceDB.init(database: configDb);
      if (_themeService != null) {
        await setCurrentTheme();
      }
    } catch (error, stackTrace) {
      debugPrintStack(
          stackTrace: stackTrace,
          label: "Error initializing ThemeNotifier: $error");
    }
  }

  Future<void> changeTheme(String themeKey, ThemeType themeType) async {
    await _themeService?.changeTheme(themeKey, themeType);

    // Apply immediately without relying on stale config snapshots
    if (themeType == ThemeType.custom) {
      final UserThemeResult? theme =
          await _themeService?.getThemeByKey(themeKey);
      if (theme != null) {
        currentThemeSignal.value = generateSeedTheme(
          primaryColor: theme.data.primaryColor,
          secondaryColor: theme.data.secondaryColor,
          tertiaryColor: theme.data.tertiaryColor,
          seedType: theme.data.seedType.index,
        );
        _cacheCustomTheme(
          key: themeKey,
          primaryColor: theme.data.primaryColor,
          secondaryColor: theme.data.secondaryColor,
          tertiaryColor: theme.data.tertiaryColor,
          seedType: theme.data.seedType.index,
        );
        return;
      }
      // Fallback if custom theme missing: try predefined by key
      final fallback = getPredefinedTheme(themeKey);
      if (fallback != null) {
        currentThemeSignal.value = fallback;
        _cacheSystemTheme(themeKey);
        return;
      }
    } else {
      final variants = getPredefinedTheme(themeKey);
      if (variants != null) {
        currentThemeSignal.value = variants;
        _cacheSystemTheme(themeKey);
        return;
      }
    }

    // Ultimate fallback if nothing matched
    currentThemeSignal.value = (
      light: FlexThemeData.light(scheme: FlexScheme.materialBaseline),
      dark: FlexThemeData.dark(scheme: FlexScheme.materialBaseline),
    );
  }

  Future<void> setCurrentTheme() async {
    loggerGlobal.info(
        "ThemeNotifier", "Applying theme from persisted config...");
    final String? key = _themeService?.configData.data.selectedThemeKey;
    final ThemeType? type = _themeService?.configData.data.selectedThemeType;

    // Fallback if config incomplete
    if (key == null || type == null) {
      loggerGlobal.warning("ThemeNotifier",
          "No persisted theme selection found. Using fallback.");
      currentThemeSignal.value = (
        light: FlexThemeData.light(scheme: FlexScheme.materialBaseline),
        dark: FlexThemeData.dark(scheme: FlexScheme.materialBaseline),
      );
      return;
    }

    if (type == ThemeType.custom) {
      loggerGlobal.fine(
          "ThemeNotifier", "Persisted theme type: custom, key=$key");
      final UserThemeResult? theme = await _themeService?.getThemeByKey(key);
      if (theme != null) {
        currentThemeSignal.value = generateSeedTheme(
          primaryColor: theme.data.primaryColor,
          secondaryColor: theme.data.secondaryColor,
          tertiaryColor: theme.data.tertiaryColor,
          seedType: theme.data.seedType.index,
        );
        _cacheCustomTheme(
          key: key,
          primaryColor: theme.data.primaryColor,
          secondaryColor: theme.data.secondaryColor,
          tertiaryColor: theme.data.tertiaryColor,
          seedType: theme.data.seedType.index,
        );
        return;
      }
      // If custom theme missing, fall through to predefined lookup
      loggerGlobal.warning("ThemeNotifier",
          "Custom theme $key not found. Falling back to predefined mapping.");
    }

    loggerGlobal.fine(
        "ThemeNotifier", "Persisted theme type: system, key=$key");
    final variants = getPredefinedTheme(key);
    currentThemeSignal.value = variants ??
        (
          light: FlexThemeData.light(scheme: FlexScheme.materialBaseline),
          dark: FlexThemeData.dark(scheme: FlexScheme.materialBaseline),
        );
    _cacheSystemTheme(key);
  }

  void _cacheSystemTheme(String key) {
    unawaited(SharedPreferences.getInstance()
        .then((p) => ThemeCache.cacheSystemTheme(p, key: key))
        .catchError((Object e) {
      loggerGlobal.warning("ThemeNotifier", "Failed to cache theme: $e");
    }));
  }

  void _cacheCustomTheme({
    required String key,
    required int primaryColor,
    required int secondaryColor,
    int? tertiaryColor,
    required int seedType,
  }) {
    unawaited(SharedPreferences.getInstance()
        .then((p) => ThemeCache.cacheCustomTheme(
              p,
              key: key,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              tertiaryColor: tertiaryColor,
              seedType: seedType,
            ))
        .catchError((Object e) {
      loggerGlobal.warning("ThemeNotifier", "Failed to cache theme: $e");
    }));
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
  final bool useSec = seedType >= 2;
  final bool useTer = seedType >= 3;
  return buildSeededVariants(
    primary: Color(primaryColor),
    secondary: Color(secondaryColor),
    tertiary: tertiaryColor != null ? Color(tertiaryColor) : null,
    useSecondary: useSec,
    useTertiary: useTer,
  );
}
