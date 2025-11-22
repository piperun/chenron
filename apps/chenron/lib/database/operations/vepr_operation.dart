import "package:chenron/utils/logger.dart";
import "package:drift/drift.dart"; // Import GeneratedDatabase
import "package:meta/meta.dart";

/// Abstract base class defining the Validate-Execute-Process-Result (VEPR) sequence.
/// Generic over the specific Database type (DB), Input, Execution Result,
/// Processing Result, and Final Result types.
abstract class VEPROperation<DB extends GeneratedDatabase, Input, ExecResult,
    ProcResult, FinalResult> {
  /// The specific database instance (e.g., AppDatabase, ConfigDatabase).
  final DB db;

  /// State variables
  late Input input;
  late ExecResult execResult;
  late ProcResult procResult;

  VEPROperation(this.db);

  /// Orchestrates the VEPR flow within a transaction.
  Future<FinalResult> run(Input input) async {
    return db.transaction(() async {
      try {
        logStep("Runner", "Starting operation");

        validate(input);
        await execute();
        await process();
        final finalResult = buildResult();

        logStep("Runner", "Operation completed successfully");
        return finalResult;
      } catch (e) {
        loggerGlobal.severe("VEPROperation", "Error during operation: $e");
        rethrow;
      }
    });
  }

  /// Validates the input data before execution.
  /// Sets [input] state.
  void validate(Input input) {
    this.input = input;
    onValidate();
  }

  /// Executes the core database action.
  /// Sets [execResult] state.
  Future<void> execute() async {
    execResult = await onExecute();
  }

  /// Processes related data or performs follow-up actions.
  /// Sets [procResult] state.
  Future<void> process() async {
    procResult = await onProcess();
  }

  /// Builds the final result object.
  FinalResult buildResult() {
    return onBuildResult();
  }

  // --- Abstract Hooks ---

  /// Hook for validation logic. Access [input].
  @protected
  void onValidate();

  /// Hook for execution logic. Access [input]. Returns [ExecResult].
  @protected
  Future<ExecResult> onExecute();

  /// Hook for processing logic. Access [input] and [execResult]. Returns [ProcResult].
  @protected
  Future<ProcResult> onProcess();

  /// Hook for result building. Access [input], [execResult], and [procResult]. Returns [FinalResult].
  @protected
  FinalResult onBuildResult();

  /// Helper method to log steps
  void logStep(String step, String message) {
    loggerGlobal.fine("VEPROperation.$runtimeType.$step", message);
  }
}
