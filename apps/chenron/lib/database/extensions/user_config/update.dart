import "package:chenron/database/database.dart";
import "package:chenron/database/operations/user_config/user_config_update_vepr.dart";
import "package:chenron/utils/logger.dart";
import "package:chenron/models/cud.dart";

extension UserConfigUpdateExtensions on ConfigDatabase {
  Future<UserThemeCUDResults> updateUserConfig({
    required String id,
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
  }) async {
    final operation = UserConfigUpdateVEPR(this);

    final UserConfigUpdateInput input = (
      id: id,
      selectedThemeKey: selectedThemeKey,
      selectedThemeType: selectedThemeType,
      darkMode: darkMode,
      defaultArchiveIs: defaultArchiveIs,
      defaultArchiveOrg: defaultArchiveOrg,
      archiveOrgS3AccessKey: archiveOrgS3AccessKey,
      archiveOrgS3SecretKey: archiveOrgS3SecretKey,
      timeDisplayFormat: timeDisplayFormat,
      itemClickAction: itemClickAction,
      cacheDirectory: cacheDirectory,
      themeUpdates: themeUpdates,
    );

    return transaction(() async {
      UserThemeCUDResults finalResult;
      try {
        operation.logStep(
            "Runner", "Starting updateUserConfig operation for ID: $id");

        operation.validate(input);

        await operation.execute(input);

        final UserThemeCUDResults processResult =
            await operation.process(input, null);

        finalResult = operation.buildResult(null, processResult);

        operation.logStep(
            "Runner", "Operation completed successfully for ID: $id");

        loggerGlobal.info("UserConfigUpdateRunner",
            "User config and themes updated successfully for ID: $id. Results: $finalResult");

        return finalResult;
      } catch (e, s) {
        loggerGlobal.severe("UserConfigUpdateRunner",
            "Error updating user config/themes for ID $id: $e\nStackTrace: $s");

        rethrow;
      }
    });
  }
}
