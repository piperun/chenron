import "package:chenron/components/tables/link_table.dart";
import "package:chenron/notifiers/link_table_notifier.dart";
import "package:flutter/material.dart";
import "package:pluto_grid/pluto_grid.dart";
import "package:intl/intl.dart";
import "package:chenron/models/cud.dart";
import "package:chenron/models/item.dart";

import "package:chenron/components/table/link_toolbar.dart";

class ItemEditor extends StatefulWidget {
  final List<FolderItem> initialItems;
  final Function(CUD<FolderItem>) onUpdate;

  const ItemEditor({
    super.key,
    required this.initialItems,
    required this.onUpdate,
  });

  @override
  State<ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends State<ItemEditor> {
  final DataGridNotifier _notifier = DataGridNotifier();
  CUD<FolderItem> folderItems = CUD<FolderItem>();

  final List<PlutoColumn> columns = [
    PlutoColumn(
      title: "Content",
      field: "content",
      type: PlutoColumnType.text(),
      enableRowChecked: true,
    ),
    PlutoColumn(
      title: "Type",
      field: "type",
      type: PlutoColumnType.text(),
      enableEditingMode: false,
    ),
    PlutoColumn(
      title: "Added",
      field: "createdAt",
      type: PlutoColumnType.text(),
      enableEditingMode: false,
    ),
  ];

  List<PlutoRow> _loadRows() {
    return widget.initialItems.map((item) {
      final String createdAtStr = item.createdAt != null
          ? DateFormat("yyyy-MM-dd HH:mm:ss").format(item.createdAt!)
          : "";
      return PlutoRow(
        cells: {
          "id": PlutoCell(value: item.id),
          "content": PlutoCell(value: item.content.value),
          "type": PlutoCell(value: item.type.toString().split(".").last),
          "createdAt": PlutoCell(value: createdAtStr),
        },
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, child) => Column(
        children: [
          LinkToolbar(
            onDelete: _notifier.checkedRows ? _deleteSelected : null,
          ),
          SizedBox(
              height: 500,
              child: DataGrid(
                  columns: columns, rows: _loadRows(), notifier: _notifier)),
        ],
      ),
    );
  }

  void _deleteSelected() async {
    final selectedRows = _notifier.stateManager?.checkedRows ?? [];
    for (final row in selectedRows) {
      String id = row.cells["id"]!.value;
      if (id.isNotEmpty) {
        folderItems.remove.add(id);
      } else {
        folderItems.create
            .where((item) => !selectedRows.any((row) => item.key == row.key))
            .toList();
      }

      _notifier.removeSelectedRows();
      _notifier.checkedRows = false;
      widget.onUpdate(folderItems);
    }
  }
}
