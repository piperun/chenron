import "package:drift/drift.dart";

/// Canonical SQL default for every `DateTime` column: UTC ISO-8601 at
/// millisecond precision (`YYYY-MM-DDTHH:MM:SS.fffZ`).
///
/// SQLite's `CURRENT_TIMESTAMP` (Drift's `currentDateAndTime`) writes a
/// space-separated, whole-second string (`YYYY-MM-DD HH:MM:SS`), which mixes
/// two text shapes in one column and breaks plain `col >= ?` range scans. This
/// direct `strftime('%Y-%m-%dT%H:%M:%fZ', 'now')` produces the same canonical
/// shape the update triggers and [dbNow] use, so the date indexes engage and
/// no `datetime()` wrapping is needed at query time.
const tsDefault =
    CustomExpression<DateTime>("strftime('%Y-%m-%dT%H:%M:%fZ', 'now')");

/// The current instant in UTC, truncated to milliseconds, for writing
/// timestamps to the database.
///
/// Every `DateTime` column stores UTC; display code converts to the device's
/// local zone. Writing with this — rather than `DateTime.now()`, which carries
/// the local offset — keeps app-written timestamps identical in shape to the
/// ones the SQL triggers write (`strftime('%Y-%m-%dT%H:%M:%fZ', 'now')`, also
/// UTC at millisecond precision), so a column never mixes `…+02:00` and `…Z`
/// text.
DateTime dbNow() {
  final now = DateTime.now().toUtc();
  return DateTime.utc(now.year, now.month, now.day, now.hour, now.minute,
      now.second, now.millisecond);
}

/// Normalizes a [DateTime] into the exact shape stored in the database — UTC,
/// truncated to milliseconds — so it can be used as a range-query bound.
///
/// Timestamp columns store canonical UTC ISO-8601 millisecond text. Plain
/// `col >= ?` comparisons are lexicographic on that text, which is only
/// correct when the bound has the identical shape. Drift serializes a UTC,
/// millisecond-precision `DateTime` via `toIso8601String()` to exactly
/// `YYYY-MM-DDTHH:MM:SS.fffZ`; a *local* `DateTime` would instead serialize
/// with a ` +HH:MM` offset (and microseconds), which sorts incorrectly
/// against the stored `…Z` text. Always wrap a bound with this before binding
/// it to a timestamp comparison.
DateTime dbBound(DateTime value) {
  final utc = value.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day, utc.hour, utc.minute,
      utc.second, utc.millisecond);
}
