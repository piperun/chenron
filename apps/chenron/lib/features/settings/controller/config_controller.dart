import "package:database/main.dart";
import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:meta/meta.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/theme/state/theme_controller.dart";
import "package:chenron/providers/theme_controller_signal.dart";
import "package:chenron/locator.dart";
import "package:logger/logger.dart";

@immutable
class ThemeChoice {
  final String key;
  final String name;
  final ThemeType type;

  const ThemeChoice(
      {required this.key, required this.name, required this.type});

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
  final ConfigService _configService = locator.get<ConfigService>();
  final ThemeController _themeController = themeControllerSignal.value;

  final isLoading = signal<bool>(true);
  final error = signal<String?>(null);
  final userConfig = signal<UserConfig?>(null);

  final selectedThemeChoice = signal<ThemeChoice?>(null);
  final availableThemes = signal<List<ThemeChoice>>([]);

  final defaultArchiveIs = signal<bool>(false);
  final defaultArchiveOrg = signal<bool>(false);
  final archiveOrgS3AccessKey = signal<String?>(null);
  final archiveOrgS3SecretKey = signal<String?>(null);
  final timeDisplayFormat = signal<int>(0); // 0 = relative, 1 = absolute
  final itemClickAction = signal<int>(0); // 0 = Open URL, 1 = Show Details
  final cacheDirectory = signal<String?>(null); // null = use default temp dir

  Future<void> initialize() async {
    isLoading.value = true;
    error.value = null;
    try {
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
      availableThemes.value = [];
      selectedThemeChoice.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAvailableThemes() async {
    final List<ThemeChoice> choices = [];

    choices.add(const ThemeChoice(
        key: "nier", name: "Nier Automata", type: ThemeType.system));

    // Example: Add standard FlexScheme themes
    for (var scheme in FlexScheme.values) {
      choices.add(ThemeChoice(
          key: scheme.name,
          name: scheme.name,
          type: ThemeType.system));
    }

    final customThemes = await _configService.getAllUserThemes();
    for (var themeResult in customThemes) {
      choices.add(ThemeChoice(
          key: themeResult.data.id,
          name: themeResult.data.name,
          type: ThemeType.custom));
    }

    availableThemes.value = choices;
    loggerGlobal.info(
        "ConfigController", "Loaded ${choices.length} available themes.");
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

  void updateCacheDirectory(String? value) {
    cacheDirectory.value = value;
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
      );

      await _themeController.changeTheme(selectedTheme.key, selectedTheme.type);

      // Refresh the user config to reflect the saved changes
      final updatedConfigResult = await _configService.getUserConfig();
      if (updatedConfigResult != null) {
        userConfig.value = updatedConfigResult.data;
      }

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

    return defaultArchiveIs.peek() != originalConfig.defaultArchiveIs ||
        defaultArchiveOrg.peek() != originalConfig.defaultArchiveOrg ||
        archiveOrgS3AccessKey.peek()?.trim() !=
            originalConfig.archiveOrgS3AccessKey ||
        archiveOrgS3SecretKey.peek()?.trim() !=
            originalConfig.archiveOrgS3SecretKey ||
        currentSelected?.key != originalConfig.selectedThemeKey ||
        currentSelected?.type.index != originalConfig.selectedThemeType ||
        timeDisplayFormat.peek() != originalConfig.timeDisplayFormat ||
        itemClickAction.peek() != originalConfig.itemClickAction ||
        cacheDirectory.peek() != originalConfig.cacheDirectory;
  }
}

