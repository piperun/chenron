import "package:drift/drift.dart";

class UserConfigs extends Table {
  TextColumn get id => text().withLength(min: 30, max: 60)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  BoolColumn get darkMode => boolean().withDefault(const Constant(false))();
  BoolColumn get copyOnImport => boolean().withDefault(const Constant(true))();
  BoolColumn get defaultArchiveIs =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get defaultArchiveOrg =>
      boolean().withDefault(const Constant(false))();
  TextColumn get archiveOrgS3AccessKey => text().nullable()();
  TextColumn get archiveOrgS3SecretKey => text().nullable()();

  TextColumn get selectedThemeKey => text().nullable()();
  IntColumn get selectedThemeType =>
      integer().references(ThemeTypes, #id).withDefault(const Constant(0))();

  IntColumn get timeDisplayFormat => integer()
      .references(TimeDisplayFormats, #id)
      .withDefault(const Constant(0))();

  IntColumn get itemClickAction => integer()
      .references(ItemClickActions, #id)
      .withDefault(const Constant(0))();

  // Path to cache directory for images (null = use system temp directory)
  TextColumn get cacheDirectory => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserThemes extends Table {
  // Keep ID as text for uniqueness and referencing
  TextColumn get id => text().withLength(min: 30, max: 60)();
  TextColumn get userConfigId => text().references(UserConfigs, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get name => text().unique()();

  IntColumn get primaryColor => integer()();
  IntColumn get secondaryColor => integer()();
  IntColumn get tertiaryColor => integer().nullable()();
  IntColumn get seedType =>
      integer().references(SeedTypes, #id).withDefault(const Constant(0))();

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

// Enum type tables
@DataClassName('ThemeTypeEntity')
class ThemeTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

@DataClassName('TimeDisplayFormatEntity')
class TimeDisplayFormats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

@DataClassName('ItemClickActionEntity')
class ItemClickActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

@DataClassName('SeedTypeEntity')
class SeedTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}
