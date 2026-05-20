import "dart:async";

import "package:app_logger/app_logger.dart";
import "package:cache_manager/cache_manager.dart";
import "package:chenron/providers/appdatabase_provider.dart";
import "package:chenron/providers/basedir.dart";
import "package:chenron/providers/configdatabase.dart";
import "package:chenron/utils/metadata.dart";
import "package:basedir/directory.dart";
import "package:database/database.dart" hide Metadata;
import "package:database/features.dart";
import "package:get_it/get_it.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/theme/state/theme_manager.dart";
import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/providers/theme_notifier_signal.dart";
import "package:chenron/base_dirs/schema.dart";
import "package:chenron/services/activity_tracker.dart";

final locator = GetIt.I;

void locatorSetup() {
  // Persistence is attached later, once the AppDatabase is open — see
  // MainSetup._setupConfig. Registering an empty instance up-front lets
  // callers grab the singleton without an init-ordering dance.
  locator.registerSingleton<MetadataCache>(MetadataCache());

  // Failure tracker is standalone — no init dependencies. Lives for
  // the app lifetime; the MetadataService and any direct consumers
  // (e.g. forced refresh in settings) share this one instance.
  locator.registerSingleton<FailureTracker>(FailureTracker());

  // Orchestrator owns the per-URL Signal<MetadataState> map, the
  // concurrency pool, and per-domain throttling. Wired against the
  // locator-registered cache + failure tracker, with chenron's HTTP
  // scraper as the fetcher and the activity-log writer as the hook.
  locator.registerSingleton<MetadataService>(
    MetadataService(
      cache: locator.get<MetadataCache>(),
      failures: locator.get<FailureTracker>(),
      fetcher: _fetcherAdapter,
      onFetchLogged: _onFetchLogged,
    ),
  );

  locator
      .registerSingleton<Signal<AppDatabaseLifecycle>>(appDatabaseAccessorSignal);
  locator.registerSingleton<Signal<ConfigDatabaseLifecycle>>(
      signal(initializeConfigDatabaseLifecycle()));

  locator.registerSingleton<Signal<Future<BaseDirectories<ChenronDir>?>>>(
      baseDirsSignal);

  locator.registerLazySingleton<ThemeManager>(() {
    final configHandlerSignal = locator<Signal<ConfigDatabaseLifecycle>>();
    final ConfigDatabaseLifecycle configHandler = configHandlerSignal.value;
    final ConfigDatabase configDb = configHandler.configDatabase;
    return ThemeManager(configDb);
  });

  // Register ConfigService
  locator.registerLazySingleton<ConfigService>(ConfigService.new);

  // Register DataSettingsService
  locator.registerLazySingleton<DataSettingsService>(DataSettingsService.new);

  // Register SettingsCoordinator (composes the five per-section notifiers).
  // Settings UIs read from / write to its section notifiers directly.
  locator.registerLazySingleton<SettingsCoordinator>(() => SettingsCoordinator(
        configService: locator.get<ConfigService>(),
        dataService: locator.get<DataSettingsService>(),
        themeApplier: themeNotifierSignal.value,
      ));

  // Register AppFileService (depends on the app database lifecycle)
  locator.registerLazySingleton<AppFileService>(() {
    final lifecycle = locator.get<Signal<AppDatabaseLifecycle>>().value;
    return AppFileService(lifecycle: lifecycle);
  });

  // Register DatabaseBackupScheduler
  locator.registerLazySingleton<DatabaseBackupScheduler>(() {
    final fileService = locator.get<AppFileService>();
    final configLifecycle =
        locator.get<Signal<ConfigDatabaseLifecycle>>().value;
    return DatabaseBackupScheduler(
      fileService: fileService,
      configLifecycle: configLifecycle,
    );
  });

  // Register ActivityTracker
  locator.registerLazySingleton<ActivityTracker>(() {
    final db = locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase;
    return ActivityTracker(db);
  });
}

// ---------------------------------------------------------------------------
// Adapters wiring chenron's HTTP scraper + activity log to MetadataService.
// ---------------------------------------------------------------------------

const _metadataLogTag = "MetadataService";

/// Bridges chenron's [MetadataFetcher.fetch] scraper to the
/// [RawFetchedMetadata] DTO that the cache_manager package expects.
Future<RawFetchedMetadata> _fetcherAdapter(String url) async {
  final f = await MetadataFetcher.fetch(url);
  return RawFetchedMetadata(
    title: f.title,
    description: f.description,
    imageUrl: f.image,
    resolvedUrl: f.url,
  );
}

/// Activity-log hook passed to [MetadataService]. Forwards every fetch
/// outcome to the BackgroundJobs table for the activity feed.
void _onFetchLogged(String url, bool succeeded, {String? error}) {
  unawaited(_logMetadataFetch(url: url, succeeded: succeeded, error: error));
}

/// Best-effort write of a metadata-fetch entry into the BackgroundJobs
/// table for the activity log. Catches and swallows all errors — a
/// missing locator (in unit tests) or DB hiccup must never break a
/// fetch. Rows age out via the activity-log TTL.
Future<void> _logMetadataFetch({
  required String url,
  required bool succeeded,
  String? error,
}) async {
  try {
    final db = locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase;
    await db.recordMetadataFetch(
      url: url,
      succeeded: succeeded,
      error: error,
    );
  } catch (e) {
    loggerGlobal.fine(_metadataLogTag,
        "Failed to log metadata fetch for $url: $e");
  }
}
