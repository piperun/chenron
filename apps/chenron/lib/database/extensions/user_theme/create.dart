import "package:chenron/database/database.dart";
// Remove old extension imports if they are only used by the old private method
// import "package:chenron/database/extensions/insert_ext.dart";
import "package:chenron/database/operations/user_theme/user_theme_create_vepr.dart"; // Import VEPR class
import "package:chenron/models/created_ids.dart";
import "package:chenron/utils/logger.dart"; // Keep logger

extension UserThemeCreateExtension on ConfigDatabase {
  /// Creates new user themes associated with a user configuration using the VEPR pattern.
  Future<List<UserThemeResultIds>> createUserTheme({
    required String userConfigId,
    required List<UserTheme> themes,
  }) async {
    // Public API method acts as the RUNNER

    // 1. Instantiate the specific VEPR implementation
    final operation =
        UserThemeCreateVEPR(this); // Pass the ConfigDatabase instance

    // 2. Prepare the input (using the typedef'd Record)
    final UserThemeCreateInput input = (
      userConfigId: userConfigId,
      themes: themes,
    );

    // 3. Execute the operation within a transaction
    // Note: The original code used transaction, let's keep it for consistency,
    // although batch might be sufficient if insertUserThemes is atomic enough.
    return transaction(() async {
      try {
        // Call the VEPR steps sequentially
        operation.logStep("Runner", "Starting createUserTheme operation");
        operation.validate(input);
        final execResult = await operation.execute(input);
        // Pass execResult to process, even though it doesn't use it here
        await operation.process(input, execResult);
        // Pass null or a placeholder for the void processResult
        final finalResult = operation.buildResult(execResult, null);
        operation.logStep("Runner", "Operation completed successfully");
        return finalResult;
      } catch (e) {
        // Log the error before rethrowing
        loggerGlobal.severe("UserThemeCreateRunner",
            "Error during createUserTheme operation: $e");
        // Transaction will handle rollback
        rethrow;
      }
    });
  }

  // Remove the old private helper method _createUserTheme
  // Future<List<UserThemeResultIds>> _createUserTheme(...) async { ... } // REMOVE
}
