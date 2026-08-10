import "dart:async";

import "package:app_logger/app_logger.dart";
import "package:basedir/directory.dart";
import "package:cache_manager/cache_manager.dart";
import "package:database/database.dart" hide Metadata;
import "package:database/features.dart";
import "package:get_it/get_it.dart";
import "package:signals/signals_flutter.dart";

import "package:chenron/base_dirs/schema.dart";
import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/theme/state/theme_manager.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:chenron/providers/appdatabase_provider.dart";
import "package:chenron/providers/basedir.dart";
import "package:chenron/providers/configdatabase.dart";
import "package:chenron/providers/theme_notifier_signal.dart";
import "package:chenron/services/metadata/metadata_fetch_client.dart";
import "package:chenron/services/activity_tracker.dart";

/// Process-wide service locator. [locatorSetup] runs once at startup;
/// everywhere else, services resolve via `locator.get<T>()`.
final locator = GetIt.I;

void locatorSetup() {
  // --- Database lifecycles ---
  // Signal-wrapped so reactive subscribers rebuild when the active
  // connection is swapped (import / restore / location change).
  locator.registerSingleton<Signal<AppDatabaseLifecycle>>(
      appDatabaseAccessorSignal);
  locator.registerSingleton<Signal<ConfigDatabaseLifecycle>>(
      signal(initializeConfigDatabaseLifecycle()));

  // --- Base directories ---
  // Async resolution (path_provider) wrapped in a signal for future
  // location changes. The factory adapter exposes the inner Future
  // because the database package consumes it directly — it can't
  // depend on the signals package to unwrap the Signal itself.
  locator.registerSingleton<Signal<Future<BaseDirectories<ChenronDir>?>>>(
      baseDirsSignal);
  locator.registerFactory<Future<BaseDirectories<ChenronDir>?>>(
      () => baseDirsSignal.value);

  // --- Metadata pipeline ---
  // Cache + failure tracker are registered first so MetadataService
  // can resolve them synchronously in its constructor. Persistence is
  // attached later, after the app database opens — see
  // MainSetup._setupConfig.
  locator.registerSingleton<MetadataCache>(MetadataCache());
  locator.registerSingleton<FailureTracker>(FailureTracker());
  locator.registerSingleton<DomainCircuitBreaker>(DomainCircuitBreaker());
  locator.registerSingleton<MetadataFetchClient>(
    MetadataFetchClient(),
    dispose: (client) => client.close(),
  );
  locator.registerSingleton<MetadataService>(
    MetadataService(
      cache: locator.get<MetadataCache>(),
      failures: locator.get<FailureTracker>(),
      domainCircuitBreaker: locator.get<DomainCircuitBreaker>(),
      fetcher: locator.get<MetadataFetchClient>().fetch,
      onFetchLogged: _onFetchLogged,
    ),
    dispose: (service) => service.dispose(),
  );

  // One process-wide on-disk image cache, lazily built on first use.
  locator.registerLazySingleton<ImageCacheManager>(ImageCacheManager.new);

  // --- Theming ---
  locator.registerLazySingleton<ThemeManager>(() => ThemeManager(
        locator<Signal<ConfigDatabaseLifecycle>>().value.configDatabase,
      ));
  locator.registerLazySingleton<ThemeOptionsStore>(ThemeOptionsStore.new);

  // --- Settings ---
  // SettingsCoordinator composes the per-section notifiers; settings
  // UIs read from / write to them directly.
  locator.registerLazySingleton<ConfigService>(ConfigService.new);
  locator.registerLazySingleton<DataSettingsService>(DataSettingsService.new);
  locator.registerLazySingleton<SettingsCoordinator>(() => SettingsCoordinator(
        configService: locator.get<ConfigService>(),
        dataService: locator.get<DataSettingsService>(),
        themeApplier: themeNotifierSignal.value,
        optionsStore: locator.get<ThemeOptionsStore>(),
        // Persisting a new cache directory redirects the image cache so the
        // change takes effect without a restart.
        onCacheDirectorySaved: (dir) =>
            locator.get<ImageCacheManager>().initialize(customPath: dir),
      ));

  // --- File services ---
  locator.registerLazySingleton<AppFileService>(() => AppFileService(
        lifecycle: locator.get<Signal<AppDatabaseLifecycle>>().value,
      ));
  locator.registerLazySingleton<DatabaseBackupScheduler>(
      () => DatabaseBackupScheduler(
            fileService: locator.get<AppFileService>(),
            configLifecycle:
                locator.get<Signal<ConfigDatabaseLifecycle>>().value,
          ));

  // --- Activity tracking ---
  locator.registerLazySingleton<ActivityTracker>(() => ActivityTracker(
        locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase,
      ));
}

// ---------------------------------------------------------------------------
// Metadata-pipeline adapters
//
// Bridge chenron-specific concerns (HTTP scraper, drift activity log) to the
// package-neutral callback interfaces MetadataService expects. Keeping the
// adapters here lets cache_manager stay free of chenron imports.
// ---------------------------------------------------------------------------

const _metadataLogTag = "MetadataService";

/// Forwards a structured terminal result to the existing activity log.
void _onFetchLogged(String url, MetadataRefreshResult result) {
  if (result.outcome == MetadataRefreshOutcome.skipped) return;
  final succeeded = result.outcome == MetadataRefreshOutcome.updated ||
      result.outcome == MetadataRefreshOutcome.unchanged;
  final failure = switch (result.state) {
    MetadataStateAvailable(:final lastFailure) => lastFailure,
    MetadataStateUnavailable(:final lastFailure) => lastFailure,
  };
  unawaited(_logMetadataFetch(
    url: url,
    succeeded: succeeded,
    error: succeeded ? null : _formatMetadataFailure(failure),
  ));
}

String _formatMetadataFailure(MetadataRefreshFailure? failure) {
  if (failure == null) return "metadata refresh failed";
  final status = failure.statusCode;
  final category = failure.kind.name;
  return status == null
      ? "$category: ${failure.reason}"
      : "$category (HTTP $status): ${failure.reason}";
}

/// Best-effort write of a metadata-fetch entry into the BackgroundJobs
/// table. Errors are swallowed because a missing locator (in unit
/// tests) or a DB hiccup must never break a fetch — rows age out via
/// the activity-log TTL.
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
    loggerGlobal.fine(
      _metadataLogTag,
      "Failed to log metadata fetch for $url: $e",
    );
  }
}
