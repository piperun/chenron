import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class FolderTable<T> extends StatefulWidget {
  final List<PlutoRow> rows;
  final List<PlutoColumn> columns;
  late PlutoGridStateManager stateManager;
  FolderTable(
      {super.key,
      required this.columns,
      required this.rows,
      required this.stateManager});

  @override
  State<FolderTable> createState() => _FolderTableState<T>();
}

class _FolderTableState<T> extends State<FolderTable> {
  // ignore: unused_field
  late PlutoGridStateManager _stateManager;
  @override
  void initState() {
    super.initState();
    _stateManager = widget.stateManager;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500, // Adjust as needed
      child: PlutoGrid(
        columns: widget.columns,
        rows: widget.rows,
        onLoaded: (PlutoGridOnLoadedEvent event) {
          _stateManager = event.stateManager;
        },
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.scale,
          ),
        ),
      ),
    );
  }
}
