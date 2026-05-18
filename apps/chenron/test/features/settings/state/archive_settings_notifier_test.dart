import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/state/archive_settings.dart";
import "package:database/database.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "archive_settings_notifier_test.mocks.dart";

@GenerateMocks([ConfigService])
void main() {
  late MockConfigService service;
  late ArchiveSettingsNotifier notifier;

  setUp(() {
    service = MockConfigService();
    notifier = ArchiveSettingsNotifier(service);
  });

  UserConfig stubConfig({
    bool defaultArchiveIs = true,
    bool defaultArchiveOrg = false,
    String? archiveOrgS3AccessKey = "ak",
    String? archiveOrgS3SecretKey = "sk",
  }) =>
      UserConfig(
        id: "cfg",
        darkMode: false,
        archiveOrgS3AccessKey: archiveOrgS3AccessKey,
        archiveOrgS3SecretKey: archiveOrgS3SecretKey,
        copyOnImport: false,
        defaultArchiveIs: defaultArchiveIs,
        defaultArchiveOrg: defaultArchiveOrg,
        selectedThemeType: 0,
        timeDisplayFormat: 0,
        itemClickAction: 0,
        showDescription: true,
        showImages: true,
        showTags: true,
        showCopyLink: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  test("hydrate copies UserConfig fields into both current and saved",
      () {
    notifier.hydrate(stubConfig());
    expect(notifier.current.value.defaultArchiveIs, isTrue);
    expect(notifier.current.value.archiveOrgS3AccessKey, "ak");
    expect(notifier.saved.value, equals(notifier.current.value));
    expect(notifier.isDirty, isFalse);
  });

  test("update mutates current and flips isDirty", () {
    notifier.hydrate(stubConfig());
    notifier.update((s) => s.copyWith(defaultArchiveOrg: true));
    expect(notifier.current.value.defaultArchiveOrg, isTrue);
    expect(notifier.saved.value.defaultArchiveOrg, isFalse);
    expect(notifier.isDirty, isTrue);
  });

  test("update back to saved value clears isDirty", () {
    notifier.hydrate(stubConfig(defaultArchiveOrg: false));
    notifier.update((s) => s.copyWith(defaultArchiveOrg: true));
    expect(notifier.isDirty, isTrue);
    notifier.update((s) => s.copyWith(defaultArchiveOrg: false));
    expect(notifier.isDirty, isFalse);
  });

  test("save invokes service then advances saved snapshot", () async {
    when(service.updateArchiveSection(
      configId: anyNamed("configId"),
      defaultArchiveIs: anyNamed("defaultArchiveIs"),
      defaultArchiveOrg: anyNamed("defaultArchiveOrg"),
      archiveOrgS3AccessKey: anyNamed("archiveOrgS3AccessKey"),
      archiveOrgS3SecretKey: anyNamed("archiveOrgS3SecretKey"),
    )).thenAnswer((_) async {});

    notifier.hydrate(stubConfig(defaultArchiveOrg: false));
    notifier.update((s) => s.copyWith(defaultArchiveOrg: true));
    expect(notifier.isDirty, isTrue);

    await notifier.save("cfg");

    verify(service.updateArchiveSection(
      configId: "cfg",
      defaultArchiveIs: true,
      defaultArchiveOrg: true,
      archiveOrgS3AccessKey: "ak",
      archiveOrgS3SecretKey: "sk",
    )).called(1);
    expect(notifier.saved.value, equals(notifier.current.value));
    expect(notifier.isDirty, isFalse);
  });

  test("save trims whitespace on secret keys before persisting", () async {
    when(service.updateArchiveSection(
      configId: anyNamed("configId"),
      defaultArchiveIs: anyNamed("defaultArchiveIs"),
      defaultArchiveOrg: anyNamed("defaultArchiveOrg"),
      archiveOrgS3AccessKey: anyNamed("archiveOrgS3AccessKey"),
      archiveOrgS3SecretKey: anyNamed("archiveOrgS3SecretKey"),
    )).thenAnswer((_) async {});

    notifier.hydrate(stubConfig());
    notifier.update(
      (s) => s.copyWith(
        archiveOrgS3AccessKey: "  fresh-key  ",
        archiveOrgS3SecretKey: "\nsecret\n",
      ),
    );

    await notifier.save("cfg");

    verify(service.updateArchiveSection(
      configId: "cfg",
      defaultArchiveIs: anyNamed("defaultArchiveIs"),
      defaultArchiveOrg: anyNamed("defaultArchiveOrg"),
      archiveOrgS3AccessKey: "fresh-key",
      archiveOrgS3SecretKey: "secret",
    )).called(1);
  });

  test("save failure leaves saved snapshot unchanged", () async {
    when(service.updateArchiveSection(
      configId: anyNamed("configId"),
      defaultArchiveIs: anyNamed("defaultArchiveIs"),
      defaultArchiveOrg: anyNamed("defaultArchiveOrg"),
      archiveOrgS3AccessKey: anyNamed("archiveOrgS3AccessKey"),
      archiveOrgS3SecretKey: anyNamed("archiveOrgS3SecretKey"),
    )).thenThrow(Exception("network down"));

    notifier.hydrate(stubConfig(defaultArchiveOrg: false));
    notifier.update((s) => s.copyWith(defaultArchiveOrg: true));

    await expectLater(notifier.save("cfg"), throwsException);
    expect(notifier.isDirty, isTrue,
        reason: "saved should not advance when persistence fails");
  });
}
