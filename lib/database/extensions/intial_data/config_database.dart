import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/user_config/create.dart';
import 'package:cuid2/cuid2.dart';

extension ConfigDatabaseInit on ConfigDatabase {
  Future<void> setupUserConfig() async {
    await _setupUserConfigEntry();
  }

  Future<void> _setupUserConfigEntry() async {
    final existingConfig = await select(userConfigs).getSingleOrNull();
    if (existingConfig == null) {
      final defaultConfig = UserConfig(
        id: cuidSecure(30),
        darkMode: false,
        colorScheme: null,
        archiveOrgS3AccessKey: null,
        archiveOrgS3SecretKey: null,
      );
      await createUserConfig(defaultConfig);
    }
  }
}
