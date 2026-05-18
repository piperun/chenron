import "package:database/main.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:vibe/vibe.dart";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/settings/state/theme_choice.dart";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:chenron/locator.dart";

/// Legacy controller — bridges the 24-signal monolithic API used by
/// existing settings UIs to the new section-based [SettingsCoordinator].
///
/// Each public signal mirrors a value owned by a section notifier.
/// `update*` methods write through to both the local signal (for UI
/// reactivity) and the underlying notifier (so coordinator-level save
/// and dirty-tracking see the edit).
///
/// This file goes away in Phase 9 once every settings UI consumes its
/// section notifier directly via the coordinator.
class ConfigController {
  late final SettingsCoordinator _coordinator;

  ConfigController()
      : _coordinator = locator.get<SettingsCoordinator>();

  @visibleForTesting
  ConfigController.withDeps({
    required ConfigService configService,
    required DataSettingsService dataSettingsService,
    required ThemeNotifier themeController,
  }) : _coordinator = SettingsCoordinator(
          configService: configService,
          dataService: dataSettingsService,
          themeApplier: themeController,
        );

  // ---------------------------------------------------------------------------
  // Public signals — kept for backwards compatibility. Mirror coordinator
  // section snapshots; see _syncFromCoordinator below.
  // ---------------------------------------------------------------------------

  final isLoading = signal<bool>(true);
  final error = signal<String?>(null);
  final userConfig = signal<UserConfig?>(null);

  final appDatabasePath = signal<String?>(null);
  String? savedAppDatabasePath;

  final selectedThemeChoice = signal<ThemeChoice?>(null);
  final availableThemes = signal<List<ThemeChoice>>([]);
  final themeSortMode = signal<ThemeSortMode>(ThemeSortMode.name);

  final backupSettings = signal<BackupSetting?>(null);
  final backupInterval = signal<String?>(null);
  final backupPath = signal<String?>(null);

  // ---------------------------------------------------------------------------
  // Init / save / dirty — all delegate to the coordinator.
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    isLoading.value = true;
    error.value = null;
    await _coordinator.initialize();
    _syncFromCoordinator();
    error.value = _coordinator.error.value;
    isLoading.value = false;
  }

  Future<bool> saveSettings() async {
    isLoading.value = true;
    final ok = await _coordinator.saveAll();
    if (ok) _syncFromCoordinator();
    error.value = _coordinator.error.value;
    isLoading.value = false;
    return ok;
  }

  bool hasUnsavedChanges() => _coordinator.hasUnsavedChanges;

  /// Copy the coordinator's section snapshots into the legacy signals.
  /// Called after [initialize] and successful [saveSettings] so the
  /// legacy UI subscribers see fresh values.
  void _syncFromCoordinator() {
    userConfig.value = _coordinator.userConfig.value;

    final themeSnap = _coordinator.theme.current.value;
    availableThemes.value = _coordinator.theme.availableThemes.value;
    selectedThemeChoice.value = _coordinator.theme.selectedChoice.value;

    final backupSnap = _coordinator.backup.current.value;
    backupSettings.value = _backupRowFromCoordinator();
    backupInterval.value = backupSnap.backupInterval;
    backupPath.value = backupSnap.backupPath;

    appDatabasePath.value = _coordinator.database.current.value;
    savedAppDatabasePath = _coordinator.database.saved.value;

    // Silence unused locals (legacy signal mirrors above already touched
    // every snapshot field we care about).
    themeSnap;
  }

  BackupSetting? _backupRowFromCoordinator() {
    final userId = userConfig.peek()?.id;
    if (userId == null) return null;
    final snap = _coordinator.backup.current.value;
    // The legacy UI only reads `.backupInterval`/`.backupPath` off this
    // object; we synthesise a row with the bare minimum so existing
    // reads keep working.
    return BackupSetting(
      id: "",
      userConfigId: userId,
      backupFilename: null,
      backupPath: snap.backupPath,
      backupInterval: snap.backupInterval,
      lastBackupTimestamp: null,
    );
  }

  // ---------------------------------------------------------------------------
  // Theme helpers preserved for the existing theme settings UI.
  // ---------------------------------------------------------------------------

  List<ThemeChoice> get sortedThemes => _coordinator.theme.sortedThemes.value;

  ThemeVariants? getPreviewVariants(ThemeChoice choice) =>
      _coordinator.theme.getPreviewVariants(choice);

  // ---------------------------------------------------------------------------
  // Update methods — write through to both the legacy signal AND the
  // section notifier so the coordinator sees the edit for dirty/save.
  // ---------------------------------------------------------------------------

  void updateSelectedTheme(ThemeChoice? choice) {
    selectedThemeChoice.value = choice;
    _coordinator.theme.select(choice);
  }

  void updateAppDatabasePath(String? value) {
    appDatabasePath.value = value;
    _coordinator.database.update(value);
  }

  void updateBackupInterval(String? value) {
    backupInterval.value = value;
    _coordinator.backup.update((s) => s.copyWith(backupInterval: value));
  }

  void updateBackupPath(String? value) {
    backupPath.value = value;
    _coordinator.backup.update((s) => s.copyWith(backupPath: value));
  }
}
