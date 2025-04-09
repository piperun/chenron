import "package:drift/drift.dart";

class UserConfigs extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  BoolColumn get darkMode => boolean().withDefault(const Constant(false))();
  BoolColumn get copyOnImport => boolean().withDefault(const Constant(true))();

  TextColumn get archiveOrgS3AccessKey => text().nullable()();
  TextColumn get archiveOrgS3SecretKey => text().nullable()();

  BoolColumn get archiveEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get colorScheme => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserThemes extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get userConfigId => text().references(UserConfigs, #id)();
  TextColumn get name => text().unique()();
  TextColumn get theme => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class BackupSettings extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get userConfigId => text().references(UserConfigs, #id)();
  TextColumn get backupInterval => text().nullable()();
  TextColumn get backupFilename => text().nullable()();
  TextColumn get backupPath => text().nullable()();
  DateTimeColumn get lastBackupTimestamp => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ArchiveSettings extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get userConfigId => text().references(UserConfigs, #id)();
  TextColumn get archiveOrgS3AccessKey => text().nullable()();
  TextColumn get archiveOrgS3SecretKey => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
