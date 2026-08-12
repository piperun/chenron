import "dart:async";

import "package:cache_manager/cache_manager.dart";
import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:signals/signals_flutter.dart";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/cache_service.dart";
import "package:chenron/features/settings/state/storage_settings.dart";
import "package:chenron/features/settings/ui/shared/path_mode_selector.dart";
import "package:chenron/features/settings/ui/shared/settings_section_header.dart";
import "package:chenron/features/settings/ui/shared/stats_action_row.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/dialogs/confirm_dialog.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";

/// Cache location plus the clear actions for both caches: the image
/// cache (files under the cache directory) and the metadata cache (rows
/// in the app database).
class CacheSettingsPanel extends StatefulWidget {
  final CacheService? cacheService;

  const CacheSettingsPanel({super.key, this.cacheService});

  @override
  State<CacheSettingsPanel> createState() => _CacheSettingsPanelState();
}

class _CacheSettingsPanelState extends State<CacheSettingsPanel> {
  late final StorageSettingsNotifier _storageNotifier;
  late final CacheService _cacheService;
  Future<int>? _imageCacheSizeFuture;
  Future<int>? _metadataCountFuture;

  @override
  void initState() {
    super.initState();
    _storageNotifier = locator.get<SettingsCoordinator>().storage;
    _initCacheService();
    _refreshMetadataCount();
  }

  Future<String> _getDefaultCachePath() async {
    final tempDir = await getTemporaryDirectory();
    return "${tempDir.path}/chenron_images";
  }

  Future<String> _getAppDataCachePath() async {
    final appDir = await getApplicationSupportDirectory();
    return "${appDir.path}/cache";
  }

  void _initCacheService() {
    _cacheService = widget.cacheService ??
        CacheService(
          resolveCachePath: () async {
            final customPath = _storageNotifier.current.peek().cacheDirectory;
            return customPath ?? await _getDefaultCachePath();
          },
        );
    _refreshCacheStats();
  }

  void _refreshCacheStats() {
    _imageCacheSizeFuture = _cacheService.getImageCacheSize();
  }

  void _refreshMetadataCount() {
    _metadataCountFuture = locator.get<MetadataCache>().count();
  }

  Future<void> _confirmAndClearImages(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: "Clear Image Cache",
      message: "Remove downloaded images? "
          "They will be re-downloaded on next view.",
      confirmLabel: "Clear",
    );
    if (!confirmed || !context.mounted) return;

    try {
      await _cacheService.clearImageCache();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Image cache cleared"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      if (mounted) setState(_refreshCacheStats);
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _confirmAndClearMetadata(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: "Clear Metadata Cache",
      message: "Clear cached page info? "
          "Titles and descriptions will be refetched.",
      confirmLabel: "Clear",
    );
    if (!confirmed || !context.mounted) return;

    try {
      // Transitional adapter until Task 6 owns coordinated clearing.
      // ignore: deprecated_member_use
      locator.get<FailureTracker>().clearAll();
      await locator.get<MetadataCache>().clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Metadata cache cleared"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      if (mounted) setState(_refreshMetadataCount);
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    }
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SignalBuilder(builder: (context) {
      // Subscribe to the whole storage snapshot so cacheDirectory edits
      // trigger a rebuild of this panel.
      final StorageSettings snapshot = _storageNotifier.current.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SettingsSectionHeader(
            title: "Cache Directory",
            description: "Location where cached images are stored.",
          ),
          PathModeSelector(
            currentPath: snapshot.cacheDirectory,
            options: [
              PathModeOption(
                label: "Default",
                resolveSubtitle: _getDefaultCachePath,
              ),
              PathModeOption(
                label: "App data",
                resolveSubtitle: _getAppDataCachePath,
                resolveValue: _getAppDataCachePath,
              ),
              const PathModeOption(
                label: "Custom",
                isCustom: true,
              ),
            ],
            fieldLabel: "Cache Path",
            onPathChanged: (value) => _storageNotifier
                .update((s) => s.copyWith(cacheDirectory: value)),
            detectInitialMode: (path) async {
              final appDataPath = await _getAppDataCachePath();
              return path == appDataPath ? 1 : 2;
            },
          ),
          const Divider(height: 32),
          Text("Cache Management", style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          StatsActionRow(
            icon: Icons.image_outlined,
            label: "Image Cache",
            future: _imageCacheSizeFuture!,
            formatValue: _formatBytes,
            buttonLabel: "Clear Images",
            onClear: () => unawaited(_confirmAndClearImages(context)),
          ),
          const SizedBox(height: 12),
          // The metadata cache lives in the app database, not the cache
          // directory above. Clearing forces a refetch on next view.
          StatsActionRow(
            icon: Icons.description_outlined,
            label: "Metadata Cache",
            future: _metadataCountFuture!,
            formatValue: (count) =>
                "$count ${count == 1 ? "entry" : "entries"}",
            buttonLabel: "Clear Metadata",
            onClear: () => unawaited(_confirmAndClearMetadata(context)),
          ),
        ],
      );
    });
  }
}
