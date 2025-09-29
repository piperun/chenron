import "package:chenron/core/setup/main_setup.dart";
import "package:chenron/features/shell/pages/error_page.dart";
import "package:chenron/features/shell/pages/root.dart";
import "package:chenron/features/theme/state/theme_manager.dart";
import "package:chenron/locator.dart";
import "package:chenron/providers/theme_controller_signal.dart";

import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

import "package:chenron/utils/logger.dart";

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await MainSetup.setup();
    loggerGlobal.info("main", "Waiting for locator dependencies...");
    await locator.allReady();
    loggerGlobal.info("main", "Locator ready, running app.");
    runApp(const MyApp());
  } catch (error, stackTrace) {
    loggerGlobal.severe(
        "Startup", "Failed to initialize app: $error", error, stackTrace);
    runApp(ErrorApp(error: error));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = locator.get<ThemeManager>();

    return Watch((context) {
      final ThemeMode? currentMode = themeManager.themeModeSignal.value;

      // Get current theme variants (light/dark) from ThemeController
      final themeController = themeControllerSignal.value;
      final variants = themeController.currentThemeSignal.value;

      loggerGlobal.fine(
          "MyApp.build", "Building with ThemeMode: $currentMode and dynamic theme");

      return MaterialApp(
        title: "Chenron",
        theme: variants.light,
        darkTheme: variants.dark,
        themeAnimationDuration: const Duration(milliseconds: 300),
        themeAnimationCurve: Curves.easeInOut,
        themeMode: currentMode ?? ThemeMode.light,
        home: const RootPage(),
      );
    });
  }
}
