import "package:chenron/core/setup/main_setup.dart";
import "package:chenron/locator.dart";
import "package:chenron/utils/logger.dart";
import "package:get_it/get_it.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";

/// Initializes the app for testing purposes
/// This should be called before pumping the MyApp widget
Future<void> initTestApp() async {
  try {
    // Check if GetIt already has registrations by checking for a known type
    final alreadySetup =
        GetIt.I.isRegistered<Signal<Future<AppDatabaseHandler>>>();

    if (alreadySetup) {
      // Reset GetIt for fresh state between tests
      await GetIt.I.reset();
      loggerGlobal.info("TestApp", "Reset GetIt for new test");
      // MainSetup.setup() will detect the reset and re-initialize
    }

    await MainSetup.setup();
    loggerGlobal.info("TestApp", "Waiting for locator dependencies...");
    await locator.allReady();
    loggerGlobal.info("TestApp", "Locator ready.");
  } catch (error, stackTrace) {
    loggerGlobal.severe(
        "TestApp", "Failed to initialize app: $error", error, stackTrace);
    rethrow;
  }
}

/// Resets the app state for the next test
/// Call this between tests if needed
Future<void> resetTestApp() async {
  if (GetIt.I.isRegistered<Signal<Future<AppDatabaseHandler>>>()) {
    await GetIt.I.reset();
    loggerGlobal.info("TestApp", "App state reset for next test");
  }
}
