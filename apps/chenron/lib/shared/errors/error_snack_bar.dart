import "package:flutter/material.dart";
import "package:chenron/shared/errors/user_error_message.dart";
import "package:chenron/shared/navigation/activity_log_request.dart";

/// Shows a themed error SnackBar with a user-friendly message.
///
/// Callers must check `mounted` before invoking this.
///
/// [showActivityLogAction] is opt-in because the Activity Log only records
/// background jobs (archiving, metadata fetches) — linking a generic error
/// (delete, export, ...) there would land the user in a log that does not
/// contain it. Only pass `true` from fetch/archive failure paths.
void showErrorSnackBar(
  BuildContext context,
  Object error, {
  bool showActivityLogAction = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(userErrorMessage(error)),
      backgroundColor: Theme.of(context).colorScheme.error,
      // Longer when there is an action: read + decide + click needs more
      // than the plain read does.
      duration: showActivityLogAction
          ? const Duration(seconds: 6)
          : const Duration(seconds: 4),
      action: showActivityLogAction
          ? SnackBarAction(
              label: "View Log",
              textColor: Theme.of(context).colorScheme.onError,
              onPressed: requestActivityLogOpen,
            )
          : null,
    ),
  );
}
