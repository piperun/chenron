import "dart:async";
import "dart:io";

import "package:cache_manager/cache_manager.dart";
import "package:vibe/vibe.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:file_picker/file_picker.dart";
import "package:signals/signals_flutter.dart";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/bookmark_export_service.dart";
import "package:chenron/features/settings/service/bookmark_import_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/settings/ui/shared/path_mode_selector.dart";
import "package:chenron/features/settings/ui/shared/settings_section_header.dart";
import "package:chenron/features/settings/ui/shared/stats_action_row.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/dialogs/confirm_dialog.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";

class DataSettings extends StatefulWidget {
  const DataSettings({super.key});

  @override
  State<DataSettings> createState() => _DataSettingsState();
}

class _DataSettingsState extends State<DataSettings> {
  final DataSettingsService _dataService = locator.get<DataSettingsService>();
  late final _databaseNotifier =
      locator.get<SettingsCoordinator>().database;
  Future<int>? _metadataCountFuture;

  @override
  void initState() {
    super.initState();
    _refreshMetadataCount();
  }

  void _refreshMetadataCount() {
    _metadataCountFuture = locator.get<MetadataCache>().count();
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
      await locator.get<MetadataCache>().clearAll();
      locator.get<FailureTracker>().clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Metadata cache cleared"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      setState(_refreshMetadataCount);
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _handleExport() async {
    final messenger = ScaffoldMessenger.of(context);

    final destination = await FilePicker.platform.getDirectoryPath();
    if (destination == null) return;

    try {
      final result = await _dataService.exportDatabase(Directory(destination));
      messenger.showSnackBar(SnackBar(
        content: Text("Database exported to ${result.path}"),
        duration: const Duration(seconds: 3),
      ));
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e);
    }
  }

  Future<void> _handleImport() async {
    final confirmed = await showConfirmDialog(
      context,
      title: "Import Database",
      message: "This will replace your current data with the imported "
          "database. The app will need to restart after importing. Continue?",
      confirmLabel: "Import",
    );
    if (!confirmed) return;

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
    await _databaseNotifier.save();

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
      // Subscribe to current/saved changes so the "Apply" button toggles.
      final currentPath = _databaseNotifier.current.value;
      final hasPathChanged = _databaseNotifier.isDirty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Database Location ---
          const SettingsSectionHeader(
            title: "Database Location",
            description: "Where the application database is stored.",
          ),

          PathModeSelector(
            currentPath: currentPath,
            options: [
              PathModeOption(
                label: "Default",
                resolveSubtitle: _dataService.getDefaultDatabasePath,
              ),
              const PathModeOption(
                label: "Custom",
                isCustom: true,
              ),
            ],
            fieldLabel: "Database Path",
            onPathChanged: _databaseNotifier.update,
          ),

          if (hasPathChanged) ...[
            const SizedBox(height: 16),
            OffsetShadow(
              child: FilledButton.icon(
                onPressed: _handleApplyRestart,
                icon: const Icon(Icons.restart_alt, size: 18),
                label: const Text("Apply & Restart"),
              ),
            ),
          ],

          const Divider(height: 32),

          // --- Metadata Cache ---
          // Lives in the app database (above), not the image cache directory.
          const SettingsSectionHeader(
            title: "Metadata Cache",
            description:
                "Cached page titles, descriptions, and preview images stored "
                "in the app database. Clearing forces a refetch on next view.",
          ),
          StatsActionRow(
            icon: Icons.description_outlined,
            label: "Metadata Cache",
            future: _metadataCountFuture!,
            formatValue: (count) =>
                "$count ${count == 1 ? "entry" : "entries"}",
            buttonLabel: "Clear Metadata",
            onClear: () => unawaited(_confirmAndClearMetadata(context)),
          ),

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
          const SettingsSectionHeader(
            title: "Bookmarks",
            description:
                "Export or import bookmarks in standard HTML format, "
                "compatible with all major browsers.",
            gapAfter: 12,
          ),

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
        const OffsetShadow(
          child: FilledButton(
            onPressed: SystemNavigator.pop,
            child: Text("Restart Now"),
          ),
        ),
      ],
    );
  }
}
