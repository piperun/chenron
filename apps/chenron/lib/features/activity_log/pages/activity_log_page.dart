import "dart:async";
import "dart:convert";
import "dart:io";

import "package:chenron/utils/safe_async.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";

/// Generalized activity log page with combinable chip filters.
///
/// Inspired by Portmaster's network activity UI: filter chips at the top
/// that combine (e.g. "failed + archive"), search bar, results count,
/// and a scrollable list of log entries.
class ActivityLogPage extends StatefulWidget {
  final AppDatabase database;

  const ActivityLogPage({super.key, required this.database});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  List<BackgroundJob> _allJobs = [];
  bool _loading = true;

  // Filters
  final Set<String> _activeStatuses = {};
  final Set<String> _activeTypes = {};
  String _searchQuery = "";

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

  List<BackgroundJob> get _filteredJobs {
    return _allJobs.where((job) {
      if (_activeStatuses.isNotEmpty && !_activeStatuses.contains(job.status)) {
        return false;
      }
      if (_activeTypes.isNotEmpty && !_activeTypes.contains(job.service)) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesUrl = job.url.toLowerCase().contains(q);
        final matchesError =
            job.error?.toLowerCase().contains(q) ?? false;
        final matchesResult =
            job.resultUrl?.toLowerCase().contains(q) ?? false;
        if (!matchesUrl && !matchesError && !matchesResult) return false;
      }
      return true;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _activeStatuses.isNotEmpty ||
      _activeTypes.isNotEmpty ||
      _searchQuery.isNotEmpty;

  void _toggleStatus(String status) {
    setState(() {
      if (_activeStatuses.contains(status)) {
        _activeStatuses.remove(status);
      } else {
        _activeStatuses.add(status);
      }
    });
  }

  void _toggleType(String type) {
    setState(() {
      if (_activeTypes.contains(type)) {
        _activeTypes.remove(type);
      } else {
        _activeTypes.add(type);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _activeStatuses.clear();
      _activeTypes.clear();
      _searchQuery = "";
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

  Future<void> _handleExport() async {
    final jobs = _filteredJobs;
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

    final result = await FilePicker.platform.saveFile(
      dialogTitle: "Export Activity Log",
      fileName:
          "activity-log-${DateTime.now().toIso8601String().split('T').first}.json",
      type: FileType.custom,
      allowedExtensions: ["json"],
    );

    if (result == null) return;

    await File(result).writeAsString(jsonString);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Exported ${jobs.length} entries to $result")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredJobs;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchBar(
            query: _searchQuery,
            onChanged: (value) => setState(() => _searchQuery = value),
            canExport: filtered.isNotEmpty,
            onExport: _handleExport,
          ),
          const SizedBox(height: 12),
          _FilterChipsRow(
            activeStatuses: _activeStatuses,
            activeTypes: _activeTypes,
            hasActiveFilters: _hasActiveFilters,
            onToggleStatus: _toggleStatus,
            onToggleType: _toggleType,
            onClearFilters: _clearFilters,
          ),
          const SizedBox(height: 16),
          _ResultsBar(
            shown: filtered.length,
            total: _allJobs.length,
            hasActiveFilters: _hasActiveFilters,
            hasCompleted: _allJobs
                .any((j) => j.status == BackgroundJobStatus.completed),
            onClearCompleted: _handleClearCompleted,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _LogBody(
              loading: _loading,
              allEmpty: _allJobs.isEmpty,
              filtered: filtered,
              onRetry: _handleRetry,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;
  final bool canExport;
  final Future<void> Function() onExport;

  const _SearchBar({
    required this.query,
    required this.onChanged,
    required this.canExport,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search log entries...",
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => onChanged(""),
                    )
                  : null,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: canExport ? () => unawaited(onExport()) : null,
          icon: const Icon(Icons.download, size: 18),
          label: const Text("Export"),
        ),
      ],
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  final Set<String> activeStatuses;
  final Set<String> activeTypes;
  final bool hasActiveFilters;
  final ValueChanged<String> onToggleStatus;
  final ValueChanged<String> onToggleType;
  final VoidCallback onClearFilters;

  const _FilterChipsRow({
    required this.activeStatuses,
    required this.activeTypes,
    required this.hasActiveFilters,
    required this.onToggleStatus,
    required this.onToggleType,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _LogFilterChip(
          label: "Queued",
          icon: Icons.schedule,
          selected: activeStatuses.contains(BackgroundJobStatus.queued),
          onSelected: () => onToggleStatus(BackgroundJobStatus.queued),
        ),
        _LogFilterChip(
          label: "In Progress",
          icon: Icons.sync,
          selected: activeStatuses.contains(BackgroundJobStatus.inProgress),
          onSelected: () => onToggleStatus(BackgroundJobStatus.inProgress),
        ),
        _LogFilterChip(
          label: "Completed",
          icon: Icons.check_circle_outline,
          selected: activeStatuses.contains(BackgroundJobStatus.completed),
          onSelected: () => onToggleStatus(BackgroundJobStatus.completed),
        ),
        _LogFilterChip(
          label: "Failed",
          icon: Icons.error_outline,
          selected: activeStatuses.contains(BackgroundJobStatus.failed),
          onSelected: () => onToggleStatus(BackgroundJobStatus.failed),
          color: theme.colorScheme.error,
        ),
        SizedBox(
          height: 32,
          child: VerticalDivider(
            width: 24,
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        _LogFilterChip(
          label: "Archive",
          icon: Icons.archive_outlined,
          selected: activeTypes.contains(BackgroundJobService.archiveOrg),
          onSelected: () => onToggleType(BackgroundJobService.archiveOrg),
        ),
        _LogFilterChip(
          label: "Metadata",
          icon: Icons.description_outlined,
          selected: activeTypes.contains(BackgroundJobService.metadataFetch),
          onSelected: () => onToggleType(BackgroundJobService.metadataFetch),
        ),
        if (hasActiveFilters) ...[
          const SizedBox(width: 4),
          TextButton(
            onPressed: onClearFilters,
            child: const Text("Clear All"),
          ),
        ],
      ],
    );
  }
}

class _ResultsBar extends StatelessWidget {
  final int shown;
  final int total;
  final bool hasActiveFilters;
  final bool hasCompleted;
  final Future<void> Function() onClearCompleted;

  const _ResultsBar({
    required this.shown,
    required this.total,
    required this.hasActiveFilters,
    required this.hasCompleted,
    required this.onClearCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          hasActiveFilters
              ? "$shown Results of $total total entries"
              : "$total entries",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        if (hasCompleted)
          TextButton.icon(
            onPressed: () => unawaited(onClearCompleted()),
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text("Clear completed"),
          ),
      ],
    );
  }
}

class _LogBody extends StatelessWidget {
  final bool loading;
  final bool allEmpty;
  final List<BackgroundJob> filtered;
  final Future<void> Function(BackgroundJob) onRetry;

  const _LogBody({
    required this.loading,
    required this.allEmpty,
    required this.filtered,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (allEmpty) return _EmptyState.noActivity(theme: theme);
    if (filtered.isEmpty) return _EmptyState.noMatches(theme: theme);

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
      itemBuilder: (context, index) => _LogEntryTile(
        job: filtered[index],
        onRetry: onRetry,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String title;
  final String? subtitle;
  final ThemeData theme;

  const _EmptyState({
    required this.icon,
    required this.iconSize,
    required this.title,
    required this.theme,
    this.subtitle,
  });

  factory _EmptyState.noActivity({required ThemeData theme}) {
    return _EmptyState(
      icon: Icons.text_snippet_outlined,
      iconSize: 64,
      title: "No activity yet",
      subtitle: "Background jobs will appear here as they run.",
      theme: theme,
    );
  }

  factory _EmptyState.noMatches({required ThemeData theme}) {
    return _EmptyState(
      icon: Icons.filter_list_off,
      iconSize: 48,
      title: "No entries match current filters",
      theme: theme,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dimmed =
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: dimmed),
          SizedBox(height: subtitle == null ? 12 : 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LogFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  const _LogFilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return FilterChip(
      label: Text(label),
      avatar: selected ? null : Icon(icon, size: 16),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: chipColor.withValues(alpha: 0.15),
      checkmarkColor: chipColor,
      side: selected
          ? BorderSide(color: chipColor.withValues(alpha: 0.5))
          : null,
      visualDensity: VisualDensity.compact,
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

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        job.url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: _buildSubtitle(theme),
      trailing: _buildTrailing(theme),
    );
  }

  Widget? _buildSubtitle(ThemeData theme) {
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

  Widget? _buildTrailing(ThemeData theme) {
    // Retry button only makes sense for queued archive jobs that re-run via
    // the processor. Metadata fetch entries are audit-log style and would
    // need the URL re-fetched directly — not supported here.
    if (job.status == BackgroundJobStatus.failed &&
        job.service != BackgroundJobService.metadataFetch) {
      return IconButton(
        icon: const Icon(Icons.replay),
        tooltip: "Retry",
        onPressed: () => onRetry(job),
      );
    }
    return null;
  }

  static String _serviceLabel(String service) {
    return switch (service) {
      BackgroundJobService.archiveOrg => "archive.org",
      BackgroundJobService.archiveIs => "archive.is",
      BackgroundJobService.metadataFetch => "metadata",
      _ => service,
    };
  }

  (IconData, Color) _statusVisual(ThemeData theme) {
    return switch (job.status) {
      BackgroundJobStatus.queued =>
        (Icons.schedule, theme.colorScheme.onSurfaceVariant),
      BackgroundJobStatus.inProgress =>
        (Icons.sync, theme.colorScheme.primary),
      BackgroundJobStatus.completed =>
        (Icons.check_circle, theme.colorScheme.primary),
      BackgroundJobStatus.failed =>
        (Icons.error_outline, theme.colorScheme.error),
      _ => (Icons.help_outline, theme.colorScheme.onSurfaceVariant),
    };
  }
}
