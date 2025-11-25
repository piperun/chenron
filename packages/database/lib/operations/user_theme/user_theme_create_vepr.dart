import "package:database/database.dart"; // Needs ConfigDatabase
import "package:database/extensions/insert_ext.dart"; // For insertUserThemes
import "package:database/operations/vepr_operation.dart";
import "package:database/models/created_ids.dart";

// Define Input type
typedef UserThemeCreateInput = ({
  String userConfigId,
  List<UserTheme> themes,
});

// Define Process Result type (None needed for this operation)
typedef UserThemeCreateProcessResult = bool;

// Define Final Result type
typedef UserThemeCreateFinalResult = List<UserThemeResultIds>;

/// Concrete VEPR implementation for creating new UserThemes.
class UserThemeCreateVEPR extends VEPROperation<
    ConfigDatabase, // Specify ConfigDatabase
    UserThemeCreateInput,
    List<UserThemeResultIds>, // Execute Result: The IDs of created themes
    UserThemeCreateProcessResult, // Process Result: None
    UserThemeCreateFinalResult // Final Result: The IDs of created themes
    > {
  // Constructor passes ConfigDatabase instance up
  UserThemeCreateVEPR(super.db);

  @override
  void onValidate() {
    logStep("Validate", "Validating user theme creation input.");
    // Original code allowed empty list, so validation passes even if empty.
    // We could add validation for userConfigId if needed, e.g., check format.
    if (input.userConfigId.trim().isEmpty) {
      throw ArgumentError("userConfigId cannot be empty.");
    }
    logStep("Validate", "Validation passed.");
  }

  @override
  Future<List<UserThemeResultIds>> onExecute() async {
    logStep("Execute",
        "Executing user theme creation for userConfigId: ${input.userConfigId}");

    // Handle empty themes list gracefully, returning empty list as per original logic.
    if (input.themes.isEmpty) {
      logStep("Execute", "No themes provided, returning empty list.");
      return [];
    }

    List<UserThemeResultIds> userThemeResults = [];
    // Use batch for inserting multiple themes efficiently
    await db.batch((batch) async {
      // Assuming insertUserThemes is an extension on ConfigDatabase or Batch
      userThemeResults = await db.insertUserThemes(
          batch: batch, userConfigId: input.userConfigId, themes: input.themes);
    });

    logStep("Execute", "Inserted ${userThemeResults.length} user themes.");
    return userThemeResults;
  }

  @override
  Future<UserThemeCreateProcessResult> onProcess() async {
    // No secondary processing (like linking tags, etc.) is needed after theme creation.
    logStep("Process", "No additional processing required for user themes.");
    return true;
  }

  @override
  UserThemeCreateFinalResult onBuildResult() {
    // The final result is simply the list of IDs returned by the execute step.
    logStep("BuildResult",
        "Building final result (returning execution result directly).");
    return execResult;
  }
}


