import "package:database/models/item.dart";
import "package:flutter/material.dart";
import "package:signals/signals.dart";
import "package:trina_grid/trina_grid.dart";

/// Generic notifier for managing table state and interactions
///
/// This notifier handles state management for any type of table (links, documents, etc.)
/// and provides a bridge between the UI and the TrinaGrid state manager.
class ItemTableNotifier<T> {
  TrinaGridStateManager? _stateManager;

  TrinaGridStateManager? get stateManager => _stateManager;

  final Signal<bool> hasCheckedRows = signal(false);

  void setStateManager(TrinaGridStateManager stateManager) {
    _stateManager = stateManager;
  }

  void onRowChecked(TrinaGridOnRowCheckedEvent event) {
    hasCheckedRows.value = event.isChecked!;
  }

  void appendRow(TrinaRow<dynamic> row, {String? key}) {
    if (_stateManager != null) {
      final String? newUrl = row.cells[key]?.value as String?;

      final bool isDuplicate = _stateManager!.rows.any((existingRow) {
        final String? existingUrl = existingRow.cells[key]?.value as String?;
        return existingUrl == newUrl;
      });

      if (!isDuplicate) {
        _stateManager!.appendRows([row]);
      }
    }
  }

  void removeSelectedRows() {
    if (_stateManager == null) return;
    final selectedRows = _stateManager!.checkedRows;
    _stateManager!.removeRows(selectedRows);
    hasCheckedRows.value = false;
  }

  void dispose() {
    hasCheckedRows.dispose();
  }

  List<TrinaRow<dynamic>> getRows(List<FolderItem> items) {
    return items.map((item) {
      return item.map(
        link: (linkItem) => TrinaRow<dynamic>(
          key: ValueKey(linkItem.itemId ?? linkItem.id ?? ""),
          cells: {
            "url": TrinaCell(value: linkItem.url),
            "comment": TrinaCell(value: ""),
            "tags": TrinaCell(value: linkItem.tags),
          },
        ),
        document: (docItem) => TrinaRow<dynamic>(
          key: ValueKey(docItem.itemId ?? docItem.id ?? ""),
          cells: {
            "url": TrinaCell(value: docItem.filePath),
            "comment": TrinaCell(value: docItem.title),
            "tags": TrinaCell(value: docItem.tags),
          },
        ),
        folder: (folderItem) => TrinaRow<dynamic>(
          key: ValueKey(folderItem.itemId ?? folderItem.id ?? ""),
          cells: {
            "url": TrinaCell(value: folderItem.folderId),
            "comment": TrinaCell(value: ""),
            "tags": TrinaCell(value: folderItem.tags),
          },
        ),
      );
    }).toList();
  }
}
