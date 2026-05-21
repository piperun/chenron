import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:database/database.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "settings_coordinator_test.mocks.dart";

@GenerateMocks([ConfigService, DataSettingsService, ThemeNotifier])
void main() {
  late MockConfigService configService;
  late MockDataSettingsService dataService;
  late MockThemeNotifier themeApplier;
  late SettingsCoordinator coordinator;

  setUp(() {
    configService = MockConfigService();
    dataService = MockDataSettingsService();
    themeApplier = MockThemeNotifier();
    coordinator = SettingsCoordinator(
      configService: configService,
      dataService: dataService,
      themeApplier: themeApplier,
      optionsStore: ThemeOptionsStore(),
    );

    // Defaults — happy path stubs.
    when(dataService.getCustomDatabasePath())
        .thenAnswer((_) async => null);
    when(configService.getAllUserThemes())
        .thenAnswer((_) async => <UserThemeResult>[]);
    when(configService.getBackupSettings())
        .thenAnswer((_) async => null);
  });

  UserConfigResult stubConfigResult({
    String id = "cfg-1",
    bool defaultArchiveOrg = false,
    TimeDisplayFormat timeDisplayFormat = TimeDisplayFormat.relative,
    String? selectedThemeKey = "materialBaseline",
    ThemeType selectedThemeType = ThemeType.system,
  }) {
    return UserConfigResult(
      data: UserConfig(
        id: id,
        darkMode: false,
        archiveOrgS3AccessKey: null,
        archiveOrgS3SecretKey: null,
        copyOnImport: false,
        defaultArchiveIs: false,
        defaultArchiveOrg: defaultArchiveOrg,
        selectedThemeKey: selectedThemeKey,
        selectedThemeType: selectedThemeType,
        timeDisplayFormat: timeDisplayFormat,
        itemClickAction: ItemClickAction.openItem,
        showDescription: true,
        showImages: true,
        showTags: true,
        showCopyLink: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  test("initialize hydrates every section from UserConfig", () async {
    when(configService.getUserConfig())
        .thenAnswer((_) async => stubConfigResult(
              defaultArchiveOrg: true,
              timeDisplayFormat: TimeDisplayFormat.absolute,
            ));

    await coordinator.initialize();

    expect(coordinator.archive.current.value.defaultArchiveOrg, isTrue);
    expect(coordinator.display.current.value.timeDisplayFormat, 1);
    expect(coordinator.isLoading.value, isFalse);
    expect(coordinator.error.value, isNull);
    expect(coordinator.hasUnsavedChanges, isFalse);
  });

  test("hasUnsavedChanges aggregates across sections", () async {
    when(configService.getUserConfig())
        .thenAnswer((_) async => stubConfigResult());
    await coordinator.initialize();
    expect(coordinator.hasUnsavedChanges, isFalse);

    coordinator.display.update((s) => s.copyWith(showTags: false));
    expect(coordinator.hasUnsavedChanges, isTrue);

    coordinator.display.update((s) => s.copyWith(showTags: true));
    expect(coordinator.hasUnsavedChanges, isFalse);

    coordinator.database.update("/custom/path.sqlite");
    expect(coordinator.hasUnsavedChanges, isTrue);
  });

  test("saveAll skips non-dirty sections", () async {
    when(configService.getUserConfig())
        .thenAnswer((_) async => stubConfigResult());
    when(configService.updateArchiveSection(
      configId: anyNamed("configId"),
      defaultArchiveIs: anyNamed("defaultArchiveIs"),
      defaultArchiveOrg: anyNamed("defaultArchiveOrg"),
      archiveOrgS3AccessKey: anyNamed("archiveOrgS3AccessKey"),
      archiveOrgS3SecretKey: anyNamed("archiveOrgS3SecretKey"),
    )).thenAnswer((_) => Future<void>.value());

    await coordinator.initialize();
    coordinator.archive.update((s) => s.copyWith(defaultArchiveOrg: true));

    final ok = await coordinator.saveAll();
    expect(ok, isTrue);

    verify(configService.updateArchiveSection(
      configId: "cfg-1",
      defaultArchiveIs: false,
      defaultArchiveOrg: true,
      archiveOrgS3AccessKey: null,
      archiveOrgS3SecretKey: null,
    )).called(1);
    verifyNever(configService.updateDisplaySection(
      configId: anyNamed("configId"),
      timeDisplayFormat: anyNamed("timeDisplayFormat"),
      itemClickAction: anyNamed("itemClickAction"),
      cacheDirectory: anyNamed("cacheDirectory"),
      showDescription: anyNamed("showDescription"),
      showImages: anyNamed("showImages"),
      showTags: anyNamed("showTags"),
      showCopyLink: anyNamed("showCopyLink"),
    ));
    verifyNever(themeApplier.changeTheme(any, any));
  });

  test("saveAll persists database path via DataSettingsService", () async {
    when(configService.getUserConfig())
        .thenAnswer((_) async => stubConfigResult());
    when(dataService.setCustomDatabasePath(any))
        .thenAnswer((_) => Future<void>.value());

    await coordinator.initialize();
    coordinator.database.update("/elsewhere/app.sqlite");

    final ok = await coordinator.saveAll();
    expect(ok, isTrue);

    verify(dataService.setCustomDatabasePath("/elsewhere/app.sqlite"))
        .called(1);
    expect(coordinator.hasUnsavedChanges, isFalse);
  });

  test("saveAll returns false and surfaces error on service exception",
      () async {
    when(configService.getUserConfig())
        .thenAnswer((_) async => stubConfigResult());
    when(configService.updateArchiveSection(
      configId: anyNamed("configId"),
      defaultArchiveIs: anyNamed("defaultArchiveIs"),
      defaultArchiveOrg: anyNamed("defaultArchiveOrg"),
      archiveOrgS3AccessKey: anyNamed("archiveOrgS3AccessKey"),
      archiveOrgS3SecretKey: anyNamed("archiveOrgS3SecretKey"),
    )).thenThrow(Exception("db locked"));

    await coordinator.initialize();
    coordinator.archive.update((s) => s.copyWith(defaultArchiveOrg: true));

    final ok = await coordinator.saveAll();
    expect(ok, isFalse);
    expect(coordinator.error.value, contains("db locked"));
    expect(coordinator.hasUnsavedChanges, isTrue,
        reason: "failed save must leave the section dirty");
  });

  test("initialize surfaces error when getUserConfig returns null",
      () async {
    when(configService.getUserConfig()).thenAnswer((_) async => null);

    await coordinator.initialize();

    expect(coordinator.userConfig.value, isNull);
    expect(coordinator.error.value, contains("Failed to load"));
    expect(coordinator.isLoading.value, isFalse);
  });
}
