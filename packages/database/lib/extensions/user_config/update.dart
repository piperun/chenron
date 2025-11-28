import "package:database/database.dart";
import "package:database/operations/user_config/user_config_update_vepr.dart";

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

    return operation.run(input);
  }
}


