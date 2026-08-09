import "package:cache_manager/src/metadata_fetch_result.dart";

/// Persistent retry bookkeeping for metadata refresh attempts.
class MetadataRefreshRecord {
  final String url;
  final DateTime lastAttemptAt;
  final MetadataFailureKind? lastFailureKind;
  final int? lastStatusCode;
  final int consecutiveFailures;
  final DateTime? nextRetryAt;

  const MetadataRefreshRecord({
    required this.url,
    required this.lastAttemptAt,
    this.lastFailureKind,
    this.lastStatusCode,
    required this.consecutiveFailures,
    this.nextRetryAt,
  });
}

/// Storage boundary for retry bookkeeping independent of metadata snapshots.
abstract class MetadataRefreshPersistence {
  Future<MetadataRefreshRecord?> getRefreshRecord(String url);
  Future<void> setRefreshRecord(MetadataRefreshRecord record);
  Future<void> removeRefreshRecord(String url);
  Future<void> clearAllRefreshRecords();
}
