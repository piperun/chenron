import "package:flutter/material.dart";
import "package:chenron/components/tables/item_table.dart";
import "package:database/models/item.dart";
import "package:chenron/notifiers/item_table_notifier.dart";
import "package:trina_grid/trina_grid.dart";
import "package:chenron/features/folder_editor/widgets/item_section/empty_state_message.dart";

class ItemTableView extends StatelessWidget {
  final List<FolderItem> items;
  final List<FolderItem> allItems;
  final bool hasSearchQuery;
  final List<TrinaColumn> columns;
  final List<TrinaRow> Function(List<FolderItem>) buildRows;
  final ItemTableNotifier tableNotifier;

  const ItemTableView({
    super.key,
    required this.items,
    required this.allItems,
    required this.hasSearchQuery,
    required this.columns,
    required this.buildRows,
    required this.tableNotifier,
  });

  @override
  Widget build(BuildContext context) {
    // No items at all
    if (items.isEmpty && allItems.isEmpty) {
      return const EmptyStateMessage(
        message: "No items in this folder",
        icon: Icons.folder_open,
      );
    }

    // Has items but search returned nothing
    if (items.isEmpty && hasSearchQuery) {
      return const EmptyStateMessage(
        message: "No items match your search",
        icon: Icons.search_off,
      );
    }

    // Show the table
    return SizedBox(
      height: 300,
      child: DataGrid(
        key: ValueKey(items.map((i) => i.id).join("|")),
        columns: columns,
        rows: buildRows(items),
        notifier: tableNotifier,
      ),
    );
  }
}

