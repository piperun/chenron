import "dart:async";

import "package:app_logger/app_logger.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";
import "package:flutter/widgets.dart";

/// Subscribe to [source] with mandatory logging on error.
///
/// Drift `.watch(...)` streams (and friends) too often go out as
/// `.listen(onData)` with no `onError` — when the underlying query
/// errors, the failure becomes an uncaught zone error and the UI
/// quietly stops updating. This wrapper makes the failure path
/// explicit: every error is logged through [loggerGlobal] under [tag],
/// and an optional [onUiError] callback fires so the State can flip
/// itself into an error/empty mode.
///
/// Returns the underlying [StreamSubscription] so callers retain full
/// control (cancel, pause, etc.).
StreamSubscription<T> safeWatch<T>(
  Stream<T> source, {
  required String tag,
  required void Function(T data) onData,
  void Function(Object error)? onUiError,
}) {
  return source.listen(
    onData,
    onError: (Object error, StackTrace stack) {
      loggerGlobal.severe(tag, "stream error", error, stack);
      onUiError?.call(error);
    },
  );
}

/// State-side `await` wrapper that bundles the three things every
/// async DB call into the UI should do: log on failure, surface a
/// user-friendly snackbar, and respect `mounted` before touching the
/// `BuildContext`.
///
/// Returns the action's result on success or `null` on failure — the
/// caller can early-return when `null` arrives, or fall back to a
/// safe value (`?? const []`, `?? const {}`).
///
/// ```dart
/// final tags = await safeAwait<List<Tag>>(
///   tag: "BulkTagDialog",
///   operation: "load tags",
///   action: () => db.getAllTags(),
/// );
/// if (tags == null) return;
/// setState(() => _tags = tags);
/// ```
///
/// When [showSnackBarOnError] is false (default true), the snackbar
/// step is skipped — useful when the caller wants to render an inline
/// error state instead. The log call always happens.
extension SafeAwaitState<W extends StatefulWidget> on State<W> {
  Future<T?> safeAwait<T>({
    required String tag,
    required String operation,
    required Future<T> Function() action,
    bool showSnackBarOnError = true,
  }) async {
    try {
      loggerGlobal.info(tag, "$operation...");
      final result = await action();
      loggerGlobal.info(tag, "$operation done");
      return result;
    } catch (e, s) {
      loggerGlobal.severe(tag, "$operation failed", e, s);
      if (showSnackBarOnError && mounted) {
        showErrorSnackBar(context, e);
      }
      return null;
    }
  }
}
