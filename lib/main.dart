import "package:chenron/core/setup/main_setup.dart";
import "package:chenron/features/home/pages/error_page.dart";
import "package:chenron/features/home/pages/root.dart";
import "package:chenron/features/theme/manager/theme_manager.dart";
import "package:chenron/locator.dart";

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
      final currentMode = themeManager.themeModeSignal.value;

      loggerGlobal.fine("MyApp.build", "Building with ThemeMode: $currentMode");

      final lightTheme = ThemeData.light(useMaterial3: true).copyWith(
        appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
      );
      final darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
        appBarTheme: const AppBarTheme(backgroundColor: Colors.indigo),
      );

      return MaterialApp(
        title: "Chenron",
        theme: lightTheme,
        darkTheme: darkTheme,
        themeAnimationDuration: const Duration(milliseconds: 300),
        themeAnimationCurve: Curves.easeInOut,
        themeMode: currentMode ?? ThemeMode.light,
        home: const RootPage(),
      );
    });
  }
}
