import "package:database/main.dart";
import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:vibe/vibe.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/theme/state/theme_controller.dart";
import "package:chenron/features/theme/state/theme_utils.dart";
import "package:chenron/providers/theme_controller_signal.dart";
import "package:chenron/locator.dart";
import "package:app_logger/app_logger.dart";

enum ThemeSortMode { name, colorCount }

@immutable
class ThemeChoice {
  final String key;
  final String name;
  final ThemeType type;
  final int colorCount;
  final List<Color> swatches;

  const ThemeChoice({
    required this.key,
    required this.name,
    required this.type,
    this.colorCount = 1,
    this.swatches = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeChoice &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          type == other.type;

  @override
  int get hashCode => key.hashCode ^ type.hashCode;
}

class ConfigController {
  late final ConfigService _configService;
  late final DataSettingsService _dataService;
  late final ThemeController _themeController;

  ConfigController()
      : _configService = locator.get<ConfigService>(),
        _dataService = locator.get<DataSettingsService>(),
        _themeController = themeControllerSignal.value;

  @visibleForTesting
  ConfigController.withDeps({
    required ConfigService configService,
    required DataSettingsService dataSettingsService,
    required ThemeController themeController,
  })  : _configService = configService,
        _dataService = dataSettingsService,
        _themeController = themeController;

  final isLoading = signal<bool>(true);
  final error = signal<String?>(null);
  final userConfig = signal<UserConfig?>(null);

  // Database path (stored in SharedPreferences, not config database)
  final appDatabasePath = signal<String?>(null);
  String? savedAppDatabasePath;

  final selectedThemeChoice = signal<ThemeChoice?>(null);
  final availableThemes = signal<List<ThemeChoice>>([]);
  final themeSortMode = signal<ThemeSortMode>(ThemeSortMode.name);

  final defaultArchiveIs = signal<bool>(false);
  final defaultArchiveOrg = signal<bool>(false);
  final archiveOrgS3AccessKey = signal<String?>(null);
  final archiveOrgS3SecretKey = signal<String?>(null);
  final timeDisplayFormat = signal<int>(0); // 0 = relative, 1 = absolute
  final itemClickAction = signal<int>(0); // 0 = Open URL, 1 = Show Details
  final cacheDirectory = signal<String?>(null); // null = use default temp dir

  // Viewer display preferences
  final showDescription = signal<bool>(true);
  final showImages = signal<bool>(true);
  final showTags = signal<bool>(true);
  final showCopyLink = signal<bool>(true);

  // Backup schedule signals
  final backupSettings = signal<BackupSetting?>(null);
  final backupInterval = signal<String?>(null); // cron expression
  final backupPath = signal<String?>(null);

  Future<void> initialize() async {
    isLoading.value = true;
    error.value = null;
    try {
      // Load database path from SharedPreferences (not config database)
      final savedPath = await _dataService.getCustomDatabasePath();
      appDatabasePath.value = savedPath;
      savedAppDatabasePath = savedPath;

      final configResult = await _configService.getUserConfig();
      if (configResult != null) {
        final config = configResult.data;
        userConfig.value = config;

        defaultArchiveIs.value = config.defaultArchiveIs;
        defaultArchiveOrg.value = config.defaultArchiveOrg;
        archiveOrgS3AccessKey.value = config.archiveOrgS3AccessKey;
        archiveOrgS3SecretKey.value = config.archiveOrgS3SecretKey;
        timeDisplayFormat.value = config.timeDisplayFormat;
        itemClickAction.value = config.itemClickAction;
        cacheDirectory.value = config.cacheDirectory;
        showDescription.value = config.showDescription;
        showImages.value = config.showImages;
        showTags.value = config.showTags;
        showCopyLink.value = config.showCopyLink;

        final backup = await _configService.getBackupSettings();
        backupSettings.value = backup;
        backupInterval.value = backup?.backupInterval;
        backupPath.value = backup?.backupPath;

        await _loadAvailableThemes();
        final initialChoice = availableThemes.peek().firstWhere(
              (choice) =>
                  choice.key == config.selectedThemeKey &&
                  choice.type.index == config.selectedThemeType,
              orElse: () => availableThemes.peek().first,
            );
        selectedThemeChoice.value = initialChoice;
      } else {
        error.value = "Failed to load user configuration.";

        defaultArchiveIs.value = false;
        defaultArchiveOrg.value = false;
        archiveOrgS3AccessKey.value = null;
        archiveOrgS3SecretKey.value = null;
        timeDisplayFormat.value = 0;
        itemClickAction.value = 0;
        cacheDirectory.value = null;
        showDescription.value = true;
        showImages.value = true;
        showTags.value = true;
        showCopyLink.value = true;
        backupSettings.value = null;
        backupInterval.value = null;
        backupPath.value = null;
        await _loadAvailableThemes();
        selectedThemeChoice.value = availableThemes.peek().isNotEmpty
            ? availableThemes.peek().first
            : null;
      }
    } catch (e, s) {
      loggerGlobal.severe("ConfigController", "Initialization error", e, s);
      error.value = "An error occurred during initialization: $e";

      userConfig.value = null;
      defaultArchiveIs.value = false;
      defaultArchiveOrg.value = false;
      archiveOrgS3AccessKey.value = null;
      archiveOrgS3SecretKey.value = null;
      timeDisplayFormat.value = 0;
      itemClickAction.value = 0;
      cacheDirectory.value = null;
      showDescription.value = true;
      showImages.value = true;
      showTags.value = true;
      showCopyLink.value = true;
      backupSettings.value = null;
      backupInterval.value = null;
      backupPath.value = null;
      availableThemes.value = [];
      selectedThemeChoice.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAvailableThemes() async {
    final List<ThemeChoice> choices = [];

    // Nier Automata (custom theme with known swatches)
    const nierP = Color(0xFFD1CDB7); // canvasBeige
    const nierS = Color(0xFF454138); // textBrownGrey
    const nierT = Color(0xFF38AAA1); // hudTeal
    choices.add(ThemeChoice(
      key: "nier",
      name: "Nier Automata",
      type: ThemeType.system,
      colorCount: countDistinctHues(nierP, nierS, nierT),
      swatches: distinctSwatches(nierP, nierS, nierT),
    ));

    // FlexScheme built-in themes (skip the "custom" placeholder)
    for (final scheme in FlexScheme.values) {
      if (scheme == FlexScheme.custom) continue;
      final data = scheme.data;
      final p = data.light.primary;
      final s = data.light.secondary;
      final t = data.light.tertiary;
      final count = countDistinctHues(p, s, t);
      choices.add(ThemeChoice(
        key: scheme.name,
        name: data.name,
        type: ThemeType.system,
        colorCount: count,
        swatches: distinctSwatches(p, s, t),
      ));
    }

    // User-created custom themes
    final customThemes = await _configService.getAllUserThemes();
    for (final themeResult in customThemes) {
      final d = themeResult.data;
      final p = Color(d.primaryColor);
      final s = Color(d.secondaryColor);
      final t = d.tertiaryColor != null ? Color(d.tertiaryColor!) : s;
      final count = countDistinctHues(p, s, t);
      choices.add(ThemeChoice(
        key: d.id,
        name: d.name,
        type: ThemeType.custom,
        colorCount: count,
        swatches: distinctSwatches(p, s, t),
      ));
    }

    availableThemes.value = choices;
    loggerGlobal.info(
        "ConfigController", "Loaded ${choices.length} available themes.");
  }

  List<ThemeChoice> get sortedThemes {
    final list = [...availableThemes.value];
    switch (themeSortMode.value) {
      case ThemeSortMode.name:
        list.sort((a, b) => a.name.compareTo(b.name));
      case ThemeSortMode.colorCount:
        list.sort((a, b) => b.colorCount.compareTo(a.colorCount));
    }
    return list;
  }

  /// Builds the full light/dark [ThemeVariants] for the given [choice]
  /// so the UI can show a color-role preview.
  ThemeVariants? getPreviewVariants(ThemeChoice choice) {
    if (choice.type == ThemeType.system) {
      return getPredefinedTheme(choice.key);
    }
    // Custom themes: approximate from stored swatches
    if (choice.swatches.isEmpty) return null;
    return buildSeededVariants(
      primary: choice.swatches.first,
      secondary: choice.swatches.length > 1 ? choice.swatches[1] : null,
      tertiary: choice.swatches.length > 2 ? choice.swatches[2] : null,
      useSecondary: choice.swatches.length > 1,
      useTertiary: choice.swatches.length > 2,
    );
  }

  // --- UI Interaction Methods ---
  void updateSelectedTheme(ThemeChoice? choice) {
    selectedThemeChoice.value = choice;
    loggerGlobal.fine("ConfigController",
        "UI selected theme: ${choice?.key} (${choice?.type})");
  }

  void updateDefaultArchiveIs({required bool enabled}) {
    defaultArchiveIs.value = enabled;
  }

  void updateDefaultArchiveOrg({required bool enabled}) {
    defaultArchiveOrg.value = enabled;
  }

  void updateArchiveOrgS3AccessKey(String? value) {
    archiveOrgS3AccessKey.value = value;
  }

  void updateArchiveOrgS3SecretKey(String? value) {
    archiveOrgS3SecretKey.value = value;
  }

  void updateTimeDisplayFormat(int value) {
    timeDisplayFormat.value = value;
  }

  void updateItemClickAction(int value) {
    itemClickAction.value = value;
  }

  void updateAppDatabasePath(String? value) {
    appDatabasePath.value = value;
  }

  void updateCacheDirectory(String? value) {
    cacheDirectory.value = value;
  }

  void updateBackupInterval(String? value) {
    backupInterval.value = value;
  }

  void updateBackupPath(String? value) {
    backupPath.value = value;
  }

  void updateShowDescription({required bool enabled}) {
    showDescription.value = enabled;
  }

  void updateShowImages({required bool enabled}) {
    showImages.value = enabled;
  }

  void updateShowTags({required bool enabled}) {
    showTags.value = enabled;
  }

  void updateShowCopyLink({required bool enabled}) {
    showCopyLink.value = enabled;
  }

  // --- Saving ---
  Future<bool> saveSettings() async {
    final config = userConfig.peek();
    final selectedTheme = selectedThemeChoice.peek();

    if (config == null) {
      error.value = "Cannot save: Original configuration not loaded.";
      return false;
    }
    if (selectedTheme == null) {
      error.value = "Cannot save: No theme selected.";
      return false;
    }

    isLoading.value = true;
    error.value = null;

    try {
      loggerGlobal.info("ConfigController", "Starting save operation...");

      // Save database path to SharedPreferences
      final newDbPath = appDatabasePath.peek();
      if (newDbPath != savedAppDatabasePath) {
        await _dataService.setCustomDatabasePath(newDbPath);
        savedAppDatabasePath = newDbPath;
      }

      await _configService.updateUserConfig(
        configId: config.id,
        defaultArchiveIs: defaultArchiveIs.peek(),
        defaultArchiveOrg: defaultArchiveOrg.peek(),
        archiveOrgS3AccessKey: archiveOrgS3AccessKey.peek()?.trim(),
        archiveOrgS3SecretKey: archiveOrgS3SecretKey.peek()?.trim(),
        selectedThemeKey: selectedTheme.key,
        selectedThemeType: selectedTheme.type,
        timeDisplayFormat: timeDisplayFormat.peek(),
        itemClickAction: itemClickAction.peek(),
        cacheDirectory: cacheDirectory.peek(),
        showDescription: showDescription.peek(),
        showImages: showImages.peek(),
        showTags: showTags.peek(),
        showCopyLink: showCopyLink.peek(),
      );

      // Save backup settings if they exist
      final backup = backupSettings.peek();
      if (backup != null) {
        final intervalValue = backupInterval.peek();
        await _configService.updateBackupSettings(
          id: backup.id,
          backupInterval: intervalValue,
          backupPath: backupPath.peek(),
          clearInterval: intervalValue == null,
        );
      }

      await _themeController.changeTheme(selectedTheme.key, selectedTheme.type);

      // Refresh to reflect saved changes
      final updatedConfigResult = await _configService.getUserConfig();
      if (updatedConfigResult != null) {
        userConfig.value = updatedConfigResult.data;
      }
      final updatedBackup = await _configService.getBackupSettings();
      backupSettings.value = updatedBackup;
      backupInterval.value = updatedBackup?.backupInterval;
      backupPath.value = updatedBackup?.backupPath;

      loggerGlobal.info("ConfigController", "Settings saved successfully.");
      return true;
    } catch (e, s) {
      loggerGlobal.severe("ConfigController", "Error saving settings", e, s);
      error.value = "Failed to save settings: $e";
      return false;
    } finally {
      // Always set loading to false in the finally block
      isLoading.value = false;
    }
  }

  bool hasUnsavedChanges() {
    final originalConfig = userConfig.peek();
    if (originalConfig == null) {
      return false;
    }

    final currentSelected = selectedThemeChoice.peek();

    final originalBackup = backupSettings.peek();

    return appDatabasePath.peek() != savedAppDatabasePath ||
        defaultArchiveIs.peek() != originalConfig.defaultArchiveIs ||
        defaultArchiveOrg.peek() != originalConfig.defaultArchiveOrg ||
        archiveOrgS3AccessKey.peek()?.trim() !=
            originalConfig.archiveOrgS3AccessKey ||
        archiveOrgS3SecretKey.peek()?.trim() !=
            originalConfig.archiveOrgS3SecretKey ||
        currentSelected?.key != originalConfig.selectedThemeKey ||
        currentSelected?.type.index != originalConfig.selectedThemeType ||
        timeDisplayFormat.peek() != originalConfig.timeDisplayFormat ||
        itemClickAction.peek() != originalConfig.itemClickAction ||
        cacheDirectory.peek() != originalConfig.cacheDirectory ||
        showDescription.peek() != originalConfig.showDescription ||
        showImages.peek() != originalConfig.showImages ||
        showTags.peek() != originalConfig.showTags ||
        showCopyLink.peek() != originalConfig.showCopyLink ||
        backupInterval.peek() != originalBackup?.backupInterval ||
        backupPath.peek() != originalBackup?.backupPath;
  }
}

