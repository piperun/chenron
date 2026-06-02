import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/models/settings_category.dart";
import "package:chenron/features/settings/pages/configuration.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:chenron/locator.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";

import "configuration_test.mocks.dart";

/// A coordinator whose save outcome and dirty-state the test controls,
/// without touching the database. [initialize] is a no-op so the page's
/// initState doesn't hit real config sources.
class _SaveControllableCoordinator extends SettingsCoordinator {
  _SaveControllableCoordinator({
    required super.configService,
    required super.dataService,
    required super.themeApplier,
    required super.optionsStore,
  });

  bool saveResult = true;
  int saveCalls = 0;

  @override
  bool get hasUnsavedChanges => true;

  @override
  Future<void> initialize() async {
    isLoading.value = false;
  }

  @override
  Future<bool> saveAll() async {
    saveCalls++;
    isLoading.value = true;
    error.value = saveResult ? null : "disk full";
    // Defer a microtask so the await in _save actually suspends, exposing
    // any missing mounted guard across the async gap.
    await Future<void>.value();
    isLoading.value = false;
    return saveResult;
  }
}

@GenerateMocks([ConfigService, DataSettingsService, ThemeNotifier])
void main() {
  late _SaveControllableCoordinator coordinator;

  setUp(() async {
    if (locator.isRegistered<SettingsCoordinator>()) {
      await locator.reset();
    }
    coordinator = _SaveControllableCoordinator(
      configService: MockConfigService(),
      dataService: MockDataSettingsService(),
      themeApplier: MockThemeNotifier(),
      optionsStore: ThemeOptionsStore(),
    );
    locator.registerSingleton<SettingsCoordinator>(coordinator);
  });

  tearDown(() async {
    if (locator.isRegistered<SettingsCoordinator>()) {
      await locator.reset();
    }
  });

  Widget buildPage() {
    return const MaterialApp(
      home: ConfigPage(selectedCategory: SettingsCategory.display),
    );
  }

  testWidgets("saving while mounted shows the result without delay",
      (tester) async {
    coordinator.saveResult = true;
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Save Settings"));
    // Drive _save to completion using only zero-duration pumps — no clock
    // advance. The result must already be on screen, proving the fix
    // dropped the arbitrary 100ms delay (the old code only revealed the
    // result after that timer elapsed).
    await tester.pump(); // _save runs to its await
    await tester.pump(); // saveAll's microtask resolves
    await tester.pump(); // snackbar inserted

    expect(coordinator.saveCalls, 1);
    expect(find.text("Settings saved"), findsOneWidget);
    // The indefinite "Saving..." snackbar was replaced, not left behind.
    expect(find.text("Saving..."), findsNothing);

    await tester.pumpAndSettle(); // drain the result snackbar timer
  });

  testWidgets("a failed save shows the error result", (tester) async {
    coordinator.saveResult = false;
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Save Settings"));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining("Error saving settings"), findsOneWidget);
    expect(find.text("Saving..."), findsNothing);
  });

  testWidgets("unmounting during save does not throw", (tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Save Settings"));
    // Tear the page down before saveAll's deferred completion resolves.
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    await tester.pumpAndSettle();

    // No exception => the mounted guard held. Sanity-check the page is gone.
    expect(find.text("Save Settings"), findsNothing);
  });
}
