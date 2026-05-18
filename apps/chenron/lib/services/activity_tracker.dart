import "dart:async";

import "package:app_logger/app_logger.dart";
import "package:database/database.dart";
import "package:database/features.dart";

/// App-level service for recording view/access activity events.
///
/// Create, delete, and edit events are handled automatically by SQLite triggers
/// (see AppDatabase._createActivityTriggers). This service only handles "viewed"
/// events and recent access tracking, which can't be captured by triggers since
/// viewing doesn't modify any database table.
class ActivityTracker {
  final AppDatabase _db;

  ActivityTracker(this._db);

  void trackLinkViewed(String linkId) =>
      _trackView(eventType: "link_viewed", entityType: "link", entityId: linkId);

  void trackDocumentViewed(String docId) => _trackView(
      eventType: "document_viewed",
      entityType: "document",
      entityId: docId);

  void trackFolderViewed(String folderId) => _trackView(
      eventType: "folder_viewed",
      entityType: "folder",
      entityId: folderId);

  /// Records both the activity event and the recent-access bump for a
  /// single view in one transaction. Previously each view fired two
  /// independent DB writes — fine in isolation but doubles the per-view
  /// fsync count on a hot path (item taps).
  void _trackView({
    required String eventType,
    required String entityType,
    required String entityId,
  }) {
    unawaited(_db.transaction(() async {
      await _db.recordActivity(
        eventType: eventType,
        entityType: entityType,
        entityId: entityId,
      );
      await _db.recordItemAccess(entityId: entityId, entityType: entityType);
    }).catchError((Object error) {
      loggerGlobal.warning(
          "ActivityTracker", "Failed to record activity: $error");
    }));
  }
}
