import "package:chenron/database/database.dart"; // ConfigDatabase, UserConfigsCompanion, UserThemesCompanion, UserTheme
import "package:chenron/database/operations/vepr_operation.dart";
import "package:chenron/database/schema/user_config_schema.dart"; // For table refs if needed, though types come from database.dart
import "package:chenron/models/cud.dart"; // Import CUD
import "package:chenron/models/created_ids.dart"; // Import UserThemeResultIds
import "package:chenron/database/extensions/insert_ext.dart"; // For insertUserThemes extension
import "package:drift/drift.dart"; // Value, batch, deleteWhere, update

// Define Input type using a Record - Updated archive fields
// NOTE: The UserTheme type within CUD<> assumes it's the generated class
// reflecting the NEW schema (primarySeedValue, etc.)
typedef UserConfigUpdateInput = ({
  String id,
  String? selectedThemeKey,
  ThemeType? selectedThemeType,
  bool? darkMode,
  bool? defaultArchiveIs,
  bool? defaultArchiveOrg,
  String? archiveOrgS3AccessKey,
  String? archiveOrgS3SecretKey,
  int? timeDisplayFormat,
  int? itemClickAction,
  String? cacheDirectory,
  CUD<UserTheme>? themeUpdates,
});

// Define the type for the results of theme CUD operations
typedef UserThemeCUDResults = Map<String, List<UserThemeResultIds>>;

// Define Execute Result type (Empty record instead of void)
typedef UserConfigUpdateExecuteResult = bool;

/// Concrete VEPR implementation for updating a UserConfig and its Themes.
/// - Execute: Updates only the UserConfig record.
/// - Process: Handles UserTheme CUD operations within a batch.
class UserConfigUpdateVEPR extends VEPROperation<
    ConfigDatabase, // Database type
    UserConfigUpdateInput, // Input type
    UserConfigUpdateExecuteResult, // Execute returns empty record
    UserThemeCUDResults, // Process returns theme results
    UserThemeCUDResults // Final result is the theme results map
    > {
  // Constructor passes the ConfigDatabase instance up
  UserConfigUpdateVEPR(super.db);

  @override
  void onValidate() {
    logStep("Validate",
        "Starting validation for updating user config ID: ${input.id}");
    if (input.id.trim().isEmpty) {
      throw ArgumentError("UserConfig ID cannot be empty for update.");
    }

    // S3 Key validation (Remains the same)
    if (input.defaultArchiveOrg == true &&
        (input.archiveOrgS3AccessKey == null ||
            input.archiveOrgS3AccessKey!.trim().isEmpty ||
            input.archiveOrgS3SecretKey == null ||
            input.archiveOrgS3SecretKey!.trim().isEmpty)) {
      logStep("Validate",
          "Warning: defaultArchiveOrg is true, but S3 keys are missing or empty.");
      // Consider if this should be an error based on requirements
    }

    if (input.themeUpdates != null) {
      logStep("Validate", "Validating theme updates...");

      // --- Updated Theme Validation ---
      for (final theme in input.themeUpdates!.update) {
        if (theme.id.trim().isEmpty) {
          throw ArgumentError("UserTheme ID cannot be empty for update.");
        }
        if (theme.name.trim().isEmpty) {
          throw ArgumentError(
              "UserTheme name cannot be empty for update (ID: ${theme.id}).");
        }
      }
      for (final themeId in input.themeUpdates!.remove) {
        if (themeId.trim().isEmpty) {
          throw ArgumentError("UserTheme ID cannot be empty for removal.");
        }
      }
      for (final theme in input.themeUpdates!.create) {
        if (theme.name.trim().isEmpty) {
          throw ArgumentError("UserTheme name cannot be empty for creation.");
        }
      }
      // --- End Updated Theme Validation ---
      logStep("Validate", "Theme updates validation passed.");
    }

    logStep("Validate", "Validation passed");
  }

  @override
  Future<UserConfigUpdateExecuteResult> onExecute() async {
    // Execute step: Only update the main UserConfig entity.
    // This part is unaffected by the UserThemes schema change.
    logStep("Execute", "Starting UserConfig update for ID: ${input.id}");

    final userConfigCompanion = UserConfigsCompanion(
      darkMode: input.darkMode != null
          ? Value(input.darkMode!)
          : const Value.absent(),
      defaultArchiveIs: input.defaultArchiveIs != null
          ? Value(input.defaultArchiveIs!)
          : const Value.absent(),
      defaultArchiveOrg: input.defaultArchiveOrg != null
          ? Value(input.defaultArchiveOrg!)
          : const Value.absent(),
      archiveOrgS3AccessKey: input.archiveOrgS3AccessKey != null
          ? Value(input.archiveOrgS3AccessKey) // Allow setting to null/empty
          : const Value.absent(),
      archiveOrgS3SecretKey: input.archiveOrgS3SecretKey != null
          ? Value(input.archiveOrgS3SecretKey) // Allow setting to null/empty
          : const Value.absent(),
      selectedThemeKey: input.selectedThemeKey != null
          ? Value(input.selectedThemeKey)
          : const Value.absent(),
      selectedThemeType: input.selectedThemeType != null
          ? Value(input.selectedThemeType!.index)
          : const Value.absent(),
      timeDisplayFormat: input.timeDisplayFormat != null
          ? Value(input.timeDisplayFormat!)
          : const Value.absent(),
      itemClickAction: input.itemClickAction != null
          ? Value(input.itemClickAction!)
          : const Value.absent(),
      cacheDirectory: input.cacheDirectory != null
          ? Value(input.cacheDirectory)
          : const Value.absent(),
    );

    // Only perform update if there are fields to update
    if (userConfigCompanion != const UserConfigsCompanion()) {
      await (db.update(db.userConfigs)..where((tbl) => tbl.id.equals(input.id)))
          .write(userConfigCompanion);
      logStep("Execute", "UserConfig update executed for ID: ${input.id}.");
    } else {
      logStep("Execute", "No UserConfig fields to update for ID: ${input.id}.");
    }

    return true;
  }

  @override
  Future<UserThemeCUDResults> onProcess() async {
    // Process step: Handle related UserTheme CUD operations.
    logStep("Process",
        "Starting UserTheme CUD processing for UserConfig ID: ${input.id}");

    final UserThemeCUDResults themeResults = {
      "create": [],
      "update": [],
      "remove": [],
    };

    if (input.themeUpdates != null && input.themeUpdates!.isNotEmpty) {
      await db.batch((batch) async {
        final CUD<UserTheme> updates = input.themeUpdates!;

        // Create new themes
        if (updates.create.isNotEmpty) {
          logStep("Process (Batch)",
              "Scheduling ${updates.create.length} theme creations.");
          // Call the updated insertUserThemes extension method.
          // It now expects UserTheme objects with seed values.
          final createdThemeIds = await db.insertUserThemes(
            batch: batch,
            themes: updates.create, // Pass the UserTheme objects directly
            userConfigId: input.id,
          );
          themeResults["create"]!.addAll(createdThemeIds);
        }

        // Update existing themes
        if (updates.update.isNotEmpty) {
          logStep("Process (Batch)",
              "Scheduling ${updates.update.length} theme updates.");
          for (final themeToUpdate in updates.update) {
            // --- Create Companion with NEW Schema Fields ---
            final themeCompanion = UserThemesCompanion(
              name: Value(themeToUpdate.name),
              // Update seed values using the properties from the UserTheme object
              primaryColor: Value(themeToUpdate.primaryColor),
              secondaryColor: Value(themeToUpdate.secondaryColor),
              tertiaryColor: Value(themeToUpdate.tertiaryColor),
              // REMOVE old 'theme' field
              // theme: Value(themeToUpdate.theme),
            );
            // --- End Companion Update ---

            batch.update(
              db.userThemes,
              themeCompanion, // Use the updated companion
              where: (tbl) =>
                  tbl.id.equals(themeToUpdate.id) &
                  tbl.userConfigId.equals(input.id),
            );
            // Result ID structure remains the same
            themeResults["update"]!.add(UserThemeResultIds(
                userThemeId: themeToUpdate.id, userConfigId: input.id));
          }
        }

        if (updates.remove.isNotEmpty) {
          logStep("Process (Batch)",
              "Scheduling ${updates.remove.length} theme removals.");
          final bool removingSelected = (input.selectedThemeKey != null &&
                  input.selectedThemeType == ThemeType.custom) &&
              updates.remove.contains(input.selectedThemeKey);
          if (removingSelected) {
            logStep("Process (Batch)",
                "Warning: Removing the currently selected theme (${input.selectedThemeKey}). The selectedThemeKey field on UserConfig might need to be cleared or updated separately by the caller or via a subsequent operation.");
            // Note: The foreign key constraint `onDelete: KeyAction.setNull` in the schema
            // should handle setting UserConfigs.selectedThemeId to null automatically if
            // the referenced theme is deleted. This warning is still useful for logging.
          }
          for (final themeIdToRemove in updates.remove) {
            batch.deleteWhere<UserThemes, UserTheme>(
              db.userThemes,
              (tbl) =>
                  tbl.id.equals(themeIdToRemove) &
                  tbl.userConfigId.equals(input.id),
            );
            // Result ID structure remains the same
            themeResults["remove"]!.add(UserThemeResultIds(
                userThemeId: themeIdToRemove, userConfigId: input.id));
          }
        }
      });
      logStep("Process", "UserTheme CUD batch processing completed.");
    } else {
      logStep("Process", "No UserTheme updates to process.");
    }

    return themeResults;
  }

  @override
  UserThemeCUDResults onBuildResult() {
    logStep("BuildResult", "Building final result (UserThemeCUDResults map).");
    return procResult;
  }
}
