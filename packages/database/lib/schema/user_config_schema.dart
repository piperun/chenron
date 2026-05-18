import "package:drift/drift.dart";
import "package:database/models/enums.dart";

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
  Column<int> get selectedThemeType =>
      intEnum<ThemeType>().withDefault(const Constant(0))();

  Column<int> get timeDisplayFormat =>
      intEnum<TimeDisplayFormat>().withDefault(const Constant(0))();

  Column<int> get itemClickAction =>
      intEnum<ItemClickAction>().withDefault(const Constant(0))();

  // Path to cache directory for images (null = use system temp directory)
  TextColumn get cacheDirectory => text().nullable()();

  // Viewer display preferences
  BoolColumn get showDescription =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get showImages => boolean().withDefault(const Constant(true))();
  BoolColumn get showTags => boolean().withDefault(const Constant(true))();
  BoolColumn get showCopyLink => boolean().withDefault(const Constant(true))();

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
  Column<int> get seedType =>
      intEnum<SeedType>().withDefault(const Constant(0))();

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

// Enum lookup tables (ThemeTypes, TimeDisplayFormats, ItemClickActions,
// SeedTypes) used to live here. They were replaced with `intEnum<T>()`
// columns referencing the matching Dart enums in `models/enums.dart`;
// the v4 -> v5 migration drops the tables and shifts the existing
// 1-based values down by 1 to match Drift's 0-based intEnum storage.
