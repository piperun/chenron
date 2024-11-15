import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:chenron/notifiers/link_table_notifier.dart';

class DataGrid extends StatefulWidget {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final DataGridNotifier notifier;

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
    return PlutoGrid(
      columns: widget.columns,
      rows: widget.rows,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        widget.notifier.setStateManager(event.stateManager);
      },
      onRowChecked: widget.notifier.onRowChecked,
      configuration: const PlutoGridConfiguration(
        columnSize: PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.scale,
        ),
      ),
    );
  }
}
