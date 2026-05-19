import "package:database/database.dart";
import "package:database/schema/user_config_schema.dart";
import "package:database/src/core/handlers/run_vepr.dart";
import "package:database/src/features/user_theme/handlers/insert_handler.dart";
import "package:drift/drift.dart";

typedef UserThemeCUDResults = Map<String, List<UserThemeResultIds>>;

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
  }) {
    return runVepr<bool, UserThemeCUDResults, UserThemeCUDResults>(
      logSource: "updateUserConfig",
      validate: () {
        if (id.trim().isEmpty) {
          throw ArgumentError("UserConfig ID cannot be empty for update.");
        }
        if (themeUpdates != null) {
          for (final theme in themeUpdates.update) {
            if (theme.id.trim().isEmpty) {
              throw ArgumentError("UserTheme ID cannot be empty for update.");
            }
            if (theme.name.trim().isEmpty) {
              throw ArgumentError(
                  "UserTheme name cannot be empty for update (ID: ${theme.id}).");
            }
          }
          for (final themeId in themeUpdates.remove) {
            if (themeId.trim().isEmpty) {
              throw ArgumentError("UserTheme ID cannot be empty for removal.");
            }
          }
          for (final theme in themeUpdates.create) {
            if (theme.name.trim().isEmpty) {
              throw ArgumentError(
                  "UserTheme name cannot be empty for creation.");
            }
          }
        }
      },
      execute: () async {
        final companion = UserConfigsCompanion(
          darkMode:
              darkMode != null ? Value(darkMode) : const Value.absent(),
          defaultArchiveIs: defaultArchiveIs != null
              ? Value(defaultArchiveIs)
              : const Value.absent(),
          defaultArchiveOrg: defaultArchiveOrg != null
              ? Value(defaultArchiveOrg)
              : const Value.absent(),
          archiveOrgS3AccessKey: archiveOrgS3AccessKey != null
              ? (archiveOrgS3AccessKey.isEmpty
                  ? const Value(null)
                  : Value(archiveOrgS3AccessKey))
              : const Value.absent(),
          archiveOrgS3SecretKey: archiveOrgS3SecretKey != null
              ? (archiveOrgS3SecretKey.isEmpty
                  ? const Value(null)
                  : Value(archiveOrgS3SecretKey))
              : const Value.absent(),
          selectedThemeKey: selectedThemeKey != null
              ? (selectedThemeKey.isEmpty
                  ? const Value(null)
                  : Value(selectedThemeKey))
              : const Value.absent(),
          selectedThemeType: selectedThemeType != null
              ? Value(selectedThemeType)
              : const Value.absent(),
          timeDisplayFormat: timeDisplayFormat != null
              ? Value(TimeDisplayFormat.values[timeDisplayFormat])
              : const Value.absent(),
          itemClickAction: itemClickAction != null
              ? Value(ItemClickAction.values[itemClickAction])
              : const Value.absent(),
          cacheDirectory: cacheDirectory != null
              ? (cacheDirectory.isEmpty
                  ? const Value(null)
                  : Value(cacheDirectory))
              : const Value.absent(),
          showDescription: showDescription != null
              ? Value(showDescription)
              : const Value.absent(),
          showImages:
              showImages != null ? Value(showImages) : const Value.absent(),
          showTags: showTags != null ? Value(showTags) : const Value.absent(),
          showCopyLink: showCopyLink != null
              ? Value(showCopyLink)
              : const Value.absent(),
        );
        if (companion != const UserConfigsCompanion()) {
          await (update(userConfigs)..where((tbl) => tbl.id.equals(id)))
              .write(companion);
        }
        return true;
      },
      process: (_) async {
        final results = <String, List<UserThemeResultIds>>{
          "create": [],
          "update": [],
          "remove": [],
        };
        if (themeUpdates == null) return results;

        await batch((b) async {
          if (themeUpdates.create.isNotEmpty) {
            final created = await insertUserThemes(
              batch: b,
              themes: themeUpdates.create,
              userConfigId: id,
            );
            results["create"]!.addAll(created);
          }
          if (themeUpdates.update.isNotEmpty) {
            for (final t in themeUpdates.update) {
              b.update(
                userThemes,
                UserThemesCompanion(
                  name: Value(t.name),
                  primaryColor: Value(t.primaryColor),
                  secondaryColor: Value(t.secondaryColor),
                  tertiaryColor: Value(t.tertiaryColor),
                  seedType: Value(t.seedType),
                  updatedAt: Value(DateTime.now()),
                ),
                where: (tbl) =>
                    tbl.id.equals(t.id) & tbl.userConfigId.equals(id),
              );
              results["update"]!.add(UserThemeResultIds(
                  userThemeId: t.id, userConfigId: id));
            }
          }
          if (themeUpdates.remove.isNotEmpty) {
            for (final themeId in themeUpdates.remove) {
              b.deleteWhere<UserThemes, UserTheme>(
                userThemes,
                (tbl) => tbl.id.equals(themeId) & tbl.userConfigId.equals(id),
              );
              results["remove"]!.add(UserThemeResultIds(
                  userThemeId: themeId, userConfigId: id));
            }
          }
        });
        return results;
      },
      build: (_, proc) => proc,
    );
  }
}
