import "package:chenron/features/settings/state/storage_settings.dart";
import "package:database/database.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";

import "archive_settings_notifier_test.mocks.dart";

void main() {
  late MockConfigService service;
  late StorageSettingsNotifier notifier;

  setUp(() {
    service = MockConfigService();
    notifier = StorageSettingsNotifier(service);

    when(service.updateStorageSection(
      configId: anyNamed("configId"),
      cacheDirectory: anyNamed("cacheDirectory"),
    )).thenAnswer((_) => Future<void>.value());
  });

  UserConfig stubConfig({String? cacheDirectory}) => UserConfig(
        id: "cfg",
        darkMode: false,
        archiveOrgS3AccessKey: null,
        archiveOrgS3SecretKey: null,
        copyOnImport: false,
        defaultArchiveIs: false,
        defaultArchiveOrg: false,
        selectedThemeType: ThemeType.custom,
        timeDisplayFormat: TimeDisplayFormat.absolute,
        itemClickAction: ItemClickAction.openItem,
        cacheDirectory: cacheDirectory,
        showDescription: true,
        showImages: true,
        showTags: true,
        showCopyLink: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  test("hydrate copies the cache directory from UserConfig", () {
    notifier.hydrate(stubConfig(cacheDirectory: "/tmp/cache"));
    expect(notifier.current.value.cacheDirectory, "/tmp/cache");
    expect(notifier.isDirty, isFalse);
  });

  test("save persists a custom directory and clears dirty", () async {
    notifier.hydrate(stubConfig());
    notifier.update((s) => s.copyWith(cacheDirectory: "/custom/cache"));
    expect(notifier.isDirty, isTrue);

    await notifier.save("cfg");

    verify(service.updateStorageSection(
      configId: "cfg",
      cacheDirectory: "/custom/cache",
    )).called(1);
    expect(notifier.isDirty, isFalse);
  });

  // The user-config update API skips null-valued columns and clears on
  // "", so a reset to the default directory must be sent as "" — null
  // would leave the old custom path in the database, and the "Default"
  // choice would resurrect as "Custom" on the next hydrate.
  test("save sends the empty-string clear sentinel for a reset directory",
      () async {
    notifier.hydrate(stubConfig(cacheDirectory: "/old/custom"));
    notifier.update((s) => s.copyWith(cacheDirectory: null));

    await notifier.save("cfg");

    verify(service.updateStorageSection(
      configId: "cfg",
      cacheDirectory: "",
    )).called(1);
  });

  test("save redirects the image cache to the saved directory", () async {
    // Regression: persisting a custom cacheDirectory must apply it to the
    // image cache. Before this wiring the setting was stored but never
    // reached ImageCacheManager, so images kept caching to the default dir.
    String? appliedDir = "unset";
    final withCallback = StorageSettingsNotifier(
      service,
      onCacheDirectorySaved: (String? dir) async => appliedDir = dir,
    );
    withCallback.hydrate(stubConfig());
    withCallback.update((s) => s.copyWith(cacheDirectory: "/custom/cache"));
    await withCallback.save("cfg");

    expect(appliedDir, "/custom/cache");
  });

  test("save passes null to the image cache callback on reset", () async {
    // The callback gets the user-facing value (null = platform default),
    // not the "" wire sentinel — ImageCacheManager.initialize(customPath:
    // null) is what falls back to the default directory.
    String? appliedDir = "unset";
    final withCallback = StorageSettingsNotifier(
      service,
      onCacheDirectorySaved: (String? dir) async => appliedDir = dir,
    );
    withCallback.hydrate(stubConfig(cacheDirectory: "/old/custom"));
    withCallback.update((s) => s.copyWith(cacheDirectory: null));
    await withCallback.save("cfg");

    expect(appliedDir, isNull);
  });

  test("save failure leaves saved snapshot unchanged", () async {
    when(service.updateStorageSection(
      configId: anyNamed("configId"),
      cacheDirectory: anyNamed("cacheDirectory"),
    )).thenThrow(Exception("write failed"));

    notifier.hydrate(stubConfig());
    notifier.update((s) => s.copyWith(cacheDirectory: "/x"));

    await expectLater(notifier.save("cfg"), throwsException);
    expect(notifier.isDirty, isTrue);
  });
}
