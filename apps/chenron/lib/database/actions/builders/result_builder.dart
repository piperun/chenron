import "package:drift/drift.dart";
import "package:chenron/models/db_result.dart";

/// Base interface for result builders
abstract class ResultBuilder<T extends DbResult> {
  /// Process a database row, extracting relevant data
  void processRow(TypedResult row, Set<Enum> includeOptions);

  /// Build the final result with all collected data
  T build();

  /// Get the entity ID for this builder
  String get entityId;
}
