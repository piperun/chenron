import "package:chenron/core/setup/main_setup.dart";
import "package:database/test_support/locator.dart";
import "package:get_it/get_it.dart";
import "package:signals/signals_flutter.dart";
import "package:database/database.dart";

/// Initializes the app for testing purposes
/// This should be called before pumping the ChenronApp widget
Future<void> initTestApp() async {
  try {
    // Check if GetIt already has registrations by checking for a known type
    final alreadySetup = GetIt.I.isRegistered<Signal<AppDatabaseHandler>>();

    if (alreadySetup) {
      // Reset GetIt for fresh state between tests
      await GetIt.I.reset();
      // MainSetup.setup() will detect the reset and re-initialize
    }

    await MainSetup.setup();
    await locator.allReady();
  } catch (error) {
    // Re-throw to let test framework handle it
    rethrow;
  }
}

/// Resets the app state for the next test
/// Call this between tests if needed
Future<void> resetTestApp() async {
  if (GetIt.I.isRegistered<Signal<AppDatabaseHandler>>()) {
    await GetIt.I.reset();
  }
}
