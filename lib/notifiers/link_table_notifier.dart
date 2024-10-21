import "package:chenron/models/item.dart";
import "package:flutter/material.dart";
import "package:pluto_grid/pluto_grid.dart";

class DataTableNotifier extends ChangeNotifier {
  PlutoGridStateManager? _stateManager;

  PlutoGridStateManager? get stateManager => _stateManager;

  void setStateManager(PlutoGridStateManager stateManager) {
    _stateManager = stateManager;
    notifyListeners();
  }

  void appendRow(PlutoRow row, {String? key}) {
    if (_stateManager != null) {
      String? newUrl = row.cells[key]?.value;

      bool isDuplicate = _stateManager!.rows.any((existingRow) {
        String? existingUrl = existingRow.cells[key]?.value;
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

  List<PlutoRow> getRows(List<FolderItem> items) {
    return items.map((link) {
      if (link.content is StringContent) {
        // Handling StringContent
        final content = link.content as StringContent;
        return PlutoRow(
          key: link.key,
          cells: {
            "url": PlutoCell(value: content.value),
            "comment": PlutoCell(value: ""),
            "tags": PlutoCell(value: []),
          },
        );
      } else if (link.content is MapContent) {
        final content = link.content as MapContent;
        final mapValue = content.value;
        return PlutoRow(
          key: link.key,
          cells: {
            "url": PlutoCell(value: mapValue["url"] ?? ""),
            "comment": PlutoCell(value: mapValue["comment"] ?? ""),
            "tags": PlutoCell(value: mapValue["tags"] ?? []),
          },
        );
      } else {
        return PlutoRow(
          key: link.key,
          cells: {
            "url": PlutoCell(value: ""),
            "comment": PlutoCell(value: ""),
            "tags": PlutoCell(value: []),
          },
        );
      }
    }).toList();
  }
}
