import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:vibe/vibe.dart";

import "package:chenron/features/settings/service/bookmark_export_service.dart";
import "package:chenron/features/settings/service/bookmark_import_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/settings/ui/shared/restart_dialog.dart";
import "package:chenron/features/settings/ui/shared/settings_section_header.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/dialogs/confirm_dialog.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";

/// Database and bookmark import/export flows.
class ImportExportSettingsPanel extends StatefulWidget {
  const ImportExportSettingsPanel({super.key});

  @override
  State<ImportExportSettingsPanel> createState() =>
      _ImportExportSettingsPanelState();
}

class _ImportExportSettingsPanelState extends State<ImportExportSettingsPanel> {
  final DataSettingsService _dataService = locator.get<DataSettingsService>();

  Future<void> _handleExport() async {
    final messenger = ScaffoldMessenger.of(context);

    final destination = await FilePicker.getDirectoryPath();
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

    final picked = await FilePicker.pickFiles(
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
          builder: (context) => const RestartDialog(
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

    final destination = await FilePicker.saveFile(
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

    final picked = await FilePicker.pickFiles(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Import & Export", style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MinorButton(
              label: "Export Database",
              icon: Icons.upload_outlined,
              onPressed: _handleExport,
            ),
            MinorButton(
              label: "Import Database",
              icon: Icons.download_outlined,
              onPressed: _handleImport,
            ),
          ],
        ),
        const Divider(height: 32),
        const SettingsSectionHeader(
          title: "Bookmarks",
          description: "Export or import bookmarks in standard HTML format, "
              "compatible with all major browsers.",
          gapAfter: 12,
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MinorButton(
              label: "Export Bookmarks",
              icon: Icons.upload_outlined,
              onPressed: _handleExportBookmarks,
            ),
            MinorButton(
              label: "Import Bookmarks",
              icon: Icons.download_outlined,
              onPressed: _handleImportBookmarks,
            ),
          ],
        ),
      ],
    );
  }
}
