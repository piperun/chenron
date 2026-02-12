import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:file_picker/file_picker.dart";
import "package:signals/signals_flutter.dart";

import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/features/settings/service/bookmark_export_service.dart";
import "package:chenron/features/settings/service/bookmark_import_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";

enum _DatabasePathMode { defaultMode, custom }

class DataSettings extends StatefulWidget {
  final ConfigController controller;

  const DataSettings({super.key, required this.controller});

  @override
  State<DataSettings> createState() => _DataSettingsState();
}

class _DataSettingsState extends State<DataSettings> {
  final DataSettingsService _dataService = locator.get<DataSettingsService>();
  late TextEditingController _pathController;
  _DatabasePathMode _mode = _DatabasePathMode.defaultMode;

  @override
  void initState() {
    super.initState();
    final customPath = widget.controller.appDatabasePath.peek();
    _mode = customPath == null
        ? _DatabasePathMode.defaultMode
        : _DatabasePathMode.custom;
    _pathController = TextEditingController(text: customPath ?? "");
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _handlePickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _pathController.text = result;
      });
      widget.controller.updateAppDatabasePath(result);
    }
  }

  void _onModeChanged(_DatabasePathMode? mode) {
    if (mode == null) return;

    setState(() {
      _mode = mode;
    });

    if (mode == _DatabasePathMode.defaultMode) {
      widget.controller.updateAppDatabasePath(null);
      _pathController.clear();
    } else {
      if (_pathController.text.isNotEmpty) {
        widget.controller.updateAppDatabasePath(_pathController.text);
      }
    }
  }

  void _onPathChanged(String value) {
    if (_mode == _DatabasePathMode.custom && value.trim().isNotEmpty) {
      widget.controller.updateAppDatabasePath(value.trim());
    }
  }

  Future<void> _handleExport() async {
    final messenger = ScaffoldMessenger.of(context);

    final destination = await FilePicker.platform.getDirectoryPath();
    if (destination == null) return;

    try {
      final result = await _dataService.exportDatabase(Directory(destination));
      if (result != null) {
        messenger.showSnackBar(SnackBar(
          content: Text("Database exported to ${result.path}"),
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e);
    }
  }

  Future<void> _handleImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Import Database"),
        content: const Text(
          "This will replace your current data with the imported database. "
          "The app will need to restart after importing. Continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Import"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["sqlite"],
    );
    if (picked == null || picked.files.isEmpty) return;

    final filePath = picked.files.single.path;
    if (filePath == null) return;

    try {
      await _dataService.importDatabase(File(filePath));
      if (mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const _RestartDialog(
            title: "Import Successful",
            message: "The database has been imported. "
                "Please restart the app for changes to take effect.",
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e);
    }
  }

  Future<void> _handleExportBookmarks() async {
    final messenger = ScaffoldMessenger.of(context);

    final destination = await FilePicker.platform.saveFile(
      fileName: "bookmarks.html",
      type: FileType.custom,
      allowedExtensions: ["html"],
    );
    if (destination == null) return;

    try {
      final file =
          await BookmarkExportService().exportBookmarks(File(destination));
      messenger.showSnackBar(SnackBar(
        content: Text("Bookmarks exported to ${file.path}"),
        duration: const Duration(seconds: 3),
      ));
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e);
    }
  }

  Future<void> _handleImportBookmarks() async {
    final messenger = ScaffoldMessenger.of(context);

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["html", "htm"],
    );
    if (picked == null || picked.files.isEmpty) return;

    final filePath = picked.files.single.path;
    if (filePath == null) return;

    try {
      final result =
          await BookmarkImportService().importBookmarks(File(filePath));
      messenger.showSnackBar(SnackBar(
        content: Text(
          "Imported ${result.linksImported} links, "
          "${result.foldersCreated} folders. "
          "${result.linksSkipped} duplicates skipped.",
        ),
        duration: const Duration(seconds: 5),
      ));
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e);
    }
  }

  Future<void> _handleApplyRestart() async {
    final navigator = Navigator.of(context);

    // Save the path to SharedPreferences immediately
    final newPath = widget.controller.appDatabasePath.peek();
    await _dataService.setCustomDatabasePath(newPath);

    if (!mounted) return;

    await showDialog<void>(
      context: navigator.context,
      barrierDismissible: false,
      builder: (context) => const _RestartDialog(
        title: "Restart Required",
        message: "The database location has been updated. "
            "The app needs to restart for this change to take effect.",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch((context) {
      // Subscribe to signal changes
      final currentPath = widget.controller.appDatabasePath.value;
      final hasPathChanged =
          currentPath != widget.controller.savedAppDatabasePath;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Database Location ---
          Text("Database Location", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            "Where the application database is stored.",
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),

          RadioGroup<_DatabasePathMode>(
            groupValue: _mode,
            onChanged: _onModeChanged,
            child: Column(
              children: [
                RadioListTile<_DatabasePathMode>(
                  title: const Text("Default"),
                  value: _DatabasePathMode.defaultMode,
                  contentPadding: EdgeInsets.zero,
                  subtitle: FutureBuilder<String>(
                    future: _dataService.getDefaultDatabasePath(),
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
                const RadioListTile<_DatabasePathMode>(
                  title: Text("Custom"),
                  value: _DatabasePathMode.custom,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          if (_mode == _DatabasePathMode.custom)
            Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pathController,
                      decoration: const InputDecoration(
                        labelText: "Database Path",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: _onPathChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _handlePickFolder,
                    icon: const Icon(Icons.folder_open),
                    tooltip: "Browse for folder",
                  ),
                ],
              ),
            ),

          if (hasPathChanged) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _handleApplyRestart,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text("Apply & Restart"),
            ),
          ],

          const Divider(height: 32),

          // --- Import / Export ---
          Text("Import & Export", style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: _handleExport,
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: const Text("Export Database"),
              ),
              OutlinedButton.icon(
                onPressed: _handleImport,
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text("Import Database"),
              ),
            ],
          ),

          const Divider(height: 32),

          // --- Bookmarks ---
          Text("Bookmarks", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            "Export or import bookmarks in standard HTML format, "
            "compatible with all major browsers.",
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: _handleExportBookmarks,
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: const Text("Export Bookmarks"),
              ),
              OutlinedButton.icon(
                onPressed: _handleImportBookmarks,
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text("Import Bookmarks"),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _RestartDialog extends StatelessWidget {
  final String title;
  final String message;

  const _RestartDialog({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        // ignore: prefer_const_constructors
        FilledButton(
          onPressed: SystemNavigator.pop,
          child: const Text("Restart Now"),
        ),
      ],
    );
  }
}
