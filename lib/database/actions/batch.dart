import 'package:drift/drift.dart';
import 'package:chenron/database/database.dart';
import 'package:logging/logging.dart';

extension BatchExtensions on AppDatabase {
  static final Logger _logger = Logger('Folder Actions Database');
  Future<void> batchOps(
      Future<void> Function(BatchOperations batch) operations) {
    return transaction(() async {
      final batch = BatchOperations(this, _logger);
      await operations(batch);
    });
  }
}

class BatchOperations {
  final Logger _logger;
  final AppDatabase _db;

  BatchOperations(this._db, this._logger);

  Future<void> insertIterBatch(
      Iterable<(TableInfo, Insertable)> tableRowPairs) async {
    try {
      await _db.batch((batch) async {
        for (final (table, row) in tableRowPairs) {
          batch.insert(table, row,
              mode: InsertMode.insertOrIgnore, onConflict: DoNothing());
        }
      });
      _logger.info('Batch insert completed successfully');
    } catch (e) {
      _logger.severe('Error during batch insert: $e');
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
      _logger.info('Batch insert completed successfully');
    } catch (e) {
      _logger.severe('Error during batch insert: $e');
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
      _logger.info('Batch update completed successfully');
    } catch (e) {
      _logger.severe('Error during batch update: $e');
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
      _logger.info('Batch delete completed successfully');
    } catch (e) {
      _logger.severe('Error during batch delete: $e');
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
      _logger.info('Batch delete completed successfully');
    } catch (e) {
      _logger.severe('Error during batch delete: $e');
      rethrow;
    }
  }
}
