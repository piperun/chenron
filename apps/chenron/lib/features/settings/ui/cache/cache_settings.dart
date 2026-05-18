import "dart:async";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/cache_service.dart";
import "package:chenron/features/settings/state/display_settings.dart";
import "package:chenron/features/settings/ui/shared/path_mode_selector.dart";
import "package:chenron/features/settings/ui/shared/settings_section_header.dart";
import "package:chenron/features/settings/ui/shared/stats_action_row.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/dialogs/confirm_dialog.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";
import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:signals/signals_flutter.dart";

class CacheSettings extends StatefulWidget {
  final CacheService? cacheService;

  const CacheSettings({super.key, this.cacheService});

  @override
  State<CacheSettings> createState() => _CacheSettingsState();
}

class _CacheSettingsState extends State<CacheSettings> {
  late final DisplaySettingsNotifier _displayNotifier;
  late final CacheService _cacheService;
  Future<int>? _imageCacheSizeFuture;

  @override
  void initState() {
    super.initState();
    _displayNotifier = locator.get<SettingsCoordinator>().display;
    _initCacheService();
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
            final customPath = _displayNotifier.current.peek().cacheDirectory;
            return customPath ?? await _getDefaultCachePath();
          },
        );
    _refreshCacheStats();
  }

  void _refreshCacheStats() {
    _imageCacheSizeFuture = _cacheService.getImageCacheSize();
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
      setState(_refreshCacheStats);
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

    return Watch((context) {
      // Subscribe to the whole display snapshot so cacheDirectory edits
      // trigger a rebuild of this panel.
      final DisplaySettings snapshot = _displayNotifier.current.value;

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
            onPathChanged: (value) => _displayNotifier
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
        ],
      );
    });
  }
}
