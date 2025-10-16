import "package:drift/drift.dart";

class UserConfigs extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  BoolColumn get darkMode => boolean().withDefault(const Constant(false))();
  BoolColumn get copyOnImport => boolean().withDefault(const Constant(true))();
  BoolColumn get defaultArchiveIs =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get defaultArchiveOrg =>
      boolean().withDefault(const Constant(false))();
  TextColumn get archiveOrgS3AccessKey => text().nullable()();
  TextColumn get archiveOrgS3SecretKey => text().nullable()();

  TextColumn get selectedThemeKey => text().nullable()();
  // 0 = custom, 1 = system
  IntColumn get selectedThemeType => integer().withDefault(const Constant(0))();

  // 0 = relative (e.g., "2h ago"), 1 = absolute (e.g., "2025-01-01 14:30")
  IntColumn get timeDisplayFormat => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserThemes extends Table {
  // Keep ID as text for uniqueness and referencing
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get userConfigId => text().references(UserConfigs, #id)();
  TextColumn get name => text().unique()();

  IntColumn get primaryColor => integer()();
  IntColumn get secondaryColor => integer()();
  IntColumn get tertiaryColor => integer().nullable()();
  // 0 = none, 1 = primary, 2 = primary+secondary, 3 = primary+secondary+tertiary
  IntColumn get seedType => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class BackupSettings extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get userConfigId =>
      text().references(UserConfigs, #id, onDelete: KeyAction.cascade)();
  TextColumn get backupInterval => text().nullable()();
  TextColumn get backupFilename => text().nullable()();
  TextColumn get backupPath => text().nullable()();
  DateTimeColumn get lastBackupTimestamp => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
