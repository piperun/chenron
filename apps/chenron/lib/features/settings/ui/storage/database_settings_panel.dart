import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:vibe/vibe.dart";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/settings/ui/shared/path_mode_selector.dart";
import "package:chenron/features/settings/ui/shared/restart_dialog.dart";
import "package:chenron/features/settings/ui/shared/settings_section_header.dart";
import "package:chenron/locator.dart";

/// Where the application database lives on disk. Changing it requires a
/// restart because the database is opened once during startup.
class DatabaseSettingsPanel extends StatefulWidget {
  const DatabaseSettingsPanel({super.key});

  @override
  State<DatabaseSettingsPanel> createState() => _DatabaseSettingsPanelState();
}

class _DatabaseSettingsPanelState extends State<DatabaseSettingsPanel> {
  final DataSettingsService _dataService = locator.get<DataSettingsService>();
  late final _databaseNotifier = locator.get<SettingsCoordinator>().database;

  Future<void> _handleApplyRestart() async {
    final navigator = Navigator.of(context);

    // Save the path to SharedPreferences immediately
    await _databaseNotifier.save();

    if (!mounted) return;

    await showDialog<void>(
      context: navigator.context,
      barrierDismissible: false,
      builder: (context) => const RestartDialog(
        title: "Restart Required",
        message: "The database location has been updated. "
            "The app needs to restart for this change to take effect.",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(builder: (context) {
      // Subscribe to current/saved changes so the "Apply" button toggles.
      final currentPath = _databaseNotifier.current.value;
      final hasPathChanged = _databaseNotifier.isDirty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
            MinorButton(
              label: "Apply & Restart",
              icon: Icons.restart_alt,
              onPressed: _handleApplyRestart,
            ),
          ],
        ],
      );
    });
  }
}
