import "dart:async";
import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/features/settings/service/cache_service.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";
import "package:path_provider/path_provider.dart";

enum CacheDirectoryMode { defaultMode, appData, custom }

class CacheSettings extends StatefulWidget {
  final ConfigController controller;
  final CacheService? cacheService;

  const CacheSettings({super.key, required this.controller, this.cacheService});

  @override
  State<CacheSettings> createState() => _CacheSettingsState();
}

class _CacheSettingsState extends State<CacheSettings> {
  late TextEditingController _pathController;
  CacheDirectoryMode _mode = CacheDirectoryMode.defaultMode;

  @override
  void initState() {
    super.initState();
    final customPath = widget.controller.cacheDirectory.peek();
    if (customPath == null) {
      _mode = CacheDirectoryMode.defaultMode;
    } else {
      // Detect if the stored path matches appData to show the right radio
      _mode = CacheDirectoryMode.custom;
      unawaited(_detectAppDataMode(customPath));
    }
    _pathController = TextEditingController(text: customPath ?? "");
    _initCacheService();
  }

  Future<void> _detectAppDataMode(String currentPath) async {
    final appDataPath = await _getAppDataCachePath();
    if (currentPath == appDataPath && mounted) {
      setState(() => _mode = CacheDirectoryMode.appData);
    }
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  Future<String> _getDefaultCachePath() async {
    final tempDir = await getTemporaryDirectory();
    return "${tempDir.path}/chenron_images";
  }

  Future<String> _getAppDataCachePath() async {
    final appDir = await getApplicationSupportDirectory();
    return "${appDir.path}/cache";
  }

  Future<void> _pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _pathController.text = result;
      });
      widget.controller.updateCacheDirectory(result);
    }
  }

  void _onModeChanged(CacheDirectoryMode? mode) {
    if (mode == null) return;

    setState(() {
      _mode = mode;
    });

    switch (mode) {
      case CacheDirectoryMode.defaultMode:
        widget.controller.updateCacheDirectory(null);
        _pathController.clear();
      case CacheDirectoryMode.appData:
        _pathController.clear();
        unawaited(_applyAppDataPath());
      case CacheDirectoryMode.custom:
        if (_pathController.text.isNotEmpty) {
          widget.controller.updateCacheDirectory(_pathController.text);
        }
    }
  }

  Future<void> _applyAppDataPath() async {
    final path = await _getAppDataCachePath();
    widget.controller.updateCacheDirectory(path);
  }

  void _onPathChanged(String value) {
    if (_mode == CacheDirectoryMode.custom && value.trim().isNotEmpty) {
      widget.controller.updateCacheDirectory(value.trim());
    }
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
      // and update local state if needed (optional, but good for reactivity)
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

          // Radio Group for Mode
          RadioGroup<CacheDirectoryMode>(
            groupValue: _mode,
            onChanged: _onModeChanged,
            child: Column(
              children: [
                // Radio: Default
                RadioListTile<CacheDirectoryMode>(
                  title: const Text("Default"),
                  value: CacheDirectoryMode.defaultMode,
                  contentPadding: EdgeInsets.zero,
                  subtitle: FutureBuilder<String>(
                    future: _getDefaultCachePath(),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? "Loading...",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      );
                    },
                  ),
                ),

                // Radio: App Data
                RadioListTile<CacheDirectoryMode>(
                  title: const Text("App data"),
                  value: CacheDirectoryMode.appData,
                  contentPadding: EdgeInsets.zero,
                  subtitle: FutureBuilder<String>(
                    future: _getAppDataCachePath(),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? "Loading...",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      );
                    },
                  ),
                ),

                // Radio: Custom
                const RadioListTile<CacheDirectoryMode>(
                  title: Text("Custom"),
                  value: CacheDirectoryMode.custom,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Custom path input (shown when custom is selected)
          if (_mode == CacheDirectoryMode.custom)
            Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pathController,
                      decoration: const InputDecoration(
                        labelText: "Cache Path",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: _onPathChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _pickFolder,
                    icon: const Icon(Icons.folder_open),
                    tooltip: "Browse for folder",
                  ),
                ],
              ),
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
