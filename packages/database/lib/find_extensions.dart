import "package:drift/drift.dart";

extension FindExtensions<Table extends HasResultSet, Row>
    on ResultSetImplementation<Table, Row> {
  Selectable<Row> findById(String id) {
    return select()
      ..where((row) {
        final idColumn = columnsByName["id"];

        if (idColumn == null) {
          throw ArgumentError.value(
              this, "this", "Must be a table with an id column");
        }

        if (idColumn.type != DriftSqlType.string) {
          throw ArgumentError("Column `id` is not an string");
        }

        return idColumn.equals(id);
      });
  }

  Selectable<Row> findByName(String columnName, dynamic value) {
    return select()
      ..where((row) {
        final formattedColumnName = columnName.replaceAllMapped(
          RegExp(r"[A-Z]"),
          (match) => "_${match.group(0)!.toLowerCase()}",
        );
        final column = columnsByName[formattedColumnName];

        if (column == null) {
          throw ArgumentError.value(
              this, "this", "Must be a table with a $columnName column");
        }

        if (column.type != DriftSqlType.string) {
          throw ArgumentError("Column $columnName is not a string");
        }

        return column.equalsNullable(value);
      });
  }
}
