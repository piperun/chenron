import "package:chenron/features/settings/state/theme_choice.dart";
import "package:chenron/features/settings/state/theme_settings.dart";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:database/database.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "archive_settings_notifier_test.mocks.dart";
import "theme_settings_notifier_test.mocks.dart";

@GenerateMocks([ThemeNotifier])
void main() {
  late MockConfigService service;
  late MockThemeNotifier themeApplier;
  late ThemeSettingsNotifier notifier;

  setUp(() {
    service = MockConfigService();
    themeApplier = MockThemeNotifier();
    notifier = ThemeSettingsNotifier(service, themeApplier);
  });

  UserConfig stubConfig({
    String? selectedThemeKey = "materialBaseline",
    int selectedThemeType = 0,
  }) =>
      UserConfig(
        id: "cfg",
        darkMode: false,
        archiveOrgS3AccessKey: null,
        archiveOrgS3SecretKey: null,
        copyOnImport: false,
        defaultArchiveIs: false,
        defaultArchiveOrg: false,
        selectedThemeKey: selectedThemeKey,
        selectedThemeType: selectedThemeType,
        timeDisplayFormat: 0,
        itemClickAction: 0,
        showDescription: true,
        showImages: true,
        showTags: true,
        showCopyLink: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  test("hydrate maps selectedThemeType int into ThemeType enum", () {
    // ThemeType is {custom: 0, system: 1}
    notifier.hydrate(stubConfig(selectedThemeKey: "nier", selectedThemeType: 0));
    expect(notifier.current.value.selectedKey, "nier");
    expect(notifier.current.value.selectedType, ThemeType.custom);
    expect(notifier.isDirty, isFalse);
  });

  test("select changes current and flips isDirty", () {
    notifier.hydrate(stubConfig());
    notifier.select(const ThemeChoice(
      key: "nier",
      name: "Nier",
      type: ThemeType.system,
    ));
    expect(notifier.current.value.selectedKey, "nier");
    expect(notifier.isDirty, isTrue);
  });

  test("select(null) is a no-op", () {
    notifier.hydrate(stubConfig());
    notifier.select(null);
    expect(notifier.isDirty, isFalse);
  });

  test("save throws when no key selected", () async {
    // hydrate with a null key (edge case — user config never persisted one)
    notifier.hydrate(stubConfig(selectedThemeKey: null));
    await expectLater(notifier.save("cfg"), throwsStateError);
    verifyNever(service.updateThemeSection(
      configId: anyNamed("configId"),
      selectedThemeKey: anyNamed("selectedThemeKey"),
      selectedThemeType: anyNamed("selectedThemeType"),
    ));
  });

  test("save writes theme section and applies via ThemeNotifier",
      () async {
    when(service.updateThemeSection(
      configId: anyNamed("configId"),
      selectedThemeKey: anyNamed("selectedThemeKey"),
      selectedThemeType: anyNamed("selectedThemeType"),
    )).thenAnswer((_) => Future<void>.value());
    when(themeApplier.changeTheme(any, any))
        .thenAnswer((_) => Future<void>.value());

    notifier.hydrate(stubConfig());
    notifier.select(const ThemeChoice(
      key: "nier",
      name: "Nier",
      type: ThemeType.system,
    ));

    await notifier.save("cfg");

    verify(service.updateThemeSection(
      configId: "cfg",
      selectedThemeKey: "nier",
      selectedThemeType: ThemeType.system,
    )).called(1);
    verify(themeApplier.changeTheme("nier", ThemeType.system)).called(1);
    expect(notifier.isDirty, isFalse);
  });

  test("save failure on service leaves saved untouched (no apply)",
      () async {
    when(service.updateThemeSection(
      configId: anyNamed("configId"),
      selectedThemeKey: anyNamed("selectedThemeKey"),
      selectedThemeType: anyNamed("selectedThemeType"),
    )).thenThrow(Exception("db locked"));

    notifier.hydrate(stubConfig());
    notifier.select(const ThemeChoice(
      key: "nier",
      name: "Nier",
      type: ThemeType.system,
    ));

    await expectLater(notifier.save("cfg"), throwsException);
    verifyNever(themeApplier.changeTheme(any, any));
    expect(notifier.isDirty, isTrue);
  });

  test("setSortMode swaps sort order of sortedThemes", () {
    notifier.availableThemes.value = [
      const ThemeChoice(
          key: "b", name: "B", type: ThemeType.system, colorCount: 1),
      const ThemeChoice(
          key: "a", name: "A", type: ThemeType.system, colorCount: 3),
    ];

    notifier.setSortMode(ThemeSortMode.name);
    expect(notifier.sortedThemes.value.first.key, "a");

    notifier.setSortMode(ThemeSortMode.colorCount);
    expect(notifier.sortedThemes.value.first.key, "a"); // highest colorCount
  });
}
