import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/components/tables/item_table.dart";
import "package:chenron/notifiers/item_table_notifier.dart";
import "package:chenron/features/create/link/pages/create_link.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/database/database.dart";
import "package:chenron/locator.dart";
import "package:signals/signals.dart";
import "package:trina_grid/trina_grid.dart";
import "package:chenron/components/tables/renderers/shared/actions_renderer.dart";

/// Widget for displaying and managing folder items in the editor
class FolderItemsSection extends StatefulWidget {
  final String folderId;
  final List<FolderItem> items;
  final ValueChanged<List<FolderItem>> onItemsChanged;

  const FolderItemsSection({
    super.key,
    required this.folderId,
    required this.items,
    required this.onItemsChanged,
  });

  @override
  State<FolderItemsSection> createState() => _FolderItemsSectionState();
}

class _FolderItemsSectionState extends State<FolderItemsSection> {
  late final ItemTableNotifier _tableNotifier;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tableNotifier = ItemTableNotifier();
  }

  @override
  void dispose() {
    _tableNotifier.dispose();
    super.dispose();
  }

  Future<void> _refreshItems() async {
    try {
      final dbHandler = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
      final folderResult = await dbHandler.appDatabase.getFolder(
        folderId: widget.folderId,
        includeOptions: const IncludeOptions({AppDataInclude.items}),
      );

      if (folderResult != null && mounted) {
        widget.onItemsChanged(folderResult.items);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to refresh items: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAddLink() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateLinkPage(
          hideAppBar: true,
          onClose: () => Navigator.pop(context),
          onSaved: () async {
            Navigator.pop(context);
            await _refreshItems();
          },
        ),
      ),
    );
  }

  void _handleAddDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Document creation not yet implemented"),
      ),
    );
  }

  void _handleDelete(Key key) {
    final updatedItems = widget.items.where((i) => i.key != key).toList();
    widget.onItemsChanged(updatedItems);
  }

  void _handleDeleteSelected() {
    if (_tableNotifier.stateManager == null) return;

    final checkedRows = _tableNotifier.stateManager!.checkedRows;
    if (checkedRows.isEmpty) return;

    // Get keys from checked rows
    final keysToRemove = checkedRows
        .map((row) => row.key)
        .whereType<Key>()
        .toSet();

    // Remove items from the list
    final updatedItems = widget.items
        .where((item) => !keysToRemove.contains(item.key))
        .toList();

    widget.onItemsChanged(updatedItems);
    _tableNotifier.removeSelectedRows();
  }

  List<TrinaColumn> _buildColumns(ThemeData theme) {
    return [
      TrinaColumn(
        title: "Type",
        field: "type",
        type: TrinaColumnType.text(),
        width: 100,
        enableRowChecked: true,
        renderer: (rendererContext) {
          final typeValue = rendererContext.row.cells["type"]?.value as String?;
          if (typeValue == null) return const SizedBox.shrink();
          return _buildTypeIconFromString(typeValue, theme);
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
        renderer: (rendererContext) {
          final itemId = rendererContext.row.cells["item_id"]?.value as String?;
          if (itemId == null) return const SizedBox.shrink();
          
          return IconButton(
            icon: Icon(
              Icons.delete,
              size: 18,
              color: theme.colorScheme.error,
            ),
            onPressed: () {
              final item = widget.items.firstWhere((i) => i.id == itemId);
              _handleDelete(item.key ?? ValueKey(itemId));
            },
            tooltip: "Delete",
          );
        },
      ),
    ];
  }

  Widget _buildTypeIconFromString(String typeValue, ThemeData theme) {
    IconData icon;
    Color color;
    String label;

    switch (typeValue) {
      case "link":
        icon = Icons.link;
        color = Colors.blue;
        label = "Link";
        break;
      case "document":
        icon = Icons.description;
        color = Colors.green;
        label = "Doc";
        break;
      case "folder":
        icon = Icons.folder;
        color = Colors.orange;
        label = "Folder";
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
        label = typeValue;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }


  List<TrinaRow> _buildRows() {
    final filteredItems = _searchQuery.isEmpty
        ? widget.items
        : widget.items.where((item) {
            final title = _getTitleFromItem(item).toLowerCase();
            return title.contains(_searchQuery.toLowerCase());
          }).toList();

    return filteredItems.map((item) {
      final title = _getTitleFromItem(item);

      return TrinaRow(
        key: item.key ?? ValueKey(item.id ?? title),
        cells: {
          "type": TrinaCell(value: item.type.name),
          "title": TrinaCell(value: title),
          "actions": TrinaCell(value: ""),
          "item_id": TrinaCell(value: item.id ?? ""),
        },
      );
    }).toList();
  }

  String _getTitleFromItem(FolderItem item) {
    if (item.path is StringContent) {
      return (item.path as StringContent).value;
    } else if (item.path is MapContent) {
      final mapValue = (item.path as MapContent).value;
      return mapValue["title"] ?? mapValue["body"] ?? "";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _tableNotifier,
      builder: (context, _) {
        final hasSelectedRows = _tableNotifier.stateManager?.checkedRows.isNotEmpty ?? false;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Folder Items (${widget.items.length})",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.link),
                      onPressed: _handleAddLink,
                      tooltip: "Add Link",
                    ),
                    IconButton(
                      icon: const Icon(Icons.note_add),
                      onPressed: _handleAddDocument,
                      tooltip: "Add Document",
                    ),
                    TextButton.icon(
                      onPressed: hasSelectedRows ? _handleDeleteSelected : null,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text("Delete Selected"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.items.isNotEmpty)
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search items...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _searchQuery = ""),
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                if (widget.items.isNotEmpty)
                  const SizedBox(height: 12),
                if (widget.items.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        "No items in this folder",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 300,
                    child: DataGrid(
                      key: ValueKey(widget.items.map((i) => i.id).join("|")),
                      columns: _buildColumns(theme),
                      rows: _buildRows(),
                      notifier: _tableNotifier,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
