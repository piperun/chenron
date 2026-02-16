import "dart:io";

import "package:chenron/core/setup/main_setup.dart";
import "package:chenron/features/shell/pages/error_page.dart";
import "package:chenron/features/shell/pages/root.dart";
import "package:chenron/features/theme/state/theme_manager.dart";
import "package:chenron/locator.dart";
import "package:chenron/providers/theme_controller_signal.dart";
import "package:chenron/services/window_service.dart";

import "package:chenron/shared/constants/durations.dart";
import "package:flutter/material.dart";

import "package:shared_preferences/shared_preferences.dart";
import "package:signals/signals_flutter.dart";
import "package:window_manager/window_manager.dart";

import "package:app_logger/app_logger.dart";

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Read cached preferences before any heavy setup so the first frame
    // renders with the correct theme and the database opens from the
    // right location.
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool("dark_mode") ?? false;
    final initialThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final customAppDbPath = prefs.getString("app_database_path");

    // Restore persisted window size on desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await _initWindowManager(prefs);
    }

    await MainSetup.setup(customAppDbPath: customAppDbPath);
    loggerGlobal.info("main", "Waiting for locator dependencies...");
    await locator.allReady();
    loggerGlobal.info("main", "Locator ready, running app.");
    runApp(ChenronApp(initialThemeMode: initialThemeMode));
  } catch (error, stackTrace) {
    loggerGlobal.severe(
        "Startup", "Failed to initialize app: $error", error, stackTrace);
    runApp(ErrorApp(error: error));
  }
}

Future<void> _initWindowManager(SharedPreferences prefs) async {
  await windowManager.ensureInitialized();

  final windowService = WindowService(prefs);
  final saved = windowService.getSavedWindowSize();

  final display = WidgetsBinding.instance.platformDispatcher.displays.first;
  final screenSize = display.size / display.devicePixelRatio;

  final targetSize = WindowService.computeTargetSize(
    savedSize: saved,
    screenSize: screenSize,
  );

  final options = WindowOptions(
    size: targetSize,
    center: true,
    titleBarStyle: TitleBarStyle.normal,
    title: "Chenron",
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Persist size changes on window resize and close
  windowManager.addListener(_WindowSizeListener(windowService));
}

class _WindowSizeListener extends WindowListener {
  final WindowService _service;

  _WindowSizeListener(this._service);

  @override
  Future<void> onWindowResized() async {
    final size = await windowManager.getSize();
    await _service.saveWindowSize(size);
  }

  @override
  Future<void> onWindowClose() async {
    final size = await windowManager.getSize();
    await _service.saveWindowSize(size);
  }
}

class ChenronApp extends StatelessWidget {
  final ThemeMode initialThemeMode;

  const ChenronApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    final themeManager = locator.get<ThemeManager>();

    return Watch((context) {
      final ThemeMode? currentMode = themeManager.themeModeSignal.value;

      // Get current theme variants (light/dark) from ThemeController
      final themeController = themeControllerSignal.value;
      final variants = themeController.currentThemeSignal.value;

      loggerGlobal.fine(
          "ChenronApp.build", "Building with ThemeMode: $currentMode and dynamic theme");

      return MaterialApp(
        title: "Chenron",
        theme: variants.light,
        darkTheme: variants.dark,
        themeAnimationDuration: kDefaultAnimationDuration,
        themeAnimationCurve: Curves.easeInOut,
        themeMode: currentMode ?? initialThemeMode,
        home: const RootPage(),
      );
    });
  }
}

