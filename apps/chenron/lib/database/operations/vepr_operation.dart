import "package:chenron/utils/logger.dart";
import "package:drift/drift.dart"; // Import GeneratedDatabase

/// Abstract base class defining the Validate-Execute-Process-Result (VEPR) sequence.
/// Generic over the specific Database type (DB), Input, Execution Result,
/// Processing Result, and Final Result types.
abstract class VEPROperation<DB extends GeneratedDatabase, Input, ExecResult,
    ProcResult, FinalResult> {
  /// The specific database instance (e.g., AppDatabase, ConfigDatabase).
  final DB db;

  VEPROperation(this.db);

  /// Validates the input data before execution.
  /// Should throw an exception if validation fails.
  void validate(Input input);

  /// Executes the core database action (e.g., insert the main record).
  /// Returns the primary result of the execution (e.g., the new ID).
  /// Note: This method now has access to the correctly typed `db`.
  Future<ExecResult> execute(Input input);

  /// Processes related data or performs follow-up actions after execution.
  /// Often involves batch operations for related entities (tags, items, etc.).
  /// Takes the original input and the result from execute() as parameters.
  /// Note: This method now has access to the correctly typed `db`.
  Future<ProcResult> process(Input input, ExecResult execResult);

  /// Builds the final result object to be returned by the public API method.
  /// Takes results from execute() and process() as parameters.
  FinalResult buildResult(ExecResult execResult, ProcResult procResult);

  /// Helper method to log steps (optional, but good practice)
  void logStep(String step, String message) {
    loggerGlobal.fine("VEPROperation.$runtimeType.$step", message);
  }
}
