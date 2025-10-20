import "package:flutter/material.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:chenron/notifiers/item_table_notifier.dart";
import "package:chenron/components/tables/item_table.dart";
import "package:chenron/features/create/link/renderers/link_column_builder.dart";
import "package:chenron/features/create/link/renderers/link_row_builder.dart";
import "package:chenron/features/create/link/renderers/link_empty_state.dart";
import "package:chenron/features/create/link/renderers/link_table_actions.dart";

class LinkTableSection extends StatefulWidget {
  final List<LinkEntry> entries;
  final ItemTableNotifier notifier;
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
  bool get hasSelectedRows =>
      widget.notifier.stateManager?.checkedRows.isNotEmpty ?? false;

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
                  LinkTableActions(
                    hasSelectedRows: hasSelectedRows,
                    hasEntries: widget.entries.isNotEmpty,
                    onDeleteSelected: widget.onDeleteSelected,
                    onClearAll: widget.onClearAll,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: widget.entries.isEmpty
                    ? LinkEmptyState.build(theme)
                    : DataGrid(
                        key: ValueKey(widget.entries
                            .map((e) =>
                                "${e.key}_${e.validationStatus}_${e.validationStatusCode ?? 0}_${e.tags.join(',')}_${e.folderIds.join(',')}_${e.isArchived}")
                            .join("|")),
                        columns: LinkColumnBuilder.build(
                          entries: widget.entries,
                          theme: theme,
                          context: context,
                          folderNames: widget.folderNames,
                          onEdit: widget.onEdit,
                          onDelete: widget.onDelete,
                        ),
                        rows: LinkRowBuilder.build(widget.entries),
                        notifier: widget.notifier,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
