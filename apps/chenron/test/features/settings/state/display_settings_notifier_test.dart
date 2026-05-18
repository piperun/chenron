import "package:chenron/features/settings/state/display_settings.dart";
import "package:database/database.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";

import "archive_settings_notifier_test.mocks.dart";

void main() {
  late MockConfigService service;
  late DisplaySettingsNotifier notifier;

  setUp(() {
    service = MockConfigService();
    notifier = DisplaySettingsNotifier(service);
  });

  UserConfig stubConfig({
    TimeDisplayFormat timeDisplayFormat = TimeDisplayFormat.absolute,
    ItemClickAction itemClickAction = ItemClickAction.openItem,
    String? cacheDirectory,
    bool showImages = true,
  }) =>
      UserConfig(
        id: "cfg",
        darkMode: false,
        archiveOrgS3AccessKey: null,
        archiveOrgS3SecretKey: null,
        copyOnImport: false,
        defaultArchiveIs: false,
        defaultArchiveOrg: false,
        selectedThemeType: ThemeType.custom,
        timeDisplayFormat: timeDisplayFormat,
        itemClickAction: itemClickAction,
        cacheDirectory: cacheDirectory,
        showDescription: true,
        showImages: showImages,
        showTags: true,
        showCopyLink: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  test("hydrate copies display fields from UserConfig", () {
    notifier.hydrate(stubConfig(
      timeDisplayFormat: TimeDisplayFormat.absolute,
      cacheDirectory: "/tmp/cache",
      showImages: false,
    ));
    expect(notifier.current.value.timeDisplayFormat, 1);
    expect(notifier.current.value.cacheDirectory, "/tmp/cache");
    expect(notifier.current.value.showImages, isFalse);
    expect(notifier.isDirty, isFalse);
  });

  test("update flips a single toggle without disturbing others", () {
    notifier.hydrate(stubConfig());
    notifier.update((s) => s.copyWith(showTags: false));
    expect(notifier.current.value.showTags, isFalse);
    expect(notifier.current.value.showImages, isTrue);
    expect(notifier.current.value.showCopyLink, isTrue);
    expect(notifier.isDirty, isTrue);
  });

  test("save invokes service and clears dirty", () async {
    when(service.updateDisplaySection(
      configId: anyNamed("configId"),
      timeDisplayFormat: anyNamed("timeDisplayFormat"),
      itemClickAction: anyNamed("itemClickAction"),
      cacheDirectory: anyNamed("cacheDirectory"),
      showDescription: anyNamed("showDescription"),
      showImages: anyNamed("showImages"),
      showTags: anyNamed("showTags"),
      showCopyLink: anyNamed("showCopyLink"),
    )).thenAnswer((_) => Future<void>.value());

    notifier.hydrate(stubConfig());
    notifier.update((s) => s.copyWith(itemClickAction: 1));
    await notifier.save("cfg");

    verify(service.updateDisplaySection(
      configId: "cfg",
      timeDisplayFormat: 1,
      itemClickAction: 1,
      cacheDirectory: null,
      showDescription: true,
      showImages: true,
      showTags: true,
      showCopyLink: true,
    )).called(1);
    expect(notifier.isDirty, isFalse);
  });

  test("save failure leaves saved snapshot unchanged", () async {
    when(service.updateDisplaySection(
      configId: anyNamed("configId"),
      timeDisplayFormat: anyNamed("timeDisplayFormat"),
      itemClickAction: anyNamed("itemClickAction"),
      cacheDirectory: anyNamed("cacheDirectory"),
      showDescription: anyNamed("showDescription"),
      showImages: anyNamed("showImages"),
      showTags: anyNamed("showTags"),
      showCopyLink: anyNamed("showCopyLink"),
    )).thenThrow(Exception("write failed"));

    notifier.hydrate(stubConfig());
    notifier.update((s) => s.copyWith(showImages: false));

    await expectLater(notifier.save("cfg"), throwsException);
    expect(notifier.isDirty, isTrue);
  });
}
