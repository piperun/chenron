import 'package:flutter/material.dart';

class FolderTable<T> extends StatefulWidget {
  final List<DataColumn> columns;
  final List<T> rowData;
  final List<DataCell> Function(T, [int]) buildCells;
  const FolderTable(
      {super.key,
      required this.columns,
      required this.rowData,
      required this.buildCells});

  @override
  State<FolderTable<T>> createState() => _FolderTableState<T>();
}

class _FolderTableState<T> extends State<FolderTable<T>> {
  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      header: const Text('Dynamic Data Table'),
      columns: widget.columns,
      source: _DataTableSource(
        widget.rowData,
        widget.buildCells,
      ),
      rowsPerPage: 5,
    );
  }
}

class _DataTableSource<T> extends DataTableSource {
  final List<T> rowData;
  final List<DataCell> Function(T) buildCells;

  _DataTableSource(this.rowData, this.buildCells);
  @override
  DataRow? getRow(int index) {
    if (index >= rowData.length) return null;

    final row = rowData[index];
    return DataRow(cells: buildCells(row));
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rowData.length;

  @override
  int get selectedRowCount => 0;
}
