import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/locator.dart";
import "package:chenron/base_dirs/schema.dart";
import "package:basedir/directory.dart";

enum BackupPathMode { defaultMode, custom }

class ScheduleSettings extends StatefulWidget {
  final ConfigController controller;

  const ScheduleSettings({super.key, required this.controller});

  @override
  State<ScheduleSettings> createState() => _ScheduleSettingsState();
}

class _ScheduleSettingsState extends State<ScheduleSettings> {
  late TextEditingController _pathController;
  BackupPathMode _mode = BackupPathMode.defaultMode;

  static const _intervalOptions = <(String, String?)>[
    ("Off", null),
    ("Every 4 hours", "0 0 */4 * * *"),
    ("Every 8 hours", "0 0 */8 * * *"),
    ("Every 12 hours", "0 0 */12 * * *"),
    ("Every 24 hours", "0 0 0 * * *"),
  ];

  @override
  void initState() {
    super.initState();
    final customPath = widget.controller.backupPath.peek();
    _mode = customPath == null
        ? BackupPathMode.defaultMode
        : BackupPathMode.custom;
    _pathController = TextEditingController(text: customPath ?? "");
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  Future<String> _getDefaultBackupPath() async {
    final baseDirsFuture =
        locator.get<Signal<Future<BaseDirectories<ChenronDir>?>>>();
    final baseDirs = await baseDirsFuture.value;
    return baseDirs?.backupAppDir.path ?? "Unknown";
  }

  Future<void> _pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _pathController.text = result;
      });
      widget.controller.updateBackupPath(result);
    }
  }

  void _onModeChanged(BackupPathMode? mode) {
    if (mode == null) return;

    setState(() {
      _mode = mode;
    });

    if (mode == BackupPathMode.defaultMode) {
      widget.controller.updateBackupPath(null);
      _pathController.clear();
    } else {
      if (_pathController.text.isNotEmpty) {
        widget.controller.updateBackupPath(_pathController.text);
      }
    }
  }

  void _onPathChanged(String value) {
    if (_mode == BackupPathMode.custom && value.trim().isNotEmpty) {
      widget.controller.updateBackupPath(value.trim());
    }
  }

  String _labelForCron(String? cronExpression) {
    for (final (label, cron) in _intervalOptions) {
      if (cron == cronExpression) return label;
    }
    return "Custom ($cronExpression)";
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return "Never";
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inHours < 1) return "${diff.inMinutes}m ago";
    if (diff.inDays < 1) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch((context) {
      final interval = widget.controller.backupInterval.value;
      final backup = widget.controller.backupSettings.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Backup Schedule Section
          Text(
            "Backup Schedule",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Automatically back up your database at regular intervals.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),

          // Interval dropdown
          Row(
            children: [
              Text("Frequency:", style: theme.textTheme.bodyMedium),
              const SizedBox(width: 16),
              DropdownButton<String?>(
                value: interval,
                onChanged: (value) {
                  widget.controller.updateBackupInterval(value);
                },
                items: _intervalOptions
                    .map(
                      (option) => DropdownMenuItem<String?>(
                        value: option.$2,
                        child: Text(option.$1),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),

          const Divider(height: 32),

          // Backup Location Section
          Text(
            "Backup Location",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Where database backups are stored.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),

          // Radio Group for Mode
          RadioGroup<BackupPathMode>(
            groupValue: _mode,
            onChanged: _onModeChanged,
            child: Column(
              children: [
                RadioListTile<BackupPathMode>(
                  title: const Text("Default"),
                  value: BackupPathMode.defaultMode,
                  contentPadding: EdgeInsets.zero,
                  subtitle: FutureBuilder<String>(
                    future: _getDefaultBackupPath(),
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
                const RadioListTile<BackupPathMode>(
                  title: Text("Custom"),
                  value: BackupPathMode.custom,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Custom path input
          if (_mode == BackupPathMode.custom)
            Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pathController,
                      decoration: const InputDecoration(
                        labelText: "Backup Path",
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

          // Last Backup Info
          Text(
            "Backup Status",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.history,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Last Backup",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    _formatTimestamp(backup?.lastBackupTimestamp),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Icon(
                Icons.schedule,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Current Schedule",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    _labelForCron(backup?.backupInterval),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });
  }
}
