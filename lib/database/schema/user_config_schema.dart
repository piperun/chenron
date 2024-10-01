import "package:drift/drift.dart";

class UserConfigs extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  BoolColumn get darkMode => boolean().withDefault(const Constant(false))();
  TextColumn get colorScheme => text().nullable()();
  TextColumn get archiveOrgS3AccessKey => text().nullable()();
  TextColumn get archiveOrgS3SecretKey => text().nullable()();
}
