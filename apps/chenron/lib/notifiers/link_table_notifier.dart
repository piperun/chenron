import "package:chenron/models/item.dart";
import "package:flutter/material.dart";
import "package:trina_grid/trina_grid.dart";

class DataGridNotifier extends ChangeNotifier {
  TrinaGridStateManager? _stateManager;

  TrinaGridStateManager? get stateManager => _stateManager;

  bool checkedRows = false;

  void setStateManager(TrinaGridStateManager stateManager) {
    _stateManager = stateManager;
    notifyListeners();
  }

  void onRowChecked(TrinaGridOnRowCheckedEvent event) {
    checkedRows = event.isChecked!;
    notifyListeners();
  }

  void appendRow(TrinaRow row, {String? key}) {
    if (_stateManager != null) {
      final String? newUrl = row.cells[key]?.value;

      final bool isDuplicate = _stateManager!.rows.any((existingRow) {
        final String? existingUrl = existingRow.cells[key]?.value;
        return existingUrl == newUrl;
      });

      if (!isDuplicate) {
        _stateManager!.appendRows([row]);
        notifyListeners();
      }
    }
  }

  void removeSelectedRows() {
    if (_stateManager == null) return;
    final selectedRows = _stateManager!.checkedRows;
    _stateManager!.removeRows(selectedRows);
    notifyListeners();
  }

  List<TrinaRow> getRows(List<FolderItem> items) {
    return items.map((link) {
      if (link.path is StringContent) {
        // Handling StringContent
        final content = link.path as StringContent;
        return TrinaRow(
          key: link.key,
          cells: {
            "url": TrinaCell(value: content.value),
            "comment": TrinaCell(value: ""),
            "tags": TrinaCell(value: []),
          },
        );
      } else if (link.path is MapContent) {
        final content = link.path as MapContent;
        final mapValue = content.value;
        return TrinaRow(
          key: link.key,
          cells: {
            "url": TrinaCell(value: mapValue["url"] ?? ""),
            "comment": TrinaCell(value: mapValue["comment"] ?? ""),
            "tags": TrinaCell(value: mapValue["tags"] ?? []),
          },
        );
      } else {
        return TrinaRow(
          key: link.key,
          cells: {
            "url": TrinaCell(value: ""),
            "comment": TrinaCell(value: ""),
            "tags": TrinaCell(value: []),
          },
        );
      }
    }).toList();
  }
}
