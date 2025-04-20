import "package:chenron/models/status.dart";
import "package:chenron/utils/logger.dart";

/// Base sealed class for database operations
sealed class DbOperation<T> {
  Future<T> perform() async {
    try {
      validate();
      await execute();
      await process();
      return await result();
    } catch (e) {
      loggerGlobal.severe("Error in operation: $e", e);
      rethrow;
    }
  }

  /// Validates input data before performing operation
  Status<T> validate();

  /// Performs the core database operation
  Future<void> execute();

  /// Processes related entities (tags, items, etc.)
  Future<void> process();

  /// Returns the operation result
  Future<T> result();
}

// Possible implementations would be sealed within this hierarchy:
// final class CreateFolderOperation extends EntityOperation<FolderResultIds> {...}
// final class UpdateFolderOperation extends EntityOperation<FolderResultIds> {...}
