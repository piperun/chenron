import "package:database/main.dart";
import "package:database/models/cud.dart";
import "package:database/src/features/user_config/handlers/user_config_update_vepr.dart";

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
    bool? showDescription,
    bool? showImages,
    bool? showTags,
    bool? showCopyLink,
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
      showDescription: showDescription,
      showImages: showImages,
      showTags: showTags,
      showCopyLink: showCopyLink,
      themeUpdates: themeUpdates,
    );

    return operation.run(input);
  }
}
