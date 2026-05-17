import "dart:async";
import "dart:convert";
import "dart:io";

import "package:chenron/utils/safe_async.dart";
import "package:database/database.dart";
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
    final theme = Theme.of(context);
    final filtered = _filteredJobs;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(theme),
          const SizedBox(height: 12),
          _buildFilterChips(theme),
          const SizedBox(height: 16),
          _buildResultsBar(theme, filtered),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(theme, filtered)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search log entries...",
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _searchQuery = ""),
                    )
                  : null,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _filteredJobs.isEmpty ? null : _handleExport,
          icon: const Icon(Icons.download, size: 18),
          label: const Text("Export"),
        ),
      ],
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Status filters
        _LogFilterChip(
          label: "Queued",
          icon: Icons.schedule,
          selected: _activeStatuses.contains("queued"),
          onSelected: () => _toggleStatus("queued"),
        ),
        _LogFilterChip(
          label: "In Progress",
          icon: Icons.sync,
          selected: _activeStatuses.contains("in_progress"),
          onSelected: () => _toggleStatus("in_progress"),
        ),
        _LogFilterChip(
          label: "Completed",
          icon: Icons.check_circle_outline,
          selected: _activeStatuses.contains("completed"),
          onSelected: () => _toggleStatus("completed"),
        ),
        _LogFilterChip(
          label: "Failed",
          icon: Icons.error_outline,
          selected: _activeStatuses.contains("failed"),
          onSelected: () => _toggleStatus("failed"),
          color: theme.colorScheme.error,
        ),
        SizedBox(
          height: 32,
          child: VerticalDivider(
            width: 24,
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        // Type filters
        _LogFilterChip(
          label: "Archive",
          icon: Icons.archive_outlined,
          selected: _activeTypes.contains("archive_org"),
          onSelected: () => _toggleType("archive_org"),
        ),
        _LogFilterChip(
          label: "Metadata",
          icon: Icons.description_outlined,
          selected: _activeTypes.contains("metadata_fetch"),
          onSelected: () => _toggleType("metadata_fetch"),
        ),
        // Future: network, download, etc.
        if (_hasActiveFilters) ...[
          const SizedBox(width: 4),
          TextButton(
            onPressed: _clearFilters,
            child: const Text("Clear All"),
          ),
        ],
      ],
    );
  }

  Widget _buildResultsBar(ThemeData theme, List<BackgroundJob> filtered) {
    final total = _allJobs.length;
    final shown = filtered.length;
    final hasCompleted = _allJobs.any((j) => j.status == "completed");

    return Row(
      children: [
        Text(
          _hasActiveFilters
              ? "$shown Results of $total total entries"
              : "$total entries",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        if (hasCompleted)
          TextButton.icon(
            onPressed: _handleClearCompleted,
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text("Clear completed"),
          ),
      ],
    );
  }

  Widget _buildBody(ThemeData theme, List<BackgroundJob> filtered) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.text_snippet_outlined,
              size: 64,
              color:
                  theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "No activity yet",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Background jobs will appear here as they run.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 48,
              color:
                  theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              "No entries match current filters",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
      itemBuilder: (context, index) => _LogEntryTile(
        job: filtered[index],
        onRetry: _handleRetry,
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
      "failed" => job.error ?? "Unknown error",
      "completed" => job.resultUrl ?? "Archived",
      "in_progress" => "Archiving...",
      "queued" => "Waiting in queue",
      _ => "",
    };

    final detailColor = switch (job.status) {
      "failed" => theme.colorScheme.error,
      "completed" => theme.colorScheme.primary,
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
    if (job.status == "failed" && job.service != "metadata_fetch") {
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
      "archive_org" => "archive.org",
      "archive_is" => "archive.is",
      "metadata_fetch" => "metadata",
      _ => service,
    };
  }

  (IconData, Color) _statusVisual(ThemeData theme) {
    return switch (job.status) {
      "queued" => (Icons.schedule, theme.colorScheme.onSurfaceVariant),
      "in_progress" => (Icons.sync, theme.colorScheme.primary),
      "completed" => (Icons.check_circle, theme.colorScheme.primary),
      "failed" => (Icons.error_outline, theme.colorScheme.error),
      _ => (Icons.help_outline, theme.colorScheme.onSurfaceVariant),
    };
  }
}
