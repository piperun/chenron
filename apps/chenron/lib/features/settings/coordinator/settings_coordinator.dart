import "package:database/database.dart";
import "package:signals/signals.dart";

import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/settings/state/archive_settings.dart";
import "package:chenron/features/settings/state/backup_settings.dart";
import "package:chenron/features/settings/state/database_settings.dart";
import "package:chenron/features/settings/state/display_settings.dart";
import "package:chenron/features/settings/state/settings_section.dart";
import "package:chenron/features/settings/state/theme_settings.dart";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:app_logger/app_logger.dart";

/// Composes the per-section notifiers and orchestrates the page-level
/// load + save flow.
///
/// Sections come in two flavours:
///   - Conform to [SettingsSection] (hydrate from `UserConfig`, write
///     back via the [ConfigService]): [archive], [display], [theme].
///   - Have their own load/save story: [backup] (separate row in the
///     `BackupSettings` table), [database] (SharedPreferences).
///
/// `hasUnsavedChanges` aggregates across all five.
class SettingsCoordinator {
  final ConfigService _configService;

  late final ArchiveSettingsNotifier archive;
  late final DisplaySettingsNotifier display;
  late final ThemeSettingsNotifier theme;
  late final BackupSettingsNotifier backup;
  late final DatabaseSettingsNotifier database;

  late final List<SettingsSection> _uniformSections;

  /// User-config row id, captured at [initialize] and reused by [saveAll].
  String? _configId;

  final isLoading = signal<bool>(true);
  final error = signal<String?>(null);

  /// Last loaded `UserConfig` row — exposed for UIs that still want
  /// the whole record (e.g. legacy `ConfigController` bridge).
  final userConfig = signal<UserConfig?>(null);

  SettingsCoordinator({
    required ConfigService configService,
    required DataSettingsService dataService,
    required ThemeNotifier themeApplier,
    required ThemeOptionsStore optionsStore,
  }) : _configService = configService {
    archive = ArchiveSettingsNotifier(configService);
    display = DisplaySettingsNotifier(configService);
    theme = ThemeSettingsNotifier(configService, themeApplier, optionsStore);
    backup = BackupSettingsNotifier(configService);
    database = DatabaseSettingsNotifier(dataService);
    _uniformSections = [archive, display, theme];
  }

  /// True if any section has unsaved edits.
  bool get hasUnsavedChanges =>
      _uniformSections.any((s) => s.isDirty) ||
      backup.isDirty ||
      database.isDirty;

  /// Load every source: SharedPreferences for the db path, the
  /// UserConfig row for the uniform sections, the BackupSetting row,
  /// and the theme list. Errors are caught and surfaced via [error];
  /// individual sections fall back to their default snapshot.
  Future<void> initialize() async {
    isLoading.value = true;
    error.value = null;
    try {
      await database.load();

      final configResult = await _configService.getUserConfig();
      if (configResult != null) {
        final config = configResult.data;
        _configId = config.id;
        userConfig.value = config;

        for (final section in _uniformSections) {
          section.hydrate(config);
        }

        await theme.loadAvailableThemes();

        // Apply persisted per-theme options now so the active theme
        // renders with the user's stored toggles on first paint
        // rather than reverting to the theme's own defaults.
        final String? activeKey = theme.current.value.selectedKey;
        if (activeKey != null) {
          await theme.loadOptionsFor(activeKey);
        }

        final backupRow = await _configService.getBackupSettings();
        backup.hydrateBackup(backupRow);
      } else {
        _configId = null;
        userConfig.value = null;
        error.value = "Failed to load user configuration.";
        // Sections keep their default snapshots; theme still loads its
        // list so the UI has something to render.
        await theme.loadAvailableThemes();
      }
    } catch (e, s) {
      loggerGlobal.severe("SettingsCoordinator", "Initialization error", e, s);
      error.value = "Initialization failed: $e";
    } finally {
      isLoading.value = false;
    }
  }

  /// Persist every dirty section. Returns true if all saves succeeded.
  ///
  /// Sections that aren't dirty are skipped — this is the
  /// per-section save granularity the old monolithic `saveSettings`
  /// couldn't offer.
  Future<bool> saveAll() async {
    isLoading.value = true;
    error.value = null;
    try {
      final configId = _configId;
      final futures = <Future<void>>[];

      if (configId != null) {
        for (final section in _uniformSections) {
          if (section.isDirty) futures.add(section.save(configId));
        }
      }
      if (backup.isDirty) futures.add(backup.save());
      if (database.isDirty) futures.add(database.save());

      await Future.wait(futures);

      // Refresh the cached UserConfig snapshot so callers see the new
      // saved state on subsequent reads.
      if (configId != null) {
        final updated = await _configService.getUserConfig();
        if (updated != null) userConfig.value = updated.data;
      }
      return true;
    } catch (e, s) {
      loggerGlobal.severe("SettingsCoordinator", "Save error", e, s);
      error.value = "Failed to save settings: $e";
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
