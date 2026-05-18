import "package:basedir/directory.dart";
import "package:chenron/base_dirs/schema.dart";
import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/state/backup_settings.dart";
import "package:chenron/features/settings/ui/shared/path_mode_selector.dart";
import "package:chenron/features/settings/ui/shared/settings_section_header.dart";
import "package:chenron/locator.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:signals/signals_flutter.dart";

enum _IntervalUnit { hours, days }

/// Sentinel value used in the dropdown to indicate "Custom" selection.
const _customSentinel = "__custom__";

class BackupSettings extends StatefulWidget {
  const BackupSettings({super.key});

  @override
  State<BackupSettings> createState() => _BackupSettingsState();
}

class _BackupSettingsState extends State<BackupSettings> {
  late final BackupSettingsNotifier _notifier;
  late TextEditingController _customAmountController;
  bool _isCustomInterval = false;
  _IntervalUnit _customUnit = _IntervalUnit.hours;

  static const _presetOptions = <(String, String?)>[
    ("Off", null),
    ("Every 4 hours", "0 0 */4 * * *"),
    ("Every 8 hours", "0 0 */8 * * *"),
    ("Every 12 hours", "0 0 */12 * * *"),
    ("Every 24 hours", "0 0 0 * * *"),
  ];

  static bool _isPreset(String? cron) {
    return _presetOptions.any((o) => o.$2 == cron);
  }

  /// Parse a custom cron expression into (amount, unit).
  static (int, _IntervalUnit)? _parseCustomCron(String cron) {
    final hourMatch = RegExp(r"^0 0 \*/(\d+) \* \* \*$").firstMatch(cron);
    if (hourMatch != null) {
      return (int.parse(hourMatch.group(1)!), _IntervalUnit.hours);
    }
    final dayMatch = RegExp(r"^0 0 0 \*/(\d+) \* \*$").firstMatch(cron);
    if (dayMatch != null) {
      return (int.parse(dayMatch.group(1)!), _IntervalUnit.days);
    }
    return null;
  }

  static String _buildCron(int amount, _IntervalUnit unit) {
    return switch (unit) {
      _IntervalUnit.hours => "0 0 */$amount * * *",
      _IntervalUnit.days => "0 0 0 */$amount * *",
    };
  }

  @override
  void initState() {
    super.initState();
    _notifier = locator.get<SettingsCoordinator>().backup;

    final currentCron = _notifier.current.peek().backupInterval;
    if (currentCron != null && !_isPreset(currentCron)) {
      _isCustomInterval = true;
      final parsed = _parseCustomCron(currentCron);
      if (parsed != null) {
        _customAmountController =
            TextEditingController(text: parsed.$1.toString());
        _customUnit = parsed.$2;
      } else {
        _customAmountController = TextEditingController(text: "1");
      }
    } else {
      _customAmountController = TextEditingController(text: "2");
    }
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  Future<String> _getDefaultBackupPath() async {
    final baseDirsFuture =
        locator.get<Signal<Future<BaseDirectories<ChenronDir>?>>>();
    final baseDirs = await baseDirsFuture.value;
    return baseDirs?.backupAppDir.path ?? "Unknown";
  }

  void _applyCustomInterval() {
    final amount = int.tryParse(_customAmountController.text);
    if (amount != null && amount > 0) {
      final cron = _buildCron(amount, _customUnit);
      _notifier.update((s) => s.copyWith(backupInterval: cron));
    }
  }

  String _labelForCron(String? cronExpression) {
    for (final (label, cron) in _presetOptions) {
      if (cron == cronExpression) return label;
    }
    if (cronExpression == null) return "Off";
    final parsed = _parseCustomCron(cronExpression);
    if (parsed != null) {
      final unit = parsed.$2 == _IntervalUnit.hours ? "hours" : "days";
      return "Every ${parsed.$1} $unit";
    }
    return "Custom";
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SettingsSectionHeader(
          title: "Backup Schedule",
          description:
              "Automatically back up your database at regular intervals.",
        ),
        Row(
          children: [
            Text("Frequency:", style: theme.textTheme.bodyMedium),
            const SizedBox(width: 16),
            Watch((context) {
              final interval = _notifier.current.value.backupInterval;
              return DropdownButton<String>(
                value: _isCustomInterval
                    ? _customSentinel
                    : (interval ?? ""),
                onChanged: (value) {
                  if (value == _customSentinel) {
                    setState(() => _isCustomInterval = true);
                    _applyCustomInterval();
                  } else {
                    setState(() => _isCustomInterval = false);
                    _notifier.update((s) => s.copyWith(
                          backupInterval: value == "" ? null : value,
                        ));
                  }
                },
                items: [
                  ..._presetOptions.map(
                    (option) => DropdownMenuItem<String>(
                      value: option.$2 ?? "",
                      child: Text(option.$1),
                    ),
                  ),
                  const DropdownMenuItem<String>(
                    value: _customSentinel,
                    child: Text("Custom"),
                  ),
                ],
              );
            }),
          ],
        ),
        if (_isCustomInterval)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              children: [
                const Text("Every "),
                SizedBox(
                  width: 64,
                  child: TextField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (_) => _applyCustomInterval(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<_IntervalUnit>(
                  value: _customUnit,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _customUnit = value);
                    _applyCustomInterval();
                  },
                  items: const [
                    DropdownMenuItem(
                      value: _IntervalUnit.hours,
                      child: Text("hours"),
                    ),
                    DropdownMenuItem(
                      value: _IntervalUnit.days,
                      child: Text("days"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const Divider(height: 32),
        const SettingsSectionHeader(
          title: "Backup Location",
          description: "Where database backups are stored.",
        ),
        PathModeSelector(
          currentPath: _notifier.current.peek().backupPath,
          options: [
            PathModeOption(
              label: "Default",
              resolveSubtitle: _getDefaultBackupPath,
            ),
            const PathModeOption(label: "Custom", isCustom: true),
          ],
          fieldLabel: "Backup Path",
          onPathChanged: (value) =>
              _notifier.update((s) => s.copyWith(backupPath: value)),
        ),
        const Divider(height: 32),
        Text("Backup Status", style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Watch((context) {
          final snap = _notifier.current.value;
          final lastBackup = _notifier.lastBackupTimestamp.value;
          return Row(
            children: [
              Icon(Icons.history, size: 20, color: theme.colorScheme.primary),
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
                    _formatTimestamp(lastBackup),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Icon(Icons.schedule, size: 20, color: theme.colorScheme.primary),
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
                    _labelForCron(snap.backupInterval),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }
}
