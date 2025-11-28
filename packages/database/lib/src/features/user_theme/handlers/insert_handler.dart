import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/src/core/id.dart";
import "package:drift/drift.dart";

extension ConfigDatabaseInserts on ConfigDatabase {
  Future<List<UserThemeResultIds>> insertUserThemes({
    required Batch batch,
    required List<UserTheme> themes,
    required String userConfigId,
  }) async {
    final List<UserThemeResultIds> results = <UserThemeResultIds>[];
    if (themes.isEmpty) return results;

    for (final UserTheme theme in themes) {
      final String themeId = generateId();
      batch.insert(
        userThemes,
        UserThemesCompanion.insert(
          id: themeId,
          userConfigId: userConfigId,
          name: theme.name,
          primaryColor: theme.primaryColor,
          secondaryColor: theme.secondaryColor,
          tertiaryColor: Value(theme.tertiaryColor),
          seedType: Value(theme.seedType),
        ),
      );

      results.add(
          CreatedIds.userTheme(userThemeId: themeId, userConfigId: userConfigId)
              as UserThemeResultIds);
    }

    return results;
  }
}
