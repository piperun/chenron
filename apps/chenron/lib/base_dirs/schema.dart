// The chenron directory schema lives in the database package because
// `AppFileService` (which the cache_manager <-> drift glue uses) needs
// to reference the same enum type at its locator-lookup site. Two
// independent definitions would be distinct Dart types — GetIt would
// see them as unrelated, and the registered `Future<BaseDirectories<
// ChenronDir>?>` wouldn't match the lookup. Re-exporting keeps every
// chenron consumer's existing import path working.
export "package:database/dir_schema.dart";
