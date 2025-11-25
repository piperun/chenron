import "package:flutter/material.dart";
import "package:trina_grid/trina_grid.dart";
import "package:chenron/notifiers/item_table_notifier.dart";

class DataGrid extends StatelessWidget {
  final List<TrinaColumn> columns;
  final List<TrinaRow> rows;
  final ItemTableNotifier notifier;

  const DataGrid({
    super.key,
    required this.columns,
    required this.rows,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return TrinaGrid(
      columns: columns,
      rows: rows,
      onLoaded: (TrinaGridOnLoadedEvent event) {
        notifier.setStateManager(event.stateManager);
      },
      onRowChecked: notifier.onRowChecked,
      configuration: const TrinaGridConfiguration(
        columnSize: TrinaGridColumnSizeConfig(
          autoSizeMode: TrinaAutoSizeMode.scale,
        ),
      ),
    );
  }
}

