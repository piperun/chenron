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
