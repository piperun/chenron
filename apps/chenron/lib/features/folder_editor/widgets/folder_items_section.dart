import "package:flutter/material.dart";
import "package:trina_grid/trina_grid.dart";
import "package:database/models/item.dart";
import "package:chenron/notifiers/item_table_notifier.dart";
import "package:chenron/features/create/link/pages/create_link.dart";
import "package:chenron/features/folder_editor/item_picker/document_picker_sheet.dart";
import "package:chenron/features/folder_editor/item_picker/link_picker_sheet.dart";
import "package:chenron/features/folder_editor/widgets/item_section/item_section.dart";
import "package:chenron/features/folder_editor/widgets/item_section/item_section_content.dart";
import "package:chenron/features/folder_editor/widgets/item_section/item_section_controller.dart";
import "package:chenron/features/folder_editor/widgets/cells/type_cell.dart";
import "package:chenron/features/folder_editor/widgets/cells/delete_cell.dart";
import "package:chenron/features/folder_editor/notifiers/folder_editor_notifier.dart";
import "package:app_logger/app_logger.dart";

/// Widget for displaying and managing folder items in the editor
class FolderItemsSection extends StatefulWidget {
  final String folderId;
  final List<FolderItem> items;
  final FolderEditorNotifier notifier;

  const FolderItemsSection({
    super.key,
    required this.folderId,
    required this.items,
    required this.notifier,
  });

  @override
  State<FolderItemsSection> createState() => _FolderItemsSectionState();
}

class _FolderItemsSectionState extends State<FolderItemsSection> {
  late final ItemTableNotifier<FolderItem> _tableNotifier;
  late final ItemSectionController _controller;
  late final List<TrinaColumn> _columns;

  @override
  void initState() {
    super.initState();
    _tableNotifier = ItemTableNotifier<FolderItem>();
    _controller = ItemSectionController();
    _columns = _buildColumns();

    // Initialize controller with current items
    _controller.updateItems(widget.items);
  }

  @override
  void didUpdateWidget(FolderItemsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _controller.updateItems(widget.items);
    }
  }

  @override
  void dispose() {
    _tableNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refreshItems() async {
    try {
      await widget.notifier.loadFolder(widget.folderId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to refresh items: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleAddLink() async {
    final List<FolderItem>? picked = await showModalBottomSheet<List<FolderItem>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LinkPickerSheet(
        currentFolderItems: widget.items,
        onCreateNew: () async {
          Navigator.pop(context);
          await _navigateToCreateLink();
        },
      ),
    );

    if (picked != null) {
      for (final FolderItem item in picked) {
        widget.notifier.addItem(item);
      }
    }
  }

  Future<void> _handleAddDocument() async {
    final List<FolderItem>? picked = await showModalBottomSheet<List<FolderItem>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DocumentPickerSheet(
        currentFolderItems: widget.items,
      ),
    );

    if (picked != null) {
      for (final FolderItem item in picked) {
        widget.notifier.addItem(item);
      }
    }
  }

  Future<void> _navigateToCreateLink() async {
    try {
      final folder = widget.notifier.folder.value?.data;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => CreateLinkPage(
            hideAppBar: true,
            initialFolders: folder != null ? [folder] : null,
            onClose: () => Navigator.pop(context),
            onSaved: () {
              Navigator.pop(context);
            },
          ),
        ),
      );

      // Refresh after navigation completes
      await _refreshItems();
    } catch (e, stackTrace) {
      loggerGlobal.severe(
          "FolderItemsSection", "Error adding link", e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error adding link: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleDelete(String itemId) {
    if (itemId.isEmpty) return;
    widget.notifier.removeItem(itemId);
  }

  void _handleDeleteSelected() {
    if (_tableNotifier.stateManager == null) return;

    final checkedRows = _tableNotifier.stateManager!.checkedRows;
    if (checkedRows.isEmpty) return;

    // Extract item IDs from checked rows
    final itemIdsToRemove = checkedRows
        .map((row) => row.cells["item_id"]?.value as String?)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();

    if (itemIdsToRemove.isNotEmpty) {
      widget.notifier.removeItems(itemIdsToRemove);
      _tableNotifier.removeSelectedRows();
    }
  }

  List<TrinaColumn> _buildColumns() {
    return [
      TrinaColumn(
        title: "Type",
        field: "type",
        type: TrinaColumnType.text(),
        width: 100,
        enableRowChecked: true,
        renderer: (ctx) {
          final typeValue = (ctx.row.cells["type"]?.value as String?) ?? "";
          return TypeCell(type: typeValue);
        },
      ),
      TrinaColumn(
        title: "Title",
        field: "title",
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: "Actions",
        field: "actions",
        type: TrinaColumnType.text(),
        width: 100,
        renderer: (ctx) {
          final itemId = ctx.row.cells["item_id"]?.value as String?;
          if (itemId == null) return const SizedBox.shrink();
          return DeleteCell(
            itemId: itemId,
            onDelete: _handleDelete,
          );
        },
      ),
    ];
  }

  List<TrinaRow<dynamic>> _buildRows(List<FolderItem> items) {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final title = ItemSectionController.getTitleFromItem(item);

      return TrinaRow<dynamic>(
        key: ValueKey("item_row_$index"),
        cells: {
          "type": TrinaCell(value: item.type.name),
          "title": TrinaCell(value: title),
          "actions": TrinaCell(value: ""),
          "item_id": TrinaCell(value: item.id ?? ""),
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _tableNotifier,
      builder: (context, _) {
        final hasSelectedRows =
            _tableNotifier.stateManager?.checkedRows.isNotEmpty ?? false;

        // Clean composition with separated concerns
        return ItemSection(
          child: ItemSectionContent(
            controller: _controller,
            onAddLink: _handleAddLink,
            onAddDocument: _handleAddDocument,
            onDeleteSelected: _handleDeleteSelected,
            hasSelectedRows: hasSelectedRows,
            columns: _columns,
            buildRows: _buildRows,
            tableNotifier: _tableNotifier,
          ),
        );
      },
    );
  }
}

