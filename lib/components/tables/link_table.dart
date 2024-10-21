import "package:flutter/material.dart";
import "package:pluto_grid/pluto_grid.dart";
import "package:chenron/notifiers/link_table_notifier.dart";

class FolderDataTable extends StatefulWidget {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final DataTableNotifier notifier;

  const FolderDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.notifier,
  });

  @override
  State<FolderDataTable> createState() => _FolderDataTableState();
}

class _FolderDataTableState extends State<FolderDataTable> {
  @override
  Widget build(BuildContext context) {
    return PlutoGrid(
      columns: widget.columns,
      rows: widget.rows,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        widget.notifier.setStateManager(event.stateManager);
      },
      configuration: const PlutoGridConfiguration(
        columnSize: PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.scale,
        ),
      ),
    );
  }
}
