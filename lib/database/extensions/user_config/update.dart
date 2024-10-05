import "package:chenron/database/database.dart";
import "package:chenron/utils/logger.dart";
import "package:drift/drift.dart";

extension UserConfigUpdateExtensions on ConfigDatabase {
  Future<void> updateUserConfig({
    required String id,
    bool? darkMode,
    bool? archiveEnabled,
    String? colorScheme,
    String? archiveOrgS3AccessKey,
    String? archiveOrgS3SecretKey,
  }) async {
    return transaction(() async {
      try {
        final updatedUserConfig = UserConfigsCompanion(
          darkMode: darkMode != null ? Value(darkMode) : const Value.absent(),
          archiveEnabled: archiveEnabled != null
              ? Value(archiveEnabled)
              : const Value.absent(),
          colorScheme:
              colorScheme != null ? Value(colorScheme) : const Value.absent(),
          archiveOrgS3AccessKey: archiveOrgS3AccessKey != null
              ? Value(archiveOrgS3AccessKey)
              : const Value.absent(),
          archiveOrgS3SecretKey: archiveOrgS3SecretKey != null
              ? Value(archiveOrgS3SecretKey)
              : const Value.absent(),
        );

        await _updateUserConfigEntry(id, updatedUserConfig);
        loggerGlobal.info("UserConfig", "User config updated successfully");
      } catch (e) {
        loggerGlobal.severe("UserConfig", "Error updating user config: $e");
        rethrow;
      }
    });
  }

  Future<int> _updateUserConfigEntry(
      String id, UserConfigsCompanion userConfig) async {
    return await (update(userConfigs)..where((tbl) => tbl.id.equals(id)))
        .write(userConfig);
  }
}
