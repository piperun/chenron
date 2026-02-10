import "dart:async";

import "package:app_logger/app_logger.dart";
import "package:database/database.dart";

/// App-level service for recording view/access activity events.
///
/// Create, delete, and edit events are handled automatically by SQLite triggers
/// (see AppDatabase._createActivityTriggers). This service only handles "viewed"
/// events and recent access tracking, which can't be captured by triggers since
/// viewing doesn't modify any database table.
class ActivityTracker {
  final AppDatabase _db;

  ActivityTracker(this._db);

  void trackLinkViewed(String linkId) {
    _record(_db.recordActivity(
      eventType: "link_viewed",
      entityType: "link",
      entityId: linkId,
    ));
    _record(_db.recordItemAccess(entityId: linkId, entityType: "link"));
  }

  void trackDocumentViewed(String docId) {
    _record(_db.recordActivity(
      eventType: "document_viewed",
      entityType: "document",
      entityId: docId,
    ));
    _record(_db.recordItemAccess(entityId: docId, entityType: "document"));
  }

  void trackFolderViewed(String folderId) {
    _record(_db.recordActivity(
      eventType: "folder_viewed",
      entityType: "folder",
      entityId: folderId,
    ));
    _record(_db.recordItemAccess(entityId: folderId, entityType: "folder"));
  }

  void _record(Future<void> future) {
    unawaited(future.catchError((Object error) {
      loggerGlobal.warning(
          "ActivityTracker", "Failed to record activity: $error");
    }));
  }
}
