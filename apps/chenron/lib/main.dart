import "dart:async";
import "dart:io";

import "package:chenron/core/setup/main_setup.dart";
import "package:chenron/features/shell/pages/error_page.dart";
import "package:chenron/features/shell/pages/root.dart";
import "package:chenron/features/theme/state/theme_cache.dart";
import "package:chenron/features/theme/state/theme_manager.dart";
import "package:chenron/locator.dart";
import "package:chenron/providers/theme_controller_signal.dart";
import "package:chenron/services/window_service.dart";

import "package:chenron/shared/constants/durations.dart";
import "package:flutter/material.dart";

import "package:shared_preferences/shared_preferences.dart";
import "package:signals/signals_flutter.dart";
import "package:vibe/vibe.dart";
import "package:window_manager/window_manager.dart";

import "package:app_logger/app_logger.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read cached preferences before any heavy setup so the first frame
  // renders with the correct theme and the database opens from the
  // right location.
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool("dark_mode") ?? false;
  final initialThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;
  final cachedTheme = ThemeCache.loadCachedTheme(prefs);

  // Restore persisted window size on desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await _initWindowManager(prefs);
  }

  // Show a loading screen immediately, then initialize in the background.
  // This eliminates the blank white window that appears while databases,
  // directories, and services are being set up.
  runApp(AppBootstrap(
    initialThemeMode: initialThemeMode,
    cachedTheme: cachedTheme,
    prefs: prefs,
  ));
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

class AppBootstrap extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final ThemeVariants? cachedTheme;
  final SharedPreferences prefs;

  const AppBootstrap({
    super.key,
    required this.initialThemeMode,
    this.cachedTheme,
    required this.prefs,
  });

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _isReady = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      final customAppDbPath = widget.prefs.getString("app_database_path");
      await MainSetup.setup(customAppDbPath: customAppDbPath);
      loggerGlobal.info("AppBootstrap", "Waiting for locator dependencies...");
      await locator.allReady();
      loggerGlobal.info("AppBootstrap", "Locator ready.");
      if (mounted) setState(() => _isReady = true);

      // Non-critical tasks (backup scheduler, daily snapshot) run after
      // the UI is visible so the app feels responsive immediately.
      await MainSetup.runDeferredTasks();
    } catch (error, stackTrace) {
      loggerGlobal.severe(
          "AppBootstrap", "Failed to initialize: $error", error, stackTrace);
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return ErrorApp(error: _error!);
    if (!_isReady) {
      return _LoadingView(
        themeMode: widget.initialThemeMode,
        cachedTheme: widget.cachedTheme,
      );
    }
    return ChenronApp(
      initialThemeMode: widget.initialThemeMode,
      cachedTheme: widget.cachedTheme,
    );
  }
}

class _LoadingView extends StatelessWidget {
  final ThemeMode themeMode;
  final ThemeVariants? cachedTheme;
  const _LoadingView({required this.themeMode, this.cachedTheme});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: cachedTheme?.light ?? ThemeData.light(),
      darkTheme: cachedTheme?.dark ?? ThemeData.dark(),
      themeMode: themeMode,
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text("Loading..."),
            ],
          ),
        ),
      ),
    );
  }
}

class ChenronApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  final ThemeVariants? cachedTheme;

  const ChenronApp({
    super.key,
    required this.initialThemeMode,
    this.cachedTheme,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = locator.get<ThemeManager>();

    // Seed the controller with cached theme so the first Watch frame
    // already has the right colors (before initialize() finishes).
    if (cachedTheme != null) {
      final controller = themeControllerSignal.value;
      controller.seedCachedTheme(cachedTheme!);
    }

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

