import "package:chenron/features/settings/state/backup_settings.dart";
import "package:database/database.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";

import "archive_settings_notifier_test.mocks.dart";

void main() {
  late MockConfigService service;
  late BackupSettingsNotifier notifier;

  setUp(() {
    service = MockConfigService();
    notifier = BackupSettingsNotifier(service);
  });

  BackupSetting stubRow({
    String? backupInterval = "0 0 */8 * * *",
    String? backupPath,
  }) =>
      BackupSetting(
        id: "backup-1",
        userConfigId: "cfg",
        backupFilename: null,
        backupPath: backupPath,
        backupInterval: backupInterval,
        lastBackupTimestamp: null,
      );

  test("hydrateBackup copies row fields into both snapshots", () {
    notifier.hydrateBackup(stubRow(backupPath: "/backup/here"));
    expect(notifier.current.value.backupInterval, "0 0 */8 * * *");
    expect(notifier.current.value.backupPath, "/backup/here");
    expect(notifier.isDirty, isFalse);
  });

  test("hydrateBackup with null row resets to defaults", () {
    notifier.hydrateBackup(null);
    expect(notifier.current.value, const BackupPreferences());
    expect(notifier.isDirty, isFalse);
  });

  test("update toggles isDirty", () {
    notifier.hydrateBackup(stubRow());
    notifier.update((s) => s.copyWith(backupInterval: "0 0 0 * * *"));
    expect(notifier.isDirty, isTrue);
  });

  test("save throws when no row hydrated", () async {
    notifier.hydrateBackup(null);
    notifier.update((s) => s.copyWith(backupInterval: "0 0 0 * * *"));
    await expectLater(notifier.save(), throwsStateError);
  });

  test("save passes row id and clearInterval=true when interval is null",
      () async {
    when(service.updateBackupSettings(
      id: anyNamed("id"),
      backupInterval: anyNamed("backupInterval"),
      backupPath: anyNamed("backupPath"),
      clearInterval: anyNamed("clearInterval"),
    )).thenAnswer((_) => Future<void>.value());

    notifier.hydrateBackup(stubRow());
    notifier.update((s) => s.copyWith(backupInterval: null));

    await notifier.save();

    verify(service.updateBackupSettings(
      id: "backup-1",
      backupInterval: null,
      backupPath: null,
      clearInterval: true,
    )).called(1);
    expect(notifier.isDirty, isFalse);
  });

  test("save failure leaves saved untouched", () async {
    when(service.updateBackupSettings(
      id: anyNamed("id"),
      backupInterval: anyNamed("backupInterval"),
      backupPath: anyNamed("backupPath"),
      clearInterval: anyNamed("clearInterval"),
    )).thenThrow(Exception("db locked"));

    notifier.hydrateBackup(stubRow());
    notifier.update((s) => s.copyWith(backupPath: "/new/path"));

    await expectLater(notifier.save(), throwsException);
    expect(notifier.isDirty, isTrue);
  });
}
