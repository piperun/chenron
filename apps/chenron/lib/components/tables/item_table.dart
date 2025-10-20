import "package:flutter/material.dart";
import "package:trina_grid/trina_grid.dart";
import "package:chenron/notifiers/item_table_notifier.dart";

class DataGrid extends StatefulWidget {
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
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  @override
  Widget build(BuildContext context) {
    return TrinaGrid(
      columns: widget.columns,
      rows: widget.rows,
      onLoaded: (TrinaGridOnLoadedEvent event) {
        widget.notifier.setStateManager(event.stateManager);
      },
      onRowChecked: widget.notifier.onRowChecked,
      configuration: const TrinaGridConfiguration(
        columnSize: TrinaGridColumnSizeConfig(
          autoSizeMode: TrinaAutoSizeMode.scale,
        ),
      ),
    );
  }
}
