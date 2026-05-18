import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/settings/state/database_settings.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "database_settings_notifier_test.mocks.dart";

@GenerateMocks([DataSettingsService])
void main() {
  late MockDataSettingsService service;
  late DatabaseSettingsNotifier notifier;

  setUp(() {
    service = MockDataSettingsService();
    notifier = DatabaseSettingsNotifier(service);
  });

  test("load pulls custom path from SharedPreferences-backed service",
      () async {
    when(service.getCustomDatabasePath())
        .thenAnswer((_) async => "/custom/db.sqlite");

    await notifier.load();

    expect(notifier.current.value, "/custom/db.sqlite");
    expect(notifier.saved.value, "/custom/db.sqlite");
    expect(notifier.isDirty, isFalse);
  });

  test("update flips isDirty until save advances saved", () async {
    when(service.getCustomDatabasePath()).thenAnswer((_) async => null);
    when(service.setCustomDatabasePath(any))
        .thenAnswer((_) => Future<void>.value());

    await notifier.load();
    expect(notifier.isDirty, isFalse);

    notifier.update("/elsewhere/app.sqlite");
    expect(notifier.isDirty, isTrue);

    await notifier.save();
    verify(service.setCustomDatabasePath("/elsewhere/app.sqlite")).called(1);
    expect(notifier.isDirty, isFalse);
  });

  test("update back to saved value clears isDirty without saving",
      () async {
    when(service.getCustomDatabasePath())
        .thenAnswer((_) async => "/persisted/db.sqlite");

    await notifier.load();
    notifier.update("/different/db.sqlite");
    expect(notifier.isDirty, isTrue);
    notifier.update("/persisted/db.sqlite");
    expect(notifier.isDirty, isFalse);
    verifyNever(service.setCustomDatabasePath(any));
  });

  test("save failure leaves saved unchanged", () async {
    when(service.getCustomDatabasePath()).thenAnswer((_) async => null);
    when(service.setCustomDatabasePath(any))
        .thenThrow(Exception("prefs locked"));

    await notifier.load();
    notifier.update("/new/path.sqlite");

    await expectLater(notifier.save(), throwsException);
    expect(notifier.saved.value, isNull);
    expect(notifier.isDirty, isTrue);
  });
}
