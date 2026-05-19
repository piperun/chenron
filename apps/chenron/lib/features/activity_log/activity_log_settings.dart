import "package:shared_preferences/shared_preferences.dart";

/// Persisted TTL for the background_jobs activity log.
///
/// Stored as hours in [SharedPreferences]; `0` means "permanent — never
/// purge." Defaults to 24h: matches the "nothing should be permanent"
/// expectation while still letting users skim yesterday's archive
/// failures.
class ActivityLogSettings {
  static const _ttlHoursKey = "activity_log_ttl_hours";
  static const defaultTtlHours = 24;

  /// Returns the configured TTL as a [Duration], or `null` for
  /// permanent retention (no purge).
  static Future<Duration?> getTtl() async {
    final prefs = await SharedPreferences.getInstance();
    final hours = prefs.getInt(_ttlHoursKey) ?? defaultTtlHours;
    if (hours <= 0) return null;
    return Duration(hours: hours);
  }

  /// Persist a new TTL. Pass `null` (or a non-positive [Duration]) to
  /// disable purging entirely.
  static Future<void> setTtl(Duration? ttl) async {
    final prefs = await SharedPreferences.getInstance();
    final hours = ttl == null || ttl.inHours <= 0 ? 0 : ttl.inHours;
    await prefs.setInt(_ttlHoursKey, hours);
  }
}
