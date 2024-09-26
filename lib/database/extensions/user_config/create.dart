import 'package:chenron/database/database.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:cuid2/cuid2.dart';

extension UserConfigExtensions on ConfigDatabase {
  static final Logger _logger = Logger('UserConfig Actions Database');

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
        _logger.info('User config created successfully');
      } catch (e) {
        _logger.severe('Error creating user config: $e');
        rethrow;
      }
    });
  }

  Future<int> _createUserConfigEntry(UserConfigsCompanion userConfig) async {
    return await into(userConfigs).insert(userConfig);
  }
}
