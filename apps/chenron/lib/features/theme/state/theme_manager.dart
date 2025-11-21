import "dart:async";

import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/user_config/read.dart";
import "package:chenron/database/extensions/user_config/update.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/utils/logger.dart";

/// Manages the application's theme mode (light/dark).
///
/// Reads from and writes to the UserConfig in the ConfigDatabase.
/// Exposes the current theme mode reactively via [themeModeSignal].
/// Designed to be used as a singleton managed by a locator (like GetIt).
class ThemeManager {
  final ConfigDatabase _db;

  /// The reactive signal holding the current theme mode.
  /// Starts as `null` until the value is loaded from the database.
  final Signal<ThemeMode?> themeModeSignal = signal(null);

  // To store the UserConfig ID once loaded, needed for updates.
  String? _userConfigId;
  // To prevent multiple load attempts running concurrently and ensure loading completes.
  Completer<void>? _loadingCompleter;

  /// Creates a ThemeManager instance.
  ///
  /// Requires a [ConfigDatabase] instance to interact with storage.
  /// It will automatically attempt to load the initial theme mode from
  /// the database upon creation (asynchronously).
  ThemeManager(this._db) {
    // Start loading immediately, but don't block the constructor.
    unawaited(_loadInitialThemeMode());
  }

  /// Asynchronously loads the theme mode from the UserConfig in the database.
  /// Updates the [themeModeSignal] upon completion. Ensures only one load runs at a time.
  Future<void> _loadInitialThemeMode() async {
    // If already loading, return the existing future to wait for it
    if (_loadingCompleter != null) {
      loggerGlobal.info("ThemeManager",
          "_loadInitialThemeMode already in progress, waiting...");
      return _loadingCompleter!.future;
    }

    // Start a new loading process
    loggerGlobal.info("ThemeManager", "Starting _loadInitialThemeMode...");
    _loadingCompleter = Completer<void>();

    try {
      // Ensure the database connection/handler is ready if needed.
      // (Assuming _db is ready to be queried here, guaranteed by locator setup)
      final configResult = await _db.getUserConfig();

      if (configResult != null) {
        _userConfigId = configResult.data.id; // Store the ID for updates
        final isDark = configResult.data.darkMode;
        themeModeSignal.value = isDark ? ThemeMode.dark : ThemeMode.light;
        loggerGlobal.info("ThemeManager",
            "Initial theme mode loaded: ${themeModeSignal.value} (UserConfig ID: $_userConfigId)");
      } else {
        // UserConfig doesn't exist yet. Signal remains null.
        // This is acceptable, the UI should handle the null state.
        // A default UserConfig should be created elsewhere in the app's setup.
        loggerGlobal.warning("ThemeManager",
            "UserConfig not found during initial load. ThemeMode remains null.");
        _userConfigId = null; // Ensure ID is null if config not found
      }
    } catch (e, s) {
      loggerGlobal.severe(
          "ThemeManager", "Failed to load initial theme mode", e, s);
      // Signal remains null, indicating an error or unloaded state.
      _userConfigId = null; // Ensure ID is null on error
    } finally {
      // Mark loading as complete and allow future loads
      if (!_loadingCompleter!.isCompleted) {
        _loadingCompleter!.complete();
      }
      _loadingCompleter = null;
      loggerGlobal.info("ThemeManager", "_loadInitialThemeMode finished.");
    }
  }

  /// Sets the desired theme mode (light/dark) and persists it to the database.
  ///
  /// Updates the [themeModeSignal] optimistically.
  Future<void> setDarkMode({required bool isDark}) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;

    if (themeModeSignal.value == newMode) {
      loggerGlobal.fine("ThemeManager",
          "setDarkMode called but mode is already $newMode. No change needed.");
      return;
    }

    themeModeSignal.value = newMode;
    loggerGlobal.info(
        "ThemeManager", "Optimistically set theme mode to: $newMode");

    if (_userConfigId == null && _loadingCompleter != null) {
      loggerGlobal.warning("ThemeManager",
          "UserConfig ID not available for update yet. Waiting for initial load...");
      await _loadingCompleter!.future;
    }

    if (_userConfigId == null) {
      loggerGlobal.severe("ThemeManager",
          "Cannot persist theme mode: UserConfig ID is null. Initial load might have failed or UserConfig doesn't exist.");
      return;
    }

    try {
      loggerGlobal.info("ThemeManager",
          "Persisting darkMode=$isDark to DB for UserConfig ID: $_userConfigId");
      await _db.updateUserConfig(
        id: _userConfigId!,
        darkMode: isDark,
      );
      loggerGlobal.info(
          "ThemeManager", "Successfully persisted darkMode=$isDark.");
    } catch (e, s) {
      loggerGlobal.severe(
          "ThemeManager", "Failed to persist theme mode change", e, s);
      // Optional: Revert optimistic update here?
      // themeModeSignal.value = !isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  /// Refreshes the theme mode from the database.
  /// Useful if the database might be changed externally or after fixing an issue.
  Future<void> refreshThemeMode() async {
    loggerGlobal.info(
        "ThemeManager", "Explicitly refreshing theme mode from database...");
    await _loadInitialThemeMode();
  }
}
