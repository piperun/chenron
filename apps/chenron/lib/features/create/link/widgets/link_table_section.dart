import "package:flutter/material.dart";
import "package:trina_grid/trina_grid.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:chenron/notifiers/link_table_notifier.dart";
import "package:chenron/components/tables/link_table.dart";

class LinkTableSection extends StatefulWidget {
  final List<LinkEntry> entries;
  final DataGridNotifier notifier;
  final ValueChanged<Key> onEdit;
  final ValueChanged<Key> onDelete;
  final VoidCallback onDeleteSelected;
  final VoidCallback onClearAll;
  final Map<String, String> folderNames;

  const LinkTableSection({
    super.key,
    required this.entries,
    required this.notifier,
    required this.onEdit,
    required this.onDelete,
    required this.onDeleteSelected,
    required this.onClearAll,
    required this.folderNames,
  });

  @override
  State<LinkTableSection> createState() => _LinkTableSectionState();
}

class _LinkTableSectionState extends State<LinkTableSection> {
  bool get hasSelectedRows => widget.notifier.stateManager?.checkedRows.isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, _) => Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Prepared Links (${widget.entries.length})",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: hasSelectedRows ? widget.onDeleteSelected : null,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text("Delete Selected"),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: widget.entries.isEmpty ? null : widget.onClearAll,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text("Clear All"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.link_off,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No links added yet",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Add URLs above to see them here",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : DataGrid(
                      columns: _buildColumns(theme),
                      rows: _buildRows(widget.entries, theme),
                      notifier: widget.notifier,
                    ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  List<TrinaColumn> _buildColumns(ThemeData theme) {
    return [
      TrinaColumn(
        title: "Status",
        field: "status",
        type: TrinaColumnType.text(),
        width: 80,
        enableRowChecked: true,
        renderer: (rendererContext) {
          final entry = widget.entries.firstWhere((e) => e.key == rendererContext.row.key);
          return _buildStatusWidget(entry, theme);
        },
      ),
      TrinaColumn(
        title: "URL",
        field: "url",
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: "Tags",
        field: "tags",
        type: TrinaColumnType.text(),
        width: 200,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final entry = widget.entries.firstWhere((e) => e.key == rendererContext.row.key);
          return _buildTagsWidget(entry, theme);
        },
      ),
      TrinaColumn(
        title: "Folders",
        field: "folders",
        type: TrinaColumnType.text(),
        width: 180,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final entry = widget.entries.firstWhere((e) => e.key == rendererContext.row.key);
          return _buildFoldersWidget(entry, theme);
        },
      ),
      TrinaColumn(
        title: "Archived",
        field: "archived",
        type: TrinaColumnType.text(),
        width: 80,
      ),
      TrinaColumn(
        title: "Actions",
        field: "actions",
        type: TrinaColumnType.text(),
        width: 150,
        renderer: (rendererContext) {
          final entry = widget.entries.firstWhere((e) => e.key == rendererContext.row.key);
          return _buildActionsWidget(entry, theme);
        },
      ),
    ];
  }

  List<TrinaRow> _buildRows(List<LinkEntry> entries, ThemeData theme) {
    return entries.map((entry) {
      return TrinaRow(
        key: entry.key,
        cells: {
          "status": TrinaCell(value: ""),
          "url": TrinaCell(value: entry.url),
          "tags": TrinaCell(value: ""),
          "folders": TrinaCell(value: ""),
          "archived": TrinaCell(value: entry.isArchived ? "Yes" : "No"),
          "actions": TrinaCell(value: ""),
        },
      );
    }).toList();
  }


  Widget _buildStatusWidget(LinkEntry entry, ThemeData theme) {
    IconData icon;
    Color color;
    String tooltip;

    switch (entry.validationStatus) {
      case LinkValidationStatus.pending:
        icon = Icons.schedule;
        color = theme.colorScheme.onSurfaceVariant;
        tooltip = "Pending validation";
        break;
      case LinkValidationStatus.validating:
        icon = Icons.sync;
        color = theme.colorScheme.primary;
        tooltip = "Validating...";
        break;
      case LinkValidationStatus.valid:
        icon = Icons.check_circle;
        color = Colors.green;
        tooltip = "Valid & reachable";
        break;
      case LinkValidationStatus.invalid:
        icon = Icons.error;
        color = theme.colorScheme.error;
        tooltip = entry.validationMessage ?? "Invalid URL";
        break;
      case LinkValidationStatus.unreachable:
        icon = Icons.warning;
        color = Colors.orange;
        tooltip = entry.validationMessage ?? "URL unreachable";
        break;
    }

    return InkWell(
      onTap: () {
        _showValidationDialog(entry, theme);
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Tooltip(
          message: tooltip,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  void _showValidationDialog(LinkEntry entry, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getStatusIcon(entry.validationStatus), color: _getStatusColor(entry.validationStatus, theme)),
            const SizedBox(width: 12),
            const Text("URL Validation Status"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("URL:", style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            SelectableText(entry.url, style: const TextStyle(fontFamily: "monospace")),
            const SizedBox(height: 16),
            Text("Status:", style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(_getStatusText(entry.validationStatus)),
            if (entry.validationMessage != null) ...[
              const SizedBox(height: 16),
              Text("Details:", style: theme.textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(entry.validationMessage!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(LinkValidationStatus status) {
    switch (status) {
      case LinkValidationStatus.pending: return Icons.schedule;
      case LinkValidationStatus.validating: return Icons.sync;
      case LinkValidationStatus.valid: return Icons.check_circle;
      case LinkValidationStatus.invalid: return Icons.error;
      case LinkValidationStatus.unreachable: return Icons.warning;
    }
  }

  Color _getStatusColor(LinkValidationStatus status, ThemeData theme) {
    switch (status) {
      case LinkValidationStatus.pending: return theme.colorScheme.onSurfaceVariant;
      case LinkValidationStatus.validating: return theme.colorScheme.primary;
      case LinkValidationStatus.valid: return Colors.green;
      case LinkValidationStatus.invalid: return theme.colorScheme.error;
      case LinkValidationStatus.unreachable: return Colors.orange;
    }
  }

  String _getStatusText(LinkValidationStatus status) {
    switch (status) {
      case LinkValidationStatus.pending: return "Pending validation";
      case LinkValidationStatus.validating: return "Validating...";
      case LinkValidationStatus.valid: return "Valid & reachable";
      case LinkValidationStatus.invalid: return "Invalid URL";
      case LinkValidationStatus.unreachable: return "URL unreachable";
    }
  }

  Widget _buildTagsWidget(LinkEntry entry, ThemeData theme) {
    if (entry.tags.isEmpty) {
      return const Text("-", style: TextStyle(color: Colors.grey));
    }
    
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: entry.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "#$tag",
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFoldersWidget(LinkEntry entry, ThemeData theme) {
    if (entry.folderIds.isEmpty) {
      return const Text("default", style: TextStyle(fontSize: 12));
    }
    
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: entry.folderIds.map((folderId) {
        final folderName = widget.folderNames[folderId] ?? folderId;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            folderName,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionsWidget(LinkEntry entry, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: () => widget.onEdit(entry.key),
          tooltip: "Edit",
        ),
        IconButton(
          icon: Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
          onPressed: () => widget.onDelete(entry.key),
          tooltip: "Delete",
        ),
      ],
    );
  }
}
