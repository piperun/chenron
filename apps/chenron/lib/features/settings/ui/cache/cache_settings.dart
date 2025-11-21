import "dart:async";
import "dart:io";
import "package:flutter/material.dart";
import "package:platform_provider/platform_provider.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:path_provider/path_provider.dart";

class CacheSettings extends StatelessWidget {
  final ConfigController controller;

  const CacheSettings({super.key, required this.controller});

  Future<void> _pickCacheDirectory(BuildContext context) async {
    // Get current value to pre-populate
    final currentPath =
        controller.cacheDirectory.peek() ?? await _getDefaultCachePath();

    // Check if widget is still mounted after async gap
    if (!context.mounted) return;

    final textController = TextEditingController(text: currentPath);

    // Get platform-specific hint
    String getHintText() {
      return OperatingSystem.current.resources.cacheDirectoryHint;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Cache Directory"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter the full path where you want to store cached images:",
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: "Directory Path",
                hintText: getHintText(),
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              minLines: 1,
            ),
            const SizedBox(height: 8),
            Text(
              "The directory will be created if it doesn't exist.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final path = textController.text.trim();
              if (path.isNotEmpty) {
                Navigator.pop(context, path);
              }
            },
            child: const Text("Set"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      controller.updateCacheDirectory(result);
    }
  }

  Future<void> _useDefaultDirectory() async {
    // Clear custom path to use default temp directory
    controller.updateCacheDirectory(null);
  }

  Future<String> _getDefaultCachePath() async {
    final tempDir = await getTemporaryDirectory();
    return "${tempDir.path}/chenron_images";
  }

  Future<int> _getCacheSize() async {
    try {
      final customPath = controller.cacheDirectory.peek();
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
      final customPath = controller.cacheDirectory.peek();
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cache Settings",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Cache Directory Section
            Text(
              "Cache Directory",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Location where cached images are stored. Default uses system temp directory.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),

            // Current Path Display
            Watch(
              (context) {
                final customPath = controller.cacheDirectory.value;
                return FutureBuilder<String>(
                  future: customPath == null
                      ? _getDefaultCachePath()
                      : Future.value(customPath),
                  builder: (context, snapshot) {
                    final displayPath = snapshot.data ?? "Loading...";
                    final isDefault = customPath == null;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayPath,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                if (isDefault)
                                  Text(
                                    "Default",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickCacheDirectory(context),
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text("Choose Custom Path"),
                ),
                const SizedBox(width: 12),
                Watch(
                  (context) => TextButton.icon(
                    onPressed: controller.cacheDirectory.value == null
                        ? null
                        : _useDefaultDirectory,
                    icon: const Icon(Icons.restart_alt, size: 18),
                    label: const Text("Reset to Default"),
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // Cache Management Section
            Text(
              "Cache Management",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Cache Size Display
            FutureBuilder<int>(
              future: _getCacheSize(),
              builder: (context, snapshot) {
                final size = snapshot.data ?? 0;
                return ListTile(
                  leading: Icon(
                    Icons.storage_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text("Cache Size"),
                  subtitle: Text(_formatBytes(size)),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
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
                icon: const Icon(Icons.delete_outline),
                label: const Text("Clear Cache"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
