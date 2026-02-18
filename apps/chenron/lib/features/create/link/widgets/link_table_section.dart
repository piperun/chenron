import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:chenron/notifiers/item_table_notifier.dart";
import "package:chenron/components/tables/item_table.dart";
import "package:chenron/features/create/link/renderers/link_column_builder.dart";
import "package:chenron/features/create/link/renderers/link_row_builder.dart";
import "package:chenron/features/create/link/renderers/link_empty_state.dart";
import "package:chenron/features/create/link/renderers/link_table_actions.dart";

class LinkTableSection extends StatelessWidget {
  final List<LinkEntry> entries;
  final ItemTableNotifier<dynamic> notifier;
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

  bool get hasSelectedRows =>
      notifier.stateManager?.checkedRows.isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch((context) {
      notifier.hasCheckedRows.value; // subscribe to row check changes
      return Card(
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
                    "Prepared Links (${entries.length})",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  LinkTableActions(
                    hasSelectedRows: hasSelectedRows,
                    hasEntries: entries.isNotEmpty,
                    onDeleteSelected: onDeleteSelected,
                    onClearAll: onClearAll,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: entries.isEmpty
                    ? LinkEmptyState.build()
                    : DataGrid(
                        key: ValueKey(entries
                            .map((e) =>
                                "${e.key}_${e.validationStatus}_${e.validationStatusCode ?? 0}_${e.tags.join(',')}_${e.folderIds.join(',')}_${e.isArchived}")
                            .join("|")),
                        columns: LinkColumnBuilder.build(
                          entries: entries,
                          theme: theme,
                          context: context,
                          folderNames: folderNames,
                          onEdit: onEdit,
                          onDelete: onDelete,
                        ),
                        rows: LinkRowBuilder.build(entries),
                        notifier: notifier,
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

