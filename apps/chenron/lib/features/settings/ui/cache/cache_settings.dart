import "dart:async";
import "dart:io";
import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:path_provider/path_provider.dart";

enum CacheDirectoryMode { defaultMode, custom }

class CacheSettings extends StatefulWidget {
  final ConfigController controller;

  const CacheSettings({super.key, required this.controller});

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
    _mode = customPath == null
        ? CacheDirectoryMode.defaultMode
        : CacheDirectoryMode.custom;
    _pathController = TextEditingController(text: customPath ?? "");
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

    if (mode == CacheDirectoryMode.defaultMode) {
      widget.controller.updateCacheDirectory(null);
      _pathController.clear();
    } else {
      // When switching to custom, if path is empty, keep it empty
      // User can type or pick
      if (_pathController.text.isNotEmpty) {
        widget.controller.updateCacheDirectory(_pathController.text);
      }
    }
  }

  void _onPathChanged(String value) {
    if (_mode == CacheDirectoryMode.custom && value.trim().isNotEmpty) {
      widget.controller.updateCacheDirectory(value.trim());
    }
  }

  Future<int> _getCacheSize() async {
    try {
      final customPath = widget.controller.cacheDirectory.peek();
      final cacheDir = Directory(
        customPath ?? await _getDefaultCachePath(),
      );

      if (!cacheDir.existsSync()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity
          in cacheDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            final stat = entity.statSync();
            totalSize += stat.size;
          } catch (_) {
            continue;
          }
        }
      }

      return totalSize;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _clearCache(BuildContext context) async {
    try {
      final customPath = widget.controller.cacheDirectory.peek();
      final cacheDir = Directory(
        customPath ?? await _getDefaultCachePath(),
      );

      if (cacheDir.existsSync()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cache cleared successfully"),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error clearing cache: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
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

          // Responsive Wrap for Cache Size and Clear Button
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            children: [
              // Cache Size Display
              FutureBuilder<int>(
                future: _getCacheSize(),
                builder: (context, snapshot) {
                  final size = snapshot.data ?? 0;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storage_outlined,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Cache Size",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            _formatBytes(size),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              // Clear Cache Button
              OutlinedButton.icon(
                onPressed: () {
                  unawaited(showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Clear Cache"),
                      content: const Text(
                        "Are you sure you want to clear all cached images? "
                        "This will free up space but images will need to be downloaded again.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            unawaited(_clearCache(context));
                          },
                          child: const Text("Clear"),
                        ),
                      ],
                    ),
                  ));
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text("Clear Cache"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
