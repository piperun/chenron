import "package:chenron/features/folder_editor/widgets/item_section/item_section_toolbar.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:trina_grid/trina_grid.dart";
import "package:database/models/item.dart";
import "package:chenron/notifiers/item_table_notifier.dart";
import "package:chenron/features/folder_editor/widgets/item_section/item_section_controller.dart";
import "package:chenron/features/folder_editor/widgets/item_table_section/item_table_filter.dart";
import "package:chenron/features/folder_editor/widgets/item_table_section/item_table_view.dart";

class ItemSectionContent extends StatelessWidget {
  final ItemSectionController controller;
  final VoidCallback onAddLink;
  final VoidCallback onAddDocument;
  final VoidCallback onDeleteSelected;
  final bool hasSelectedRows;
  final List<TrinaColumn> columns;
  final List<TrinaRow<dynamic>> Function(List<FolderItem>) buildRows;
  final ItemTableNotifier<FolderItem> tableNotifier;

  const ItemSectionContent({
    super.key,
    required this.controller,
    required this.onAddLink,
    required this.onAddDocument,
    required this.onDeleteSelected,
    required this.hasSelectedRows,
    required this.columns,
    required this.buildRows,
    required this.tableNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toolbar
        Watch((context) => ItemSectionToolbar(
              items: controller.filteredItems.value,
              hasSelectedRows: hasSelectedRows,
              onAddLink: onAddLink,
              onAddDocument: onAddDocument,
              onDeleteSelected: onDeleteSelected,
            )),

        const SizedBox(height: 12),

        // Search filter (conditionally shown)
        Watch((context) {
          if (controller.allItems.value.isNotEmpty) {
            return Column(
              children: [
                ItemTableFilter(controller: controller),
                const SizedBox(height: 12),
              ],
            );
          }
          return const SizedBox.shrink();
        }),

        // Main content
        Watch((context) => ItemTableView(
              items: controller.filteredItems.value,
              allItems: controller.allItems.value,
              hasSearchQuery: controller.searchQuery.value.isNotEmpty,
              columns: columns,
              buildRows: buildRows,
              tableNotifier: tableNotifier,
            )),
      ],
    );
  }
}

