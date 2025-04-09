import "package:chenron/core/ui/search/searchbar.dart";
import "package:chenron/database/database.dart" show UserConfig;
import "package:chenron/database/extensions/operations/config_file_handler.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:chenron/root.dart";
import "package:chenron/utils/directory/directory.dart";
import "package:chenron/utils/logger.dart";
import "package:chenron/utils/scheduler.dart";
import "package:chenron/database/extensions/user_config/read.dart";
import "package:chenron/database/extensions/user_config/update.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

final _themeModeSignal = signal<ThemeMode>(ThemeMode.system);

Future<void> setupConfig() async {
  final configHandler = locator.get<Signal<ConfigDatabaseFileHandler>>();
  final baseDir =
      await locator.get<Signal<Future<ChenronDirectories?>>>().value;
  if (baseDir == null) {
    loggerGlobal.severe("SetupConfig", "Base directory not initialized");
    throw Exception("Base directory not initialized");
  }
  final databaseLocation = DatabaseLocation(
    databaseDirectory: baseDir.configDir,
    databaseFilename: "config.sqlite",
  );
  configHandler.value.databaseLocation = databaseLocation;
  configHandler.value.createDatabase(setupOnInit: true);

  // Load theme preference from database
  await loadThemePreference(configHandler);
}

// Add this function to load the theme preference
Future<void> loadThemePreference(
    Signal<ConfigDatabaseFileHandler> handler) async {
  try {
    final UserConfig? config = await handler.value.configDatabase
        .getUserConfig()
        .then((config) => config?.data);

    if (config != null) {
      _themeModeSignal.value =
          config.darkMode ? ThemeMode.dark : ThemeMode.light;
      loggerGlobal.info("Theme",
          "Loaded theme preference: ${config.darkMode ? 'dark' : 'light'}");
    } else {
      loggerGlobal.info(
          "Theme", "No theme preference found, using system default");
    }
  } catch (e) {
    loggerGlobal.warning("Theme", "Failed to load theme preference: $e");
    // Keep default ThemeMode.system if there's an error
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    locatorSetup();
    await setupConfig();
    scheduleBackup();
    runApp(const MyApp());
  } catch (e) {
    loggerGlobal.severe("Startup", "Failed to initialize app: $e");
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => MaterialApp(
        title: "Chenron",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: _themeModeSignal.value,
        themeAnimationDuration: const Duration(milliseconds: 300),
        themeAnimationCurve: Curves.easeInOut,
        home: const MyHomePage(title: "Chenron"),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const GlobalSearchBar(),
        actions: [const DarkModeButton()],
      ),
      body: const RootPage(),
    );
  }
}

class DarkModeButton extends StatelessWidget {
  const DarkModeButton({super.key});
  @override
  Widget build(BuildContext context) {
    final configHandler = locator.get<Signal<ConfigDatabaseFileHandler>>();

    return Watch(
      (context) => IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            _themeModeSignal.value == ThemeMode.dark
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
          ),
        ),
        onPressed: () => _handleThemeToggle(configHandler),
      ),
    );
  }

  Future<void> _handleThemeToggle(
      Signal<ConfigDatabaseFileHandler> handler) async {
    final UserConfig? config = await handler.value.configDatabase
        .getUserConfig()
        .then((config) => config?.data);
    if (config == null) return;

    final newDarkMode = !config.darkMode;
    _themeModeSignal.value = newDarkMode ? ThemeMode.dark : ThemeMode.light;
    await handler.value.configDatabase.updateUserConfig(
      id: config.id,
      darkMode: newDarkMode,
    );
  }
}
