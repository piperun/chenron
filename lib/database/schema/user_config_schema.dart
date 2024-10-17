import "package:drift/drift.dart";

class UserConfigs extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  BoolColumn get darkMode => boolean().withDefault(const Constant(false))();
  BoolColumn get copyOnImport => boolean().withDefault(const Constant(true))();
  BoolColumn get archiveEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get colorScheme => text().nullable()();
  TextColumn get archiveOrgS3AccessKey => text().nullable()();
  TextColumn get archiveOrgS3SecretKey => text().nullable()();
}

class BackupSettings extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get backupInterval => text().nullable()();
  TextColumn get backupFilename => text().nullable()();
  TextColumn get backupPath => text().nullable()();
}

class ArchiveSettings extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get archiveOrgS3AccessKey => text().nullable()();
  TextColumn get archiveOrgS3SecretKey => text().nullable()();
}
