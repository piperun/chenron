import "package:database/database.dart";
import "package:database/main.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/theme/state/theme_controller.dart";

import "package:chenron_mockups/chenron_mockups.dart";

import "config_controller_test.mocks.dart";

// ---------------------------------------------------------------------------
// Factories
// ---------------------------------------------------------------------------

UserConfig makeUserConfig({
  String id = "cfg-1",
  bool defaultArchiveIs = false,
  bool defaultArchiveOrg = false,
  String? archiveOrgS3AccessKey,
  String? archiveOrgS3SecretKey,
  String? selectedThemeKey = "nier",
  int selectedThemeType = 1, // ThemeType.system index
  int timeDisplayFormat = 0,
  int itemClickAction = 0,
  String? cacheDirectory,
  bool showDescription = true,
  bool showImages = true,
  bool showTags = true,
  bool showCopyLink = true,
}) =>
    UserConfig(
      id: id,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
      darkMode: false,
      copyOnImport: false,
      defaultArchiveIs: defaultArchiveIs,
      defaultArchiveOrg: defaultArchiveOrg,
      archiveOrgS3AccessKey: archiveOrgS3AccessKey,
      archiveOrgS3SecretKey: archiveOrgS3SecretKey,
      selectedThemeKey: selectedThemeKey,
      selectedThemeType: selectedThemeType,
      timeDisplayFormat: timeDisplayFormat,
      itemClickAction: itemClickAction,
      cacheDirectory: cacheDirectory,
      showDescription: showDescription,
      showImages: showImages,
      showTags: showTags,
      showCopyLink: showCopyLink,
    );

UserConfigResult makeConfigResult([UserConfig? config]) =>
    UserConfigResult(data: config ?? makeUserConfig());

BackupSetting makeBackupSetting({
  String id = "bk-1",
  String userConfigId = "cfg-1",
  String? backupInterval,
  String? backupPath,
}) =>
    BackupSetting(
      id: id,
      userConfigId: userConfigId,
      backupInterval: backupInterval,
      backupPath: backupPath,
    );

/// Stubs ConfigService + DataSettingsService for a successful initialize().
void stubHappyPath(
  MockConfigService mockConfig,
  MockDataSettingsService mockData, {
  UserConfig? config,
  BackupSetting? backup,
  String? dbPath,
}) {
  when(mockData.getCustomDatabasePath()).thenAnswer((_) async => dbPath);
  when(mockConfig.getUserConfig())
      .thenAnswer((_) async => makeConfigResult(config));
  when(mockConfig.getBackupSettings()).thenAnswer((_) async => backup);
  when(mockConfig.getAllUserThemes())
      .thenAnswer((_) async => <UserThemeResult>[]);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

@GenerateMocks([ConfigService, DataSettingsService, ThemeController])
void main() {
  setUpAll(installTestLogger);

  late MockConfigService mockConfig;
  late MockDataSettingsService mockData;
  late MockThemeController mockTheme;
  late ConfigController controller;

  setUp(() {
    mockConfig = MockConfigService();
    mockData = MockDataSettingsService();
    mockTheme = MockThemeController();
    controller = ConfigController.withDeps(
      configService: mockConfig,
      dataSettingsService: mockData,
      themeController: mockTheme,
    );
  });

  // -------------------------------------------------------------------------
  // initialize()
  // -------------------------------------------------------------------------
  group("initialize()", () {
    test("populates signals from config", () async {
      final config = makeUserConfig(
        defaultArchiveIs: true,
        defaultArchiveOrg: true,
        archiveOrgS3AccessKey: "ak",
        archiveOrgS3SecretKey: "sk",
        timeDisplayFormat: 1,
        itemClickAction: 1,
        cacheDirectory: "/cache",
        showDescription: false,
        showImages: false,
        showTags: false,
        showCopyLink: false,
      );
      stubHappyPath(mockConfig, mockData, config: config);

      await controller.initialize();

      expect(controller.defaultArchiveIs.value, isTrue);
      expect(controller.defaultArchiveOrg.value, isTrue);
      expect(controller.archiveOrgS3AccessKey.value, equals("ak"));
      expect(controller.archiveOrgS3SecretKey.value, equals("sk"));
      expect(controller.timeDisplayFormat.value, equals(1));
      expect(controller.itemClickAction.value, equals(1));
      expect(controller.cacheDirectory.value, equals("/cache"));
      expect(controller.showDescription.value, isFalse);
      expect(controller.showImages.value, isFalse);
      expect(controller.showTags.value, isFalse);
      expect(controller.showCopyLink.value, isFalse);
      expect(controller.error.value, isNull);
    });

    test("loads backup settings into signals", () async {
      final backup = makeBackupSetting(
        backupInterval: "0 0 */4 * * *",
        backupPath: "/my/backups",
      );
      stubHappyPath(mockConfig, mockData, backup: backup);

      await controller.initialize();

      expect(controller.backupSettings.value, equals(backup));
      expect(controller.backupInterval.value, equals("0 0 */4 * * *"));
      expect(controller.backupPath.value, equals("/my/backups"));
    });

    test("sets error on null config result", () async {
      when(mockData.getCustomDatabasePath()).thenAnswer((_) async => null);
      when(mockConfig.getUserConfig()).thenAnswer((_) async => null);
      when(mockConfig.getAllUserThemes())
          .thenAnswer((_) async => <UserThemeResult>[]);

      await controller.initialize();

      expect(controller.error.value, isNotNull);
      expect(controller.userConfig.value, isNull);
    });

    test("sets error on service exception", () async {
      when(mockData.getCustomDatabasePath())
          .thenThrow(Exception("db exploded"));

      await controller.initialize();

      expect(controller.error.value, isNotNull);
      expect(controller.userConfig.value, isNull);
      expect(controller.defaultArchiveIs.value, isFalse);
      expect(controller.backupSettings.value, isNull);
      expect(controller.backupInterval.value, isNull);
    });

    test("isLoading is false after completion", () async {
      stubHappyPath(mockConfig, mockData);

      await controller.initialize();

      expect(controller.isLoading.value, isFalse);
    });

    test("isLoading is false after error", () async {
      when(mockData.getCustomDatabasePath())
          .thenThrow(Exception("boom"));

      await controller.initialize();

      expect(controller.isLoading.value, isFalse);
    });

    test("loads database path from DataSettingsService", () async {
      stubHappyPath(mockConfig, mockData, dbPath: "/custom/db");

      await controller.initialize();

      expect(controller.appDatabasePath.value, equals("/custom/db"));
      expect(controller.savedAppDatabasePath, equals("/custom/db"));
    });
  });

  // -------------------------------------------------------------------------
  // saveSettings()
  // -------------------------------------------------------------------------
  group("saveSettings()", () {
    /// Initializes the controller with the given config + backup, then stubs
    /// the save-related service calls so saveSettings() can run end-to-end.
    Future<void> initAndStubSave({
      UserConfig? config,
      BackupSetting? backup,
      BackupSetting? updatedBackup,
    }) async {
      final cfg = config ?? makeUserConfig();
      final bk = backup;
      stubHappyPath(mockConfig, mockData, config: cfg, backup: bk);
      await controller.initialize();

      // Stubs for saveSettings() calls
      when(mockConfig.updateUserConfig(
        configId: anyNamed("configId"),
        defaultArchiveIs: anyNamed("defaultArchiveIs"),
        defaultArchiveOrg: anyNamed("defaultArchiveOrg"),
        archiveOrgS3AccessKey: anyNamed("archiveOrgS3AccessKey"),
        archiveOrgS3SecretKey: anyNamed("archiveOrgS3SecretKey"),
        selectedThemeKey: anyNamed("selectedThemeKey"),
        selectedThemeType: anyNamed("selectedThemeType"),
        timeDisplayFormat: anyNamed("timeDisplayFormat"),
        itemClickAction: anyNamed("itemClickAction"),
        cacheDirectory: anyNamed("cacheDirectory"),
        showDescription: anyNamed("showDescription"),
        showImages: anyNamed("showImages"),
        showTags: anyNamed("showTags"),
        showCopyLink: anyNamed("showCopyLink"),
      )).thenAnswer((_) async {});

      when(mockConfig.updateBackupSettings(
        id: anyNamed("id"),
        backupInterval: anyNamed("backupInterval"),
        backupPath: anyNamed("backupPath"),
        clearInterval: anyNamed("clearInterval"),
      )).thenAnswer((_) async {});

      when(mockTheme.changeTheme(any, any)).thenAnswer((_) async {});

      // Post-save reload stubs
      when(mockConfig.getUserConfig())
          .thenAnswer((_) async => makeConfigResult(cfg));
      when(mockConfig.getBackupSettings())
          .thenAnswer((_) async => updatedBackup ?? bk);
    }

    test("calls updateUserConfig with current signal values", () async {
      final config = makeUserConfig(
        defaultArchiveIs: true,
        timeDisplayFormat: 1,
      );
      await initAndStubSave(config: config);

      final result = await controller.saveSettings();

      expect(result, isTrue);
      verify(mockConfig.updateUserConfig(
        configId: "cfg-1",
        defaultArchiveIs: true,
        defaultArchiveOrg: false,
        archiveOrgS3AccessKey: null,
        archiveOrgS3SecretKey: null,
        selectedThemeKey: anyNamed("selectedThemeKey"),
        selectedThemeType: anyNamed("selectedThemeType"),
        timeDisplayFormat: 1,
        itemClickAction: 0,
        cacheDirectory: null,
        showDescription: true,
        showImages: true,
        showTags: true,
        showCopyLink: true,
      )).called(1);
    });

    test("calls updateBackupSettings when backup exists", () async {
      final backup = makeBackupSetting();
      await initAndStubSave(backup: backup);
      controller.backupInterval.value = "0 0 */8 * * *";
      controller.backupPath.value = "/backups";

      await controller.saveSettings();

      verify(mockConfig.updateBackupSettings(
        id: "bk-1",
        backupInterval: "0 0 */8 * * *",
        backupPath: "/backups",
        clearInterval: false,
      )).called(1);
    });

    test("sets clearInterval=true when interval is null", () async {
      final backup = makeBackupSetting(
        backupInterval: "0 0 */4 * * *",
      );
      await initAndStubSave(backup: backup);
      controller.backupInterval.value = null;

      await controller.saveSettings();

      verify(mockConfig.updateBackupSettings(
        id: "bk-1",
        backupInterval: null,
        backupPath: anyNamed("backupPath"),
        clearInterval: true,
      )).called(1);
    });

    test("sets clearInterval=false when interval has value", () async {
      final backup = makeBackupSetting();
      await initAndStubSave(backup: backup);
      controller.backupInterval.value = "0 0 0 * * *";

      await controller.saveSettings();

      verify(mockConfig.updateBackupSettings(
        id: anyNamed("id"),
        backupInterval: "0 0 0 * * *",
        backupPath: anyNamed("backupPath"),
        clearInterval: false,
      )).called(1);
    });

    test("syncs backup signals after save (regression)", () async {
      final backup = makeBackupSetting();
      final updatedBackup = makeBackupSetting(
        backupInterval: "0 0 */12 * * *",
        backupPath: "/new/path",
      );
      await initAndStubSave(backup: backup, updatedBackup: updatedBackup);

      await controller.saveSettings();

      expect(
          controller.backupInterval.value, equals("0 0 */12 * * *"));
      expect(controller.backupPath.value, equals("/new/path"));
    });

    test("calls changeTheme with selected theme", () async {
      await initAndStubSave();

      await controller.saveSettings();

      verify(mockTheme.changeTheme(any, any)).called(1);
    });

    test("returns false when config is null", () async {
      // Don't initialize — userConfig stays null
      final result = await controller.saveSettings();

      expect(result, isFalse);
      expect(controller.error.value, contains("not loaded"));
    });

    test("returns false when no theme selected", () async {
      stubHappyPath(mockConfig, mockData);
      await controller.initialize();
      // Force selectedThemeChoice to null
      controller.selectedThemeChoice.value = null;

      // Stub userConfig so it's non-null but theme is null
      final result = await controller.saveSettings();

      expect(result, isFalse);
      expect(controller.error.value, contains("No theme"));
    });

    test("returns false on service exception", () async {
      await initAndStubSave();

      // Override updateUserConfig to throw
      when(mockConfig.updateUserConfig(
        configId: anyNamed("configId"),
        defaultArchiveIs: anyNamed("defaultArchiveIs"),
        defaultArchiveOrg: anyNamed("defaultArchiveOrg"),
        archiveOrgS3AccessKey: anyNamed("archiveOrgS3AccessKey"),
        archiveOrgS3SecretKey: anyNamed("archiveOrgS3SecretKey"),
        selectedThemeKey: anyNamed("selectedThemeKey"),
        selectedThemeType: anyNamed("selectedThemeType"),
        timeDisplayFormat: anyNamed("timeDisplayFormat"),
        itemClickAction: anyNamed("itemClickAction"),
        cacheDirectory: anyNamed("cacheDirectory"),
        showDescription: anyNamed("showDescription"),
        showImages: anyNamed("showImages"),
        showTags: anyNamed("showTags"),
        showCopyLink: anyNamed("showCopyLink"),
      )).thenThrow(Exception("save failed"));

      final result = await controller.saveSettings();

      expect(result, isFalse);
      expect(controller.error.value, isNotNull);
      expect(controller.isLoading.value, isFalse);
    });

    test("saves database path via DataSettingsService when changed",
        () async {
      await initAndStubSave();
      controller.appDatabasePath.value = "/new/db/path";
      when(mockData.setCustomDatabasePath(any)).thenAnswer((_) async {});

      await controller.saveSettings();

      verify(mockData.setCustomDatabasePath("/new/db/path")).called(1);
    });

    test("skips database path save when unchanged", () async {
      await initAndStubSave();
      // Don't change appDatabasePath — stays equal to savedAppDatabasePath

      await controller.saveSettings();

      verifyNever(mockData.setCustomDatabasePath(any));
    });

    test("skips backup save when backupSettings is null", () async {
      await initAndStubSave(backup: null);

      await controller.saveSettings();

      verifyNever(mockConfig.updateBackupSettings(
        id: anyNamed("id"),
        backupInterval: anyNamed("backupInterval"),
        backupPath: anyNamed("backupPath"),
        clearInterval: anyNamed("clearInterval"),
      ));
    });

    test("trims archiveOrg keys before saving", () async {
      await initAndStubSave();
      controller.archiveOrgS3AccessKey.value = "  my-key  ";
      controller.archiveOrgS3SecretKey.value = "  secret  ";

      await controller.saveSettings();

      verify(mockConfig.updateUserConfig(
        configId: anyNamed("configId"),
        defaultArchiveIs: anyNamed("defaultArchiveIs"),
        defaultArchiveOrg: anyNamed("defaultArchiveOrg"),
        archiveOrgS3AccessKey: "my-key",
        archiveOrgS3SecretKey: "secret",
        selectedThemeKey: anyNamed("selectedThemeKey"),
        selectedThemeType: anyNamed("selectedThemeType"),
        timeDisplayFormat: anyNamed("timeDisplayFormat"),
        itemClickAction: anyNamed("itemClickAction"),
        cacheDirectory: anyNamed("cacheDirectory"),
        showDescription: anyNamed("showDescription"),
        showImages: anyNamed("showImages"),
        showTags: anyNamed("showTags"),
        showCopyLink: anyNamed("showCopyLink"),
      )).called(1);
    });
  });

  // -------------------------------------------------------------------------
  // hasUnsavedChanges()
  // -------------------------------------------------------------------------
  group("hasUnsavedChanges()", () {
    test("returns false when nothing changed", () async {
      stubHappyPath(mockConfig, mockData);
      await controller.initialize();

      expect(controller.hasUnsavedChanges(), isFalse);
    });

    test("detects theme change", () async {
      stubHappyPath(mockConfig, mockData);
      await controller.initialize();

      controller.selectedThemeChoice.value = const ThemeChoice(
        key: "different",
        name: "Different",
        type: ThemeType.system,
      );

      expect(controller.hasUnsavedChanges(), isTrue);
    });

    test("detects toggle change", () async {
      stubHappyPath(mockConfig, mockData);
      await controller.initialize();

      controller.defaultArchiveIs.value = true;

      expect(controller.hasUnsavedChanges(), isTrue);
    });

    test("detects backup interval change", () async {
      stubHappyPath(mockConfig, mockData);
      await controller.initialize();

      controller.backupInterval.value = "0 0 */8 * * *";

      expect(controller.hasUnsavedChanges(), isTrue);
    });

    test("detects database path change", () async {
      stubHappyPath(mockConfig, mockData);
      await controller.initialize();

      controller.appDatabasePath.value = "/different/path";

      expect(controller.hasUnsavedChanges(), isTrue);
    });

    test("returns false when config is null", () async {
      // Don't initialize — userConfig stays null
      expect(controller.hasUnsavedChanges(), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // update*() setters
  // -------------------------------------------------------------------------
  group("update setters", () {
    test("updateBackupInterval sets signal", () {
      controller.updateBackupInterval("0 0 */4 * * *");
      expect(controller.backupInterval.value, equals("0 0 */4 * * *"));

      controller.updateBackupInterval(null);
      expect(controller.backupInterval.value, isNull);
    });

    test("updateBackupPath sets signal", () {
      controller.updateBackupPath("/my/path");
      expect(controller.backupPath.value, equals("/my/path"));

      controller.updateBackupPath(null);
      expect(controller.backupPath.value, isNull);
    });
  });
}
