import "package:app_logger/app_logger.dart";

/// Executes [action] with info-level logging before and after.
/// On error, logs at severe level and rethrows.
Future<T> runLogged<T>({
  required String tag,
  required String operation,
  required Future<T> Function() action,
}) async {
  loggerGlobal.info(tag, "$operation...");
  try {
    final result = await action();
    loggerGlobal.info(tag, "$operation done");
    return result;
  } catch (e, s) {
    loggerGlobal.severe(tag, "Error: $operation", e, s);
    rethrow;
  }
}

/// Executes [action] with info-level logging before and after.
/// On error, logs at severe level and returns [fallback].
Future<T> runLoggedOr<T>({
  required String tag,
  required String operation,
  required Future<T> Function() action,
  required T fallback,
}) async {
  loggerGlobal.info(tag, "$operation...");
  try {
    final result = await action();
    loggerGlobal.info(tag, "$operation done");
    return result;
  } catch (e, s) {
    loggerGlobal.severe(tag, "Error: $operation", e, s);
    return fallback;
  }
}
