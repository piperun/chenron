import "dart:async";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/features/settings/service/cache_service.dart";
import "package:chenron/features/settings/ui/shared/path_mode_selector.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";
import "package:path_provider/path_provider.dart";

class CacheSettings extends StatefulWidget {
  final ConfigController controller;
  final CacheService? cacheService;

  const CacheSettings({super.key, required this.controller, this.cacheService});

  @override
  State<CacheSettings> createState() => _CacheSettingsState();
}

class _CacheSettingsState extends State<CacheSettings> {
  @override
  void initState() {
    super.initState();
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

  late final CacheService _cacheService;
  Future<int>? _imageCacheSizeFuture;
  Future<int>? _metadataCountFuture;

  void _initCacheService() {
    _cacheService = widget.cacheService ??
        CacheService(
          resolveCachePath: () async {
            final customPath = widget.controller.cacheDirectory.peek();
            return customPath ?? await _getDefaultCachePath();
          },
        );
    _refreshCacheStats();
  }

  void _refreshCacheStats() {
    _imageCacheSizeFuture = _cacheService.getImageCacheSize();
    _metadataCountFuture = _cacheService.getMetadataCacheEntryCount();
  }

  Future<void> _handleClearImages(BuildContext context) async {
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

  Future<void> _handleClearMetadata(BuildContext context) async {
    try {
      await _cacheService.clearMetadataCache();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Metadata cache cleared"),
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
      // Subscribe to cacheDirectory changes to trigger rebuilds
      // ignore: unused_local_variable
      final _ = widget.controller.cacheDirectory.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cache Directory Section
          Text(
            "Cache Directory",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Location where cached images are stored.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),

          PathModeSelector(
            currentPath: widget.controller.cacheDirectory.peek(),
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
            onPathChanged: widget.controller.updateCacheDirectory,
            detectInitialMode: (path) async {
              final appDataPath = await _getAppDataCachePath();
              return path == appDataPath ? 1 : 2;
            },
          ),

          const Divider(height: 32),

          // Cache Management Section
          Text(
            "Cache Management",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          // Image Cache Row
          _CacheRow(
            icon: Icons.image_outlined,
            label: "Image Cache",
            future: _imageCacheSizeFuture!,
            formatValue: _formatBytes,
            buttonLabel: "Clear Images",
            onClear: () {
              unawaited(showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Clear Image Cache"),
                  content: const Text(
                    "Remove downloaded images? "
                    "They will be re-downloaded on next view.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        unawaited(_handleClearImages(context));
                      },
                      child: const Text("Clear"),
                    ),
                  ],
                ),
              ));
            },
          ),

          const SizedBox(height: 12),

          // Metadata Cache Row
          _CacheRow(
            icon: Icons.description_outlined,
            label: "Metadata Cache",
            future: _metadataCountFuture!,
            formatValue: (count) =>
                "$count ${count == 1 ? "entry" : "entries"}",
            buttonLabel: "Clear Metadata",
            onClear: () {
              unawaited(showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Clear Metadata Cache"),
                  content: const Text(
                    "Clear cached page info? "
                    "Titles and descriptions will be refetched.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        unawaited(_handleClearMetadata(context));
                      },
                      child: const Text("Clear"),
                    ),
                  ],
                ),
              ));
            },
          ),
        ],
      );
    });
  }
}

class _CacheRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Future<int> future;
  final String Function(int value) formatValue;
  final String buttonLabel;
  final VoidCallback onClear;

  const _CacheRow({
    required this.icon,
    required this.label,
    required this.future,
    required this.formatValue,
    required this.buttonLabel,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color
                    ?.withValues(alpha: 0.7),
              ),
            ),
            FutureBuilder<int>(
              future: future,
              builder: (context, snapshot) {
                final value = snapshot.data;
                return Text(
                  value != null ? formatValue(value) : "...",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ],
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: onClear,
          icon: const Icon(Icons.delete_outline, size: 18),
          label: Text(buttonLabel),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }
}
