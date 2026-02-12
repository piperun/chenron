import "dart:io";

import "package:drift/drift.dart";
import "package:sqlite3/sqlite3.dart";

/// Translates an exception into a user-friendly message.
///
/// Logs should still capture the raw exception for debugging — this
/// function only produces the string shown in SnackBars and UI text.
String userErrorMessage(Object error) {
  if (error is DriftWrappedException && error.cause != null) {
    return userErrorMessage(error.cause!);
  }

  if (error is SqliteException) {
    return _sqliteMessage(error);
  }

  if (error is FileSystemException) {
    return "File operation failed: ${error.message}";
  }

  if (error is ArgumentError) {
    final msg = error.message;
    if (msg is String && msg.isNotEmpty) return msg;
    return "Invalid input.";
  }

  return "Something went wrong. Please try again.";
}

String _sqliteMessage(SqliteException e) {
  // Extended result codes: https://sqlite.org/rescode.html
  return switch (e.extendedResultCode) {
    // SQLITE_CONSTRAINT_UNIQUE (2067) and SQLITE_CONSTRAINT_PRIMARYKEY (1555)
    2067 || 1555 => "This item already exists.",
    // SQLITE_CONSTRAINT_FOREIGNKEY (787)
    787 => "Cannot complete — a related item is missing or was removed.",
    // SQLITE_CONSTRAINT_NOTNULL (1299)
    1299 => "A required field is empty.",
    // SQLITE_BUSY (5) / SQLITE_LOCKED (6)
    5 || 6 => "Database is busy. Please try again.",
    // SQLITE_READONLY (8)
    8 => "Database is read-only.",
    // SQLITE_FULL (13)
    13 => "Disk is full.",
    // SQLITE_CORRUPT (11)
    11 => "Database file appears damaged. Try restoring from a backup.",
    // Fallback for any other code
    _ => "A database error occurred. Please try again.",
  };
}
