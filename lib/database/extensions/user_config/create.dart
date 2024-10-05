import "package:chenron/database/database.dart";
import "package:chenron/utils/logger.dart";
import "package:drift/drift.dart";
import "package:cuid2/cuid2.dart";

extension UserConfigExtensions on ConfigDatabase {
  Future<void> createUserConfig(UserConfig userConfig) async {
    return transaction(() async {
      try {
        final insertConfig = UserConfigsCompanion.insert(
          id: cuidSecure(30),
          darkMode: Value(userConfig.darkMode),
          colorScheme: Value(userConfig.colorScheme),
          archiveOrgS3AccessKey: Value(userConfig.archiveOrgS3AccessKey),
          archiveOrgS3SecretKey: Value(userConfig.archiveOrgS3SecretKey),
        );

        await _createUserConfigEntry(insertConfig);
        loggerGlobal.info(
            "UserCOnfigActionsCreate", "User config created successfully");
      } catch (e) {
        loggerGlobal.severe(
            "UserCOnfigActionsCreate", "Error creating user config: $e");
        rethrow;
      }
    });
  }

  Future<int> _createUserConfigEntry(UserConfigsCompanion userConfig) async {
    return await into(userConfigs).insert(userConfig);
  }
}
