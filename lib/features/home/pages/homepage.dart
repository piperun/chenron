// --- Home Page Widget --- (No changes needed)
import "package:chenron/features/theme/controller/theme_controller.dart";
import "package:chenron/shared/ui/search/searchbar.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/operations/config_file_handler.dart";
import "package:chenron/database/extensions/user_config/read.dart";
import "package:chenron/database/extensions/user_config/update.dart";
import "package:chenron/features/home/pages/root.dart";
import "package:chenron/locator.dart";
import "package:chenron/utils/logger.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

final _themeModeSignal = locator.get<ThemeController>().themeModeSignal;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const GlobalSearchBar(),
        actions: [const DarkModeButton()], // Keep the button
      ),
      body: const RootPage(),
    );
  }
}

// --- Dark Mode Button Widget ---
class DarkModeButton extends StatelessWidget {
  const DarkModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the theme mode signal for UI updates
    return Watch((context) => IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Icon(
              // Use key to help AnimatedSwitcher differentiate icons
              _themeModeSignal.value == ThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              key: ValueKey(_themeModeSignal.value), // Add key
            ),
          ),
          tooltip: _themeModeSignal.value == ThemeMode.dark
              ? "Switch to Light Mode"
              : "Switch to Dark Mode",
          onPressed: () => _handleThemeToggle(), // Call the toggle handler
        ));
  }

  // Toggle handler remains largely the same, updates signal and DB
  Future<void> _handleThemeToggle() async {
    final configHandler = locator.get<Signal<ConfigDatabaseFileHandler>>();
    UserConfig? config;
    try {
      config = await configHandler.value.configDatabase
          .getUserConfig()
          .then((configResult) => configResult?.data);
    } catch (e, s) {
      loggerGlobal.severe(
          "DarkModeButton", "Failed to get UserConfig for toggle: $e", e, s);
      // Optionally show an error to the user (e.g., SnackBar)
      return; // Don't proceed if config can't be read
    }

    if (config == null) {
      loggerGlobal.warning(
          "DarkModeButton", "Cannot toggle theme: UserConfig not found.");
      // Optionally show an error to the user
      return; // Don't proceed if no config
    }

    // Determine the new mode
    final newDarkMode = !config.darkMode;
    // Update the signal immediately for UI responsiveness
    _themeModeSignal.value = newDarkMode ? ThemeMode.dark : ThemeMode.light;
    loggerGlobal.info("DarkModeButton",
        "Toggled ThemeMode signal to: ${_themeModeSignal.value}");

    // Persist the change to the database asynchronously
    try {
      await configHandler.value.configDatabase.updateUserConfig(
        id: config.id,
        darkMode: newDarkMode,
      );
      loggerGlobal.info("DarkModeButton",
          "Persisted darkMode=$newDarkMode to DB for UserConfig ID: ${config.id}");
    } catch (e, s) {
      loggerGlobal.severe("DarkModeButton",
          "Failed to persist darkMode change to DB: $e", e, s);
      // Optionally revert the signal change or notify the user
      // Reverting might cause UI flicker, consider carefully
      // _themeModeSignal.value = !newDarkMode ? ThemeMode.dark : ThemeMode.light; // Example revert
      // Show SnackBar or dialog about save failure
    }
  }
}
