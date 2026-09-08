import "dart:async";
import "dart:convert";
import "dart:io";

import "package:chenron/features/activity_log/activity_log_settings.dart";
import "package:chenron/utils/safe_async.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:vibe/vibe.dart";
import "package:log_view/log_view.dart";

/// Chenron's job history and actions, presented by the shared log view.
class ActivityLogPage extends StatefulWidget {
  final AppDatabase database;

  /// Status filter chips active when the page opens. Empty means no
  /// filter. Used by "View Log" failure-toast actions to land the user
  /// directly on the failed entries.
  final Set<String> initialStatusFilters;

  /// Writes [contents] to the file at [path]. Injectable so tests can
  /// simulate a permission/read-only failure; defaults to a real
  /// [File.writeAsString].
  @visibleForTesting
  final Future<void> Function(String path, String contents) fileWriter;

  ActivityLogPage({
    super.key,
    required this.database,
    this.initialStatusFilters = const {},
    Future<void> Function(String path, String contents)? fileWriter,
  }) : fileWriter = fileWriter ??
            ((path, contents) => File(path).writeAsString(contents));

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  List<BackgroundJob> _allJobs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadJobs());
  }

  Future<void> _loadJobs() async {
    final jobs = await safeAwait<List<BackgroundJob>>(
      tag: "ActivityLogPage",
      operation: "load background jobs",
      action: widget.database.getAllBackgroundJobs,
    );
    if (!mounted) return;
    setState(() {
      if (jobs != null) _allJobs = jobs;
      _loading = false;
    });
  }

  Future<void> _handleRetry(BackgroundJob job) async {
    final ok = await safeAwait<bool>(
      tag: "ActivityLogPage",
      operation: "retry archive job",
      action: () async {
        await widget.database.retryArchiveJob(job.id);
        return true;
      },
    );
    if (ok == true) await _loadJobs();
  }

  Future<void> _handleClearCompleted() async {
    final ok = await safeAwait<bool>(
      tag: "ActivityLogPage",
      operation: "clear completed jobs",
      action: () async {
        await widget.database.clearCompletedBackgroundJobs();
        return true;
      },
    );
    if (ok == true) await _loadJobs();
  }

  Future<void> _handleOpenSettings() async {
    final current = await ActivityLogSettings.getTtl();
    if (!mounted) return;
    final picked = await showDialog<_TtlChoice>(
      context: context,
      builder: (_) => _TtlSettingsDialog(current: current),
    );
    if (picked == null) return;
    await ActivityLogSettings.setTtl(picked.duration);
  }

  Future<void> _handleExport(List<BackgroundJob> jobs) async {
    final jsonData = jobs
        .map((job) => {
              "id": job.id,
              "linkId": job.linkId,
              "url": job.url,
              "service": job.service,
              "status": job.status,
              "resultUrl": job.resultUrl,
              "error": job.error,
              "attempts": job.attempts,
              "createdAt": job.createdAt.toIso8601String(),
              "updatedAt": job.updatedAt.toIso8601String(),
            })
        .toList();

    final jsonString = const JsonEncoder.withIndent("  ").convert(jsonData);

    final result = await FilePicker.saveFile(
      dialogTitle: "Export Activity Log",
      fileName:
          "activity-log-${DateTime.now().toIso8601String().split('T').first}.json",
      type: FileType.custom,
      allowedExtensions: ["json"],
    );

    if (result == null) return;

    final wrote = await safeAwait<bool>(
      tag: "ActivityLogPage",
      operation: "write activity log export",
      action: () async {
        await widget.fileWriter(result, jsonString);
        return true;
      },
    );
    if (wrote != true) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Exported ${jobs.length} entries to $result")),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: LogView<BackgroundJob>(
          entries: _allJobs,
          entryKey: (job) => job.id,
          loading: _loading,
          initialFilters: {"status": widget.initialStatusFilters},
          searchText: (job) =>
              '${job.url}\n${job.error ?? ""}\n${job.resultUrl ?? ""}',
          filters: [
            LogFilterGroup(id: "status", options: [
              for (final (id, label, icon) in [
                (BackgroundJobStatus.queued, "Queued", Icons.schedule),
                (BackgroundJobStatus.inProgress, "In Progress", Icons.sync),
                (
                  BackgroundJobStatus.completed,
                  "Completed",
                  Icons.check_circle_outline
                ),
                (BackgroundJobStatus.failed, "Failed", Icons.error_outline),
              ])
                LogFilterOption(
                    id: id,
                    label: label,
                    icon: icon,
                    matches: (job) => job.status == id),
            ]),
            LogFilterGroup(id: "type", options: [
              LogFilterOption(
                  id: "archive",
                  label: "Archive",
                  icon: Icons.archive_outlined,
                  matches: (job) =>
                      job.service == BackgroundJobService.archiveOrg ||
                      job.service == BackgroundJobService.archiveIs),
              LogFilterOption(
                  id: "metadata",
                  label: "Metadata",
                  icon: Icons.description_outlined,
                  matches: (job) =>
                      job.service == BackgroundJobService.metadataFetch),
            ]),
          ],
          actionsBuilder: (context, visible) => [
            IconButton(
                tooltip: "Retention settings",
                icon: const Icon(Icons.settings_outlined, size: 20),
                onPressed: () => unawaited(_handleOpenSettings())),
            MinorButton(
                label: "Export",
                icon: Icons.download,
                onPressed: visible.isEmpty
                    ? null
                    : () => unawaited(_handleExport(visible))),
          ],
          resultActions: [
            if (_allJobs
                .any((job) => job.status == BackgroundJobStatus.completed))
              TextButton.icon(
                onPressed: () => unawaited(_handleClearCompleted()),
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text("Clear completed"),
              ),
          ],
          emptyMessage: "No activity yet",
          itemBuilder: (context, job) =>
              _LogEntryTile(job: job, onRetry: _handleRetry),
        ),
      );
}

/// One option in the TTL chooser dialog. `duration: null` = permanent.
class _TtlChoice {
  final String label;
  final Duration? duration;
  const _TtlChoice(this.label, this.duration);

  static const options = <_TtlChoice>[
    _TtlChoice("24 hours", Duration(hours: 24)),
    _TtlChoice("3 days", Duration(hours: 72)),
    _TtlChoice("7 days", Duration(hours: 168)),
    _TtlChoice("30 days", Duration(hours: 720)),
    _TtlChoice("Forever (no auto-purge)", null),
  ];

  /// Match a stored TTL [Duration] (or null) to the closest preset.
  static _TtlChoice fromDuration(Duration? current) {
    if (current == null) return options.last;
    for (final opt in options) {
      if (opt.duration?.inHours == current.inHours) return opt;
    }
    return options.first;
  }
}

class _TtlSettingsDialog extends StatefulWidget {
  final Duration? current;
  const _TtlSettingsDialog({required this.current});

  @override
  State<_TtlSettingsDialog> createState() => _TtlSettingsDialogState();
}

class _TtlSettingsDialogState extends State<_TtlSettingsDialog> {
  late _TtlChoice _selected;

  @override
  void initState() {
    super.initState();
    _selected = _TtlChoice.fromDuration(widget.current);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Activity log retention"),
      content: RadioGroup<_TtlChoice>(
        groupValue: _selected,
        onChanged: (v) {
          if (v != null) setState(() => _selected = v);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Background-job rows older than this are deleted at startup.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ..._TtlChoice.options.map(
              (opt) => RadioListTile<_TtlChoice>(
                title: Text(opt.label),
                value: opt,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text("Save"),
        ),
      ],
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  final BackgroundJob job;
  final Future<void> Function(BackgroundJob) onRetry;

  const _LogEntryTile({required this.job, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _statusVisual(theme);

    // Retry only makes sense for archive jobs (they re-run through the
    // processor). Metadata fetches are audit-log entries — re-fetching
    // happens implicitly on next access, so no Retry button.
    final canRetry = job.status == BackgroundJobStatus.failed &&
        job.service != BackgroundJobService.metadataFetch;

    return LogRecordTile(
      leading: Icon(icon, color: color),
      title: Text(
        job.url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: _LogEntrySubtitle(job: job),
      trailing: canRetry
          ? IconButton(
              icon: const Icon(Icons.replay),
              tooltip: "Retry",
              onPressed: () => onRetry(job),
            )
          : null,
    );
  }

  (IconData, Color) _statusVisual(ThemeData theme) {
    return switch (job.status) {
      BackgroundJobStatus.queued => (
          Icons.schedule,
          theme.colorScheme.onSurfaceVariant
        ),
      BackgroundJobStatus.inProgress => (Icons.sync, theme.colorScheme.primary),
      BackgroundJobStatus.completed => (
          Icons.check_circle,
          theme.colorScheme.primary
        ),
      BackgroundJobStatus.failed => (
          Icons.error_outline,
          theme.colorScheme.error
        ),
      _ => (Icons.help_outline, theme.colorScheme.onSurfaceVariant),
    };
  }
}

class _LogEntrySubtitle extends StatelessWidget {
  final BackgroundJob job;

  const _LogEntrySubtitle({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <InlineSpan>[];

    // Type badge
    parts.add(WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _serviceLabel(job.service),
          style: theme.textTheme.labelSmall,
        ),
      ),
    ));

    // Status-specific detail
    final detail = switch (job.status) {
      BackgroundJobStatus.failed => job.error ?? "Unknown error",
      BackgroundJobStatus.completed => job.resultUrl ?? "Archived",
      BackgroundJobStatus.inProgress => "Archiving...",
      BackgroundJobStatus.queued => "Waiting in queue",
      _ => "",
    };

    final detailColor = switch (job.status) {
      BackgroundJobStatus.failed => theme.colorScheme.error,
      BackgroundJobStatus.completed => theme.colorScheme.primary,
      _ => theme.colorScheme.onSurfaceVariant,
    };

    parts.add(TextSpan(
      text: detail,
      style: theme.textTheme.bodySmall?.copyWith(color: detailColor),
    ));

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: parts),
    );
  }

  static String _serviceLabel(String service) {
    return switch (service) {
      BackgroundJobService.archiveOrg => "archive.org",
      BackgroundJobService.archiveIs => "archive.is",
      BackgroundJobService.metadataFetch => "metadata",
      _ => service,
    };
  }
}
