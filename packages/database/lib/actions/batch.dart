import "package:logger/logger.dart";
import "package:drift/drift.dart"
    show TableInfo, Insertable, InsertMode, DoNothing, Expression, Table;
import "package:database/database.dart" show AppDatabase;

extension BatchExtensions on AppDatabase {
  Future<void> batchOps(
      Future<void> Function(BatchOperations batch) operations) {
    return transaction(() async {
      final batch = BatchOperations(this);
      await operations(batch);
    });
  }
}

class BatchOperations {
  final AppDatabase _db;

  BatchOperations(this._db);

  Future<void> insertIterBatch(
      Iterable<(TableInfo, Insertable)> tableRowPairs) async {
    try {
      await _db.batch((batch) async {
        for (final (table, row) in tableRowPairs) {
          batch.insert(table, row,
              mode: InsertMode.insertOrIgnore, onConflict: DoNothing());
        }
      });
      loggerGlobal.info(
          "BatchOperationInsertIter", "Batch insert completed successfully");
    } catch (e) {
      loggerGlobal.info(
          "BatchOperationInsertIter", "Error during batch insert: $e");
      rethrow;
    }
  }

  Future<void> insertAllBatch(
      TableInfo table, Iterable<Insertable> rows) async {
    if (rows.isEmpty) return;
    try {
      await _db.batch((batch) async {
        batch.insertAll(
          table,
          rows,
          onConflict: DoNothing(),
          mode: InsertMode.insertOrIgnore,
        );
      });
      loggerGlobal.info(
          "BatchOperationInsertAll", "Batch insert completed successfully");
    } catch (e) {
      loggerGlobal.info(
          "BatchOperationInsertAll", "Error during batch insert: $e");
      rethrow;
    }
  }

  Future<void> updateBatch(TableInfo table, List<Insertable> rows,
      Expression<bool> Function(Table) where) async {
    if (rows.isEmpty) return;
    try {
      await _db.batch((batch) async {
        for (final row in rows) {
          batch.update(table, row, where: where);
        }
      });
      loggerGlobal.info(
          "BatchOperationUpdate", "Batch update completed successfully");
    } catch (e) {
      loggerGlobal.info(
          "BatchOperationUpdate", "Error during batch update: $e");
      rethrow;
    }
  }

  Future<void> deleteBatch(TableInfo table, Iterable<Insertable> rows) async {
    if (rows.isEmpty) return;
    try {
      await _db.batch((batch) async {
        for (final row in rows) {
          batch.delete(table, row);
        }
      });
      loggerGlobal.info(
          "BatchOperationDelete", "Batch delete completed successfully");
    } catch (e) {
      loggerGlobal.info(
          "BatchOperationDelete", "Error during batch delete: $e");
      rethrow;
    }
  }

  Future<void> deleteIterBatch(
      Iterable<(TableInfo, Insertable)> tableRowPairs) async {
    if (tableRowPairs.isEmpty) return;
    try {
      await _db.batch((batch) async {
        for (final (table, row) in tableRowPairs) {
          batch.delete(table, row);
        }
      });
      loggerGlobal.info(
          "BatchOperationDeleteIter", "Batch delete completed successfully");
    } catch (e) {
      loggerGlobal.info(
          "BatchOperationDeleteIter", "Error during batch delete: $e");
      rethrow;
    }
  }
}


