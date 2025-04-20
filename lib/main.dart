import "package:chenron/core/setup/main_setup.dart";
import "package:chenron/core/themes/nier_theme.dart";
import "package:chenron/features/home/pages/error_page.dart";
import "package:chenron/features/home/pages/homepage.dart";
import "package:chenron/features/theme/controller/theme_controller.dart";
import "package:chenron/locator.dart";

import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

import "package:chenron/utils/logger.dart";

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await MainSetup.setup();
    runApp(const MyApp());
  } catch (error, stackTrace) {
    loggerGlobal.severe(
        "Startup", "Failed to initialize app: $error", error, stackTrace);
    // Optionally, show a fallback error UI instead of rethrowing
    runApp(ErrorApp(error: error)); // Example fallback
  }
}

// --- Main App Widget ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final themeController = locator.get<ThemeController>();

      return MaterialApp(
        title: "Chenron",
        theme: themeController.currentThemeSignal.value.light,
        darkTheme: themeController.currentThemeSignal.value.dark,
        themeAnimationDuration: const Duration(milliseconds: 300),
        themeAnimationCurve: Curves.easeInOut,
        themeMode: themeController.themeModeSignal.value,
        home: const HomePage(title: "Chenron"),
      );
    });
  }
}
