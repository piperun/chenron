import "package:chenron/database/database.dart";
import "package:logging/logging.dart";
import "package:drift/drift.dart";

extension UserConfigUpdateExtensions on ConfigDatabase {
  static final Logger _logger = Logger("UserConfig Update Database");
  Future<void> updateUserConfig({
    required String id,
    bool? darkMode,
    String? colorScheme,
    String? archiveOrgS3AccessKey,
    String? archiveOrgS3SecretKey,
  }) async {
    return transaction(() async {
      try {
        final updatedUserConfig = UserConfigsCompanion(
          darkMode: darkMode != null ? Value(darkMode) : const Value.absent(),
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
        _logger.info("User config updated successfully");
      } catch (e) {
        _logger.severe("Error updating user config: $e");
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
