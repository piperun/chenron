import "package:database/database.dart";
import "package:database/src/core/handlers/run_vepr.dart";
import "package:database/src/features/user_theme/handlers/insert_handler.dart";

extension UserThemeCreateExtension on ConfigDatabase {
  /// Creates new user themes associated with a user configuration.
  Future<List<UserThemeResultIds>> createUserTheme({
    required String userConfigId,
    required List<UserTheme> themes,
  }) {
    return runVepr<List<UserThemeResultIds>, void, List<UserThemeResultIds>>(
      logSource: "createUserTheme",
      validate: () {
        if (userConfigId.trim().isEmpty) {
          throw ArgumentError("userConfigId cannot be empty.");
        }
      },
      execute: () async {
        if (themes.isEmpty) return <UserThemeResultIds>[];
        List<UserThemeResultIds> results = [];
        await batch((b) async {
          results = await insertUserThemes(
            batch: b,
            userConfigId: userConfigId,
            themes: themes,
          );
        });
        return results;
      },
      process: (_) async {},
      build: (results, _) => results,
    );
  }
}
