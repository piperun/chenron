import "package:database/database.dart";
// Remove old extension imports if they are only used by the old private method
// import "package:database/extensions/insert_ext.dart";
import "package:database/operations/user_theme/user_theme_create_vepr.dart"; // Import VEPR class
import "package:database/models/created_ids.dart";

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
    // 3. Execute the operation using the run macro
    return operation.run(input);
  }

  // Remove the old private helper method _createUserTheme
  // Future<List<UserThemeResultIds>> _createUserTheme(...) async { ... } // REMOVE
}


