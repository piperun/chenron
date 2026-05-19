import "package:app_logger/app_logger.dart";
import "package:drift/drift.dart";

/// Phase identifiers used by [runVepr]'s phase-tracking error logger.
/// Exposed so tests + callers can read the same constants.
class VeprPhase {
  static const validate = "Validate";
  static const execute = "Execute";
  static const process = "Process";
  static const build = "Build";
}

/// Helper that runs a write operation through the four VEPR phases
/// (Validate → Execute → Process → Result) inside a single SQLite
/// transaction. Replaces the old `VEPROperation` class hierarchy with
/// a single call site per operation.
///
/// Atomicity contract:
/// 1. The whole call runs inside [GeneratedDatabase.transaction], so
///    a failure in any phase rolls back every preceding DB write.
/// 2. Phase order is sequential: validate → execute → process → build.
///    The type system enforces wiring (`process` must take the `E` that
///    `execute` returned; `build` must take `(E, P)`).
/// 3. [validate] runs before any DB write — invalid input never
///    touches the database.
/// 4. The wrap composes correctly with outer transactions via drift's
///    savepoint nesting.
///
/// Logging:
/// - `fine` log on start and successful completion (filtered in prod).
/// - `severe` log on failure, **tagged with the phase that failed**
///   (`Validate failed: ...`, `Process failed: ...`). Callers don't
///   need to thread loggers through their lambdas to know what blew up.
///
/// Compared to subclassing the old `VEPROperation`: no generic-
/// parameter declarations on the operation type, no `late` field
/// mutation, no `@override` boilerplate, and the operation lives next
/// to its public extension entry point instead of in a separate file.
extension VeprRunner on GeneratedDatabase {
  Future<F> runVepr<E, P, F>({
    required Future<E> Function() execute,
    required Future<P> Function(E execResult) process,
    required F Function(E execResult, P procResult) build,
    void Function()? validate,
    String? logSource,
  }) async {
    final source = logSource ?? "Vepr";
    String currentPhase = VeprPhase.validate;
    loggerGlobal.fine(source, "Starting operation");
    return transaction(() async {
      try {
        if (validate != null) {
          validate();
        }
        currentPhase = VeprPhase.execute;
        final execResult = await execute();
        currentPhase = VeprPhase.process;
        final procResult = await process(execResult);
        currentPhase = VeprPhase.build;
        final result = build(execResult, procResult);
        loggerGlobal.fine(source, "Operation completed successfully");
        return result;
      } catch (e, s) {
        loggerGlobal.severe(source, "$currentPhase failed: $e", e, s);
        rethrow;
      }
    });
  }
}
