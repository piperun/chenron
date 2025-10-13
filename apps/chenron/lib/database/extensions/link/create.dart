import "package:chenron/database/database.dart";
import "package:chenron/database/operations/link/link_create_vepr.dart";
import "package:chenron/models/created_ids.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/utils/logger.dart";

extension LinkCreateExtensions on AppDatabase {
  /// Creates a new link along with its optional tags using the VEPR pattern.
  Future<LinkResultIds> createLink({
    required String link,
    List<Metadata>? tags,
  }) async {
    // Public API method acts as the RUNNER

    // 1. Instantiate the specific VEPR implementation
    final operation = LinkCreateVEPR(this);

    final LinkCreateInput input = (
      url: link,
      tags: tags,
    );

    return transaction(() async {
      try {
        // Call the VEPR steps sequentially
        operation.logStep("Runner", "Starting createLink operation");
        operation.validate(input);
        final execResult = await operation.execute(input);
        final procResult = await operation.process(input, execResult);
        final finalResult = operation.buildResult(execResult, procResult);
        operation.logStep("Runner", "Operation completed successfully");
        return finalResult;
      } catch (e) {
        // Log the error before rethrowing
        loggerGlobal.severe(
            "LinkCreateRunner", "Error during createLink operation: $e");
        // Transaction will handle rollback
        rethrow;
      }
    });
  }
}
