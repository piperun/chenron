import 'package:chenron/database/database.dart';
import 'package:logging/logging.dart';

extension UserConfigReadExtensions on ConfigDatabase {
  static final Logger _logger = Logger('UserConfig Read Database');

  Future<UserConfig?> getUserConfig() async {
    try {
      final query = select(userConfigs);
      final result = await query.getSingleOrNull();
      _logger.info('User config retrieved successfully');
      return result;
    } catch (e) {
      _logger.severe('Error retrieving user config: $e');
      rethrow;
    }
  }
}
