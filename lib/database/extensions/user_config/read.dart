import "package:chenron/database/database.dart";
import "package:chenron/utils/logger.dart";

extension UserConfigReadExtensions on ConfigDatabase {
  Future<UserConfig?> getUserConfig() async {
    try {
      final query = select(userConfigs);
      final result = await query.getSingleOrNull();
      loggerGlobal.info(
          "UserConfigActionsRead", "User config retrieved successfully");
      return result;
    } catch (e) {
      loggerGlobal.severe(
          "UserConfigActionsRead", "Error retrieving user config: $e");
      rethrow;
    }
  }
}
